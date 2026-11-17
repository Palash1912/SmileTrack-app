import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/quiz_model.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../../../core/services/points_service.dart';
import '../../../../shared/providers/auth_provider.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository();
});

final pointsServiceProvider = Provider<PointsService>((ref) {
  return PointsService();
});

final dailyQuizProvider = FutureProvider.autoDispose<QuizQuestion>((ref) async {
  final repo = ref.read(quizRepositoryProvider);
  return repo.getDailyQuiz();
});

final todayAttemptProvider = FutureProvider.autoDispose<QuizAttempt?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final repo = ref.read(quizRepositoryProvider);
  return repo.getTodayAttempt(userId: user.uid);
});

final selectedOptionProvider = StateProvider<int?>((ref) => null);

final quizSubmitProvider = StateProvider<bool>((ref) => false);

// ✅ NEW: Provider to refresh user data after quiz submission
final userDataRefreshProvider = FutureProvider.autoDispose<void>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;
  
  // This will trigger a refresh of currentUserProvider
  ref.invalidate(currentUserProvider);
});
