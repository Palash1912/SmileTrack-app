import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/brushing_log.dart';
import '../../data/repositories/brushing_repository.dart';
import '../../../../shared/providers/auth_provider.dart';

final brushingRepositoryProvider = Provider<BrushingRepository>((ref) {
  return BrushingRepository();
});

// Tracks locally logged sessions today — survives timer resets
final localTodaySessionsProvider =
    StateProvider<Set<BrushingSession>>((ref) => {});

class BrushingLogsNotifier extends AsyncNotifier<List<BrushingLog>> {
  @override
  Future<List<BrushingLog>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];
    final repo = ref.read(brushingRepositoryProvider);
    final effectiveNow =
        repo.getEffectiveLocalTime(DateTime.now().toUtc(), user.timezone);
    return repo.getMonthLogs(
      userId: user.uid,
      year: effectiveNow.year,
      month: effectiveNow.month,
      timezone: user.timezone,
    );
  }

  void addOptimistic(BrushingLog log) {
    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, log]);
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final repo = ref.read(brushingRepositoryProvider);
    final effectiveNow =
        repo.getEffectiveLocalTime(DateTime.now().toUtc(), user.timezone);
    final newLogs = await repo.getMonthLogs(
      userId: user.uid,
      year: effectiveNow.year,
      month: effectiveNow.month,
      timezone: user.timezone,
    );
    state = AsyncData(newLogs);
  }
}

final brushingLogsProvider =
    AsyncNotifierProvider<BrushingLogsNotifier, List<BrushingLog>>(
  BrushingLogsNotifier.new,
);

final dailyStatusProvider =
    Provider<Map<DateTime, DailyBrushingStatus>>((ref) {
  final user = ref.watch(currentUserProvider);
  final logsAsync = ref.watch(brushingLogsProvider);
  final localSessions = ref.watch(localTodaySessionsProvider);
  final repo = ref.read(brushingRepositoryProvider);
  final tz = user?.timezone ?? 'UTC';
  final effectiveNow = repo.getEffectiveLocalTime(DateTime.now().toUtc(), tz);
  final todayKey =
      DateTime(effectiveNow.year, effectiveNow.month, effectiveNow.day);

  Map<DateTime, DailyBrushingStatus> buildMap(List<BrushingLog> logs) {
    if (user == null) return {};
    final map = Map<DateTime, DailyBrushingStatus>.from(
      repo.buildDailyStatusMap(
        logs: logs,
        timezone: user.timezone,
        today: DateTime.now().toUtc(),
      ),
    );

    // Merge today's locally tracked sessions — survives timer reset
    if (localSessions.isNotEmpty) {
      final existing = map[todayKey];
      final morning = (existing?.morningBrushed ?? false) ||
          localSessions.contains(BrushingSession.morning);
      final evening = (existing?.eveningBrushed ?? false) ||
          localSessions.contains(BrushingSession.evening);

      DayStatus status;
      if (morning && evening) {
        status = DayStatus.green;
      } else if (morning || evening) {
        status = DayStatus.yellow;
      } else {
        status = existing?.status ?? DayStatus.red;
      }

      map[todayKey] = DailyBrushingStatus(
        date: todayKey,
        morningBrushed: morning,
        eveningBrushed: evening,
        status: status,
      );
    }

    return map;
  }

  return logsAsync.when(
    data: (logs) => buildMap(logs),
    loading: () => buildMap(ref.read(brushingLogsProvider).valueOrNull ?? []),
    error: (_, __) =>
        buildMap(ref.read(brushingLogsProvider).valueOrNull ?? []),
  );
});

final todayStatusProvider = Provider<DailyBrushingStatus?>((ref) {
  final statusMap = ref.watch(dailyStatusProvider);
  final user = ref.watch(currentUserProvider);
  final repo = ref.read(brushingRepositoryProvider);
  final tz = user?.timezone ?? 'UTC';
  final effectiveNow = repo.getEffectiveLocalTime(DateTime.now().toUtc(), tz);
  final todayKey =
      DateTime(effectiveNow.year, effectiveNow.month, effectiveNow.day);
  return statusMap[todayKey];
});

final todayBrushingCountProvider = Provider<int>((ref) {
  final status = ref.watch(todayStatusProvider);
  if (status == null) return 0;
  int count = 0;
  if (status.morningBrushed) count++;
  if (status.eveningBrushed) count++;
  return count;
});

final streakProvider = Provider<Map<String, int>>((ref) {
  final user = ref.read(currentUserProvider);
  final statusMap = ref.watch(dailyStatusProvider);
  if (user == null || statusMap.isEmpty) return {'current': 0, 'max': 0};
  final repo = ref.read(brushingRepositoryProvider);
  return repo.calculateStreaks(
    statusMap: statusMap,
    timezone: user.timezone,
  );
});

final brushingLoadingProvider = StateProvider<bool>((ref) => false);

final logBrushingProvider =
    Provider<Future<void> Function(int durationSeconds)>((ref) {
  return (int durationSeconds) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    ref.read(brushingLoadingProvider.notifier).state = true;

    try {
      final repo = ref.read(brushingRepositoryProvider);
      final authRepo = ref.read(authRepositoryProvider);
      final now = DateTime.now().toUtc();

      final effectiveLocal = repo.getEffectiveLocalTime(now, user.timezone);
      final session = effectiveLocal.hour < 12
          ? BrushingSession.morning
          : BrushingSession.evening;

      // STEP 1: Save session locally — survives timer resets
      ref.read(localTodaySessionsProvider.notifier).update(
            (s) => {...s, session},
          );

      // STEP 2: Optimistic log
      final optimisticLog = BrushingLog(
        id: 'optimistic_${now.millisecondsSinceEpoch}',
        userId: user.uid,
        timestamp: now,
        session: session,
        timezone: user.timezone,
        durationSeconds: durationSeconds,
        pointsEarned: 10,
      );
      ref.read(brushingLogsProvider.notifier).addOptimistic(optimisticLog);

      // STEP 3: Optimistic points update
      final updatedUser = user.copyWith(totalPoints: user.totalPoints + 10);
      ref.read(currentUserProvider.notifier).state = updatedUser;

      // STEP 4: Release loading state
      ref.read(brushingLoadingProvider.notifier).state = false;

      // STEP 5: SQLite + Firestore write
      final result = await repo.logBrushing(
        userId: user.uid,
        timezone: user.timezone,
        durationSeconds: durationSeconds,
        explicitSession: session,
      );

      if (result != null) {
        // STEP 6: Persist points
        await authRepo.updateUserProfile(updatedUser);
        // STEP 7: Sync real data
        await ref.read(brushingLogsProvider.notifier).refresh();
      } else {
        // Already logged — roll back
        ref.read(localTodaySessionsProvider.notifier).update(
              (s) => s.where((e) => e != session).toSet(),
            );
        ref.read(currentUserProvider.notifier).state = user;
        await ref.read(brushingLogsProvider.notifier).refresh();
      }
    } catch (e) {
      ref.invalidate(brushingLogsProvider);
      print("Error logging brushing: $e");
      rethrow;
    } finally {
      ref.read(brushingLoadingProvider.notifier).state = false;
    }
  };
});