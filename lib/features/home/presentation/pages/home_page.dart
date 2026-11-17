import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../brushing/data/models/brushing_log.dart';
import '../../../brushing/presentation/providers/brushing_provider.dart';
import '../widgets/tooth_character.dart';
import '../widgets/streak_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // Refresh user data when home page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
    });
  }

  Future<void> _refreshUserData() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(currentUserProvider.notifier).refreshFromFirestore(user.uid);
      await ref.read(brushingLogsProvider.notifier).refresh();
    }
  }

  Color _getDayColor(DayStatus? status) {
    switch (status) {
      case DayStatus.green:
        return AppTheme.calGreen;
      case DayStatus.yellow:
        return AppTheme.calYellow;
      case DayStatus.red:
        return AppTheme.calRed;
      default:
        return AppTheme.calWhite;
    }
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    Map<DateTime, DailyBrushingStatus> dailyStatus,
    ThemeData theme, {
    bool isToday = false,
  }) {
    final dateKey = DateTime(day.year, day.month, day.day);
    final status = dailyStatus[dateKey];
    final color = _getDayColor(status?.status);
    final hasStatus = status != null;
    final borderColor = hasStatus ? color : AppTheme.primaryMint;
    final bgColor = hasStatus
        ? color.withOpacity(0.2)
        : isToday
            ? AppTheme.primaryMint.withOpacity(0.15)
            : Colors.transparent;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: isToday ? 2.0 : 1.5,
        ),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
            color: hasStatus
                ? color.withOpacity(0.9)
                : isToday
                    ? AppTheme.primaryMint
                    : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final dailyStatus = ref.watch(dailyStatusProvider);
    final streaks = ref.watch(streakProvider);
    final todayStatus = ref.watch(todayStatusProvider);
    final theme = Theme.of(context);

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.login);
      });
      return const SizedBox();
    }

    final now = DateTime.now();
    final isEvening = now.hour >= 12;
    final isMorning = now.hour < 12;
    final todayStatusValue = todayStatus?.status ?? DayStatus.white;
    final eveningDone = todayStatus?.eveningBrushed ?? false;
    final morningDone = todayStatus?.morningBrushed ?? false;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryMint,
          onRefresh: () async {
            ref.invalidate(brushingLogsProvider);
            await _refreshUserData();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppHeader(),
                      const SizedBox(height: 8),

                      // Greeting + Points
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_getGreeting(),
                                    style: theme.textTheme.bodyMedium),
                                Text(user.displayName,
                                    style: theme.textTheme.displaySmall),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.accentYellow,
                                  Color(0xFFFFB347)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Text('⭐',
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 4),
                                Text(
                                  '${user.totalPoints}',
                                  style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 24),

                      // Tooth Character
                      ToothCharacter(todayStatus: todayStatus)
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.2, duration: 500.ms),

                      const SizedBox(height: 24),

                      // Brush button
                      if (todayStatusValue != DayStatus.green && !eveningDone)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => context.go(AppRoutes.brushing),
                            icon: const Text('🪥',
                                style: TextStyle(fontSize: 20)),
                            label: Text(
                              isMorning &&
                                      todayStatusValue != DayStatus.yellow
                                  ? 'Start Morning Brush!'
                                  : isEvening &&
                                          todayStatusValue != DayStatus.green
                                      ? 'Complete Evening Brush!'
                                      : 'Log Brushing',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 18),
                            ),
                          ),
                        ).animate().fadeIn(delay: 300.ms),

                      if (todayStatusValue == DayStatus.green || eveningDone)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.calGreen.withOpacity(0.15),
                                AppTheme.accentBlue.withOpacity(0.1)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppTheme.calGreen.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Text('🎉',
                                  style: TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      morningDone && eveningDone
                                          ? 'Amazing! All done today!'
                                          : 'Great job! Keep it up!',
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                              color: AppTheme.calGreen),
                                    ),
                                    Text(
                                      morningDone && eveningDone
                                          ? 'You brushed morning & evening 🌟'
                                          : eveningDone
                                              ? 'You completed your evening brush! 🌙'
                                              : 'You completed your morning brush! ☀️',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 24),

                      // Streak cards
                      StreakCard(
                        currentStreak: streaks['current'] ?? 0,
                        maxStreak: streaks['max'] ?? 0,
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 24),

                      // Calendar section
                      Text('Monthly Progress',
                              style: theme.textTheme.headlineLarge)
                          .animate()
                          .fadeIn(delay: 450.ms),
                      const SizedBox(height: 4),
                      Text('Your brushing calendar',
                              style: theme.textTheme.bodyMedium)
                          .animate()
                          .fadeIn(delay: 500.ms),
                      const SizedBox(height: 16),

                      _buildCalendar(dailyStatus, theme),
                      _buildLegend(theme).animate().fadeIn(delay: 550.ms),

                      // const SizedBox(height: 24),
                      // _buildQuizTeaser(context, theme)
                      //     .animate()
                      //     .fadeIn(delay: 600.ms),
                      // const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(
      Map<DateTime, DailyBrushingStatus> dailyStatus, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.now(),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            if (!selectedDay.isAfter(DateTime.now())) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          onPageChanged: (focusedDay) {
            setState(() => _focusedDay = focusedDay);
          },
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            todayDecoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppTheme.primaryMint,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: theme.textTheme.bodyMedium!.copyWith(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
            ),
            todayTextStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryMint,
            ),
            weekendTextStyle: theme.textTheme.bodyMedium!,
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: theme.textTheme.headlineMedium!,
            leftChevronIcon: const Icon(Icons.chevron_left,
                color: AppTheme.primaryMint),
            rightChevronIcon: const Icon(Icons.chevron_right,
                color: AppTheme.primaryMint),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              if (day.isAfter(DateTime.now())) return null;
              return _buildDayCell(context, day, dailyStatus, theme);
            },
            todayBuilder: (context, day, focusedDay) {
              return _buildDayCell(context, day, dailyStatus, theme,
                  isToday: true);
            },
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildLegend(ThemeData theme) {
    final legends = [
      {'color': AppTheme.calGreen, 'label': 'Both sessions'},
      {'color': AppTheme.calYellow, 'label': 'One session'},
      {'color': AppTheme.calRed, 'label': 'Missed'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: legends.map((l) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: (l['color'] as Color).withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: l['color'] as Color, width: 1.5),
                ),
              ),
              const SizedBox(width: 4),
              Text(l['label'] as String,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontSize: 11)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Widget _buildQuizTeaser(BuildContext context, ThemeData theme) {
  //   return GestureDetector(
  //     onTap: () => context.go(AppRoutes.quiz),
  //     child: Container(
  //       padding: const EdgeInsets.all(20),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [
  //             const Color(0xFF6C63FF).withOpacity(0.15),
  //             const Color(0xFF9B59B6).withOpacity(0.1),
  //           ],
  //         ),
  //         borderRadius: BorderRadius.circular(20),
  //         border: Border.all(
  //             color: const Color(0xFF6C63FF).withOpacity(0.3)),
  //       ),
  //       child: Row(
  //         children: [
  //           const Text('🧠', style: TextStyle(fontSize: 40)),
  //           const SizedBox(width: 16),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text("Today's Dental Quiz",
  //                     style: theme.textTheme.headlineMedium),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                     'Test your dental knowledge & earn 20 points!',
  //                     style: theme.textTheme.bodyMedium),
  //               ],
  //             ),
  //           ),
  //           Icon(Icons.arrow_forward_ios_rounded,
  //               color: const Color(0xFF6C63FF), size: 18),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}
