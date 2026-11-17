import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../data/models/quiz_model.dart';
import '../../data/repositories/quiz_repository.dart';
import '../providers/quiz_provider.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({super.key});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  int? _selectedOption;
  bool _submitted = false;

  Future<void> _submitAnswer(QuizQuestion question) async {
    if (_selectedOption == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _submitted = true);

    final repo = ref.read(quizRepositoryProvider);
    final pointsEarned = _selectedOption == question.correctIndex ? 20 : 5;
    
    await repo.saveAttempt(
      userId: user.uid,
      isCorrect: _selectedOption == question.correctIndex,
      selectedIndex: _selectedOption!,
    );

    // ✅ Update user in memory with new points
    final updatedUser = user.copyWith(
      totalPoints: user.totalPoints + pointsEarned,
    );
    
    ref.read(currentUserProvider.notifier).setUser(updatedUser);
    print('✅ User points updated in memory: ${updatedUser.totalPoints}');
    
    // Reload attempt
    ref.invalidate(todayAttemptProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quizAsync = ref.watch(dailyQuizProvider);
    final attemptAsync = ref.watch(todayAttemptProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const AppHeader(),
              Expanded(
                child: attemptAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryMint),
                  ),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (attempt) {
                    if (attempt != null) {
                      return _buildAlreadyAttempted(attempt, theme);
                    }
                    return quizAsync.when(
                      loading: () => _buildLoading(theme),
                      error: (e, _) => _buildError(theme),
                      data: (question) => _buildQuiz(question, theme),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🧠', style: TextStyle(fontSize: 60))
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms),
        const SizedBox(height: 20),
        Text('Generating your daily quiz...', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        const CircularProgressIndicator(color: AppTheme.primaryMint),
      ],
    );
  }

  Widget _buildError(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('😕', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 16),
        Text("Couldn't load quiz", style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Check your connection and try again', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => ref.invalidate(dailyQuizProvider),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildAlreadyAttempted(QuizAttempt attempt, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(attempt.isCorrect ? '🎉' : '💪', style: const TextStyle(fontSize: 80))
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text(
          attempt.isCorrect ? 'Correct Answer!' : "Better luck tomorrow!",
          style: theme.textTheme.displaySmall?.copyWith(
            color: attempt.isCorrect ? AppTheme.calGreen : AppTheme.accentCoral,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        Text(
          attempt.isCorrect
              ? "Brilliant! You're a dental genius! 🦷✨\n+${attempt.pointsEarned} points earned!"
              : "Don't worry, it happens sometimes.\nYou'll get it tomorrow! 💙",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryMint.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryMint.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Text('📅', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text('Come back tomorrow for a new quiz!', style: theme.textTheme.bodyLarge),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildQuiz(QuizQuestion question, ThemeData theme) {
    final isCorrect = _submitted && _selectedOption == question.correctIndex;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Header
          Center(
            child: Column(
              children: [
                const Text('🧠', style: TextStyle(fontSize: 52))
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Today's Dental Quiz",
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Text(
              question.question,
              style: theme.textTheme.headlineMedium?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 24),

          // Options
          ...question.options.asMap().entries.map((entry) {
            final i = entry.key;
            final option = entry.value;
            final isSelected = _selectedOption == i;
            final isCorrectOption = i == question.correctIndex;

            Color borderColor = theme.colorScheme.outline;
            Color bgColor = theme.colorScheme.surface;
            Widget? trailing;

            if (_submitted) {
              if (isCorrectOption) {
                borderColor = AppTheme.calGreen;
                bgColor = AppTheme.calGreen.withOpacity(0.1);
                trailing = const Icon(Icons.check_circle_rounded, color: AppTheme.calGreen);
              } else if (isSelected && !isCorrectOption) {
                borderColor = AppTheme.accentCoral;
                bgColor = AppTheme.accentCoral.withOpacity(0.1);
                trailing = const Icon(Icons.cancel_rounded, color: AppTheme.accentCoral);
              }
            } else if (isSelected) {
              borderColor = AppTheme.primaryMint;
              bgColor = AppTheme.primaryMint.withOpacity(0.1);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: _submitted ? null : () => setState(() => _selectedOption = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: isSelected || _submitted ? 2 : 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryMint : borderColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            ['A', 'B', 'C', 'D'][i],
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Text(option, style: theme.textTheme.bodyLarge)),
                      if (trailing != null) trailing,
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (400 + i * 100).ms).slideX(begin: 0.1),
            );
          }),

          const SizedBox(height: 8),

          // Result message
          if (_submitted)
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isCorrect
                    ? AppTheme.calGreen.withOpacity(0.1)
                    : AppTheme.accentCoral.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCorrect ? AppTheme.calGreen : AppTheme.accentCoral,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    isCorrect ? '🎉 Brilliant!' : "😊 Don't worry!",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: isCorrect ? AppTheme.calGreen : AppTheme.accentCoral,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCorrect
                        ? 'That\'s correct! You\'re a dental genius!\n+20 points added! ⭐'
                        : "Don't worry, it happens sometimes.\nHere's what you should know:",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (!isCorrect) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '💡 ${question.funFact}',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.2),

          if (!_submitted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedOption == null
                    ? null
                    : () => _submitAnswer(question),
                child: const Text('Submit Answer'),
              ),
            ).animate().fadeIn(delay: 700.ms),

          if (_submitted && isCorrect)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentYellow.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(question.funFact, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
