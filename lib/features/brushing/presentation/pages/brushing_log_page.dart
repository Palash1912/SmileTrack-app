import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../brushing/data/models/brushing_log.dart';
import '../../../timer/presentation/providers/brushing_timer_provider.dart';
import '../providers/brushing_provider.dart';

class BrushingLogPage extends ConsumerStatefulWidget {
  const BrushingLogPage({super.key});

  @override
  ConsumerState<BrushingLogPage> createState() => _BrushingLogPageState();
}

class _BrushingLogPageState extends ConsumerState<BrushingLogPage>
    with SingleTickerProviderStateMixin {
  bool _isLogging = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _logBrushing() async {
    setState(() => _isLogging = true);
    try {
      final timerState = ref.read(brushingTimerProvider);
      final logFn = ref.read(logBrushingProvider);
      await logFn(timerState.elapsed);
      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
  }

  void _showSuccessDialog() {
    final now = DateTime.now();
    final isMorning = now.hour < 12;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final primary = Theme.of(ctx).colorScheme.primary;
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 60))
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 16),
                Text(
                  'Brushed!',
                  style: Theme.of(ctx)
                      .textTheme
                      .displaySmall
                      ?.copyWith(color: primary),
                ),
                const SizedBox(height: 8),
                Text(
                  isMorning
                      ? 'Great morning brush! 🌅\n+10 points earned!'
                      : 'Awesome evening routine! 🌙\n+10 points earned!',
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(brushingTimerProvider.notifier).resetTimer();
                  },
                  child: const Text('Wonderful! 🌟'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLoading = ref.watch(brushingLoadingProvider);
    final timerState = ref.watch(brushingTimerProvider);
    final timerNotifier = ref.read(brushingTimerProvider.notifier);

    // Sync pulse animation with timer running state
    if (timerState.isRunning && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!timerState.isRunning && _pulseController.isAnimating) {
      _pulseController.stop();
    }

    final now = DateTime.now();
    final isMorning = now.hour < 12;
    final isEvening = now.hour > 12;
    final todayStatus = ref.watch(todayStatusProvider);
    final todayStatusValue = todayStatus?.status ?? DayStatus.white;

    final alreadyBrushed =
        (isMorning && (todayStatus?.morningBrushed ?? false)) ||
            (!isMorning && (todayStatus?.eveningBrushed ?? false));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const AppHeader(),
                const SizedBox(height: 16),

                Text(
                  isMorning && todayStatusValue != DayStatus.yellow
                      ? 'Start Morning Brush!'
                      : isEvening && todayStatusValue != DayStatus.green
                          ? 'Complete Evening Brush!'
                          : 'Log Brushing',
                ).animate().fadeIn(),

                Text(
                  '2 minutes for a dazzling smile!',
                  style: theme.textTheme.bodyMedium,
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 40),

                if (alreadyBrushed)
                  _buildAlreadyBrushedCard(theme)
                else ...[
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = timerState.isRunning
                          ? 1.0 + (_pulseController.value * 0.02)
                          : 1.0;
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: CircularPercentIndicator(
                      radius: 130,
                      lineWidth: 16,
                      percent: timerState.progress,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timerState.isCompleted ? '✅' : '🦷',
                            style: const TextStyle(fontSize: 48),
                          ),
                          Text(
                            timerState.isCompleted
                                ? 'Done!'
                                : timerState.timeString,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: timerState.isCompleted ? 28 : 36,
                              fontWeight: FontWeight.w800,
                              color: timerState.isCompleted
                                  ? AppTheme.calGreen
                                  : colorScheme.onSurface,
                            ),
                          ),
                          if (!timerState.isCompleted)
                            Text('remaining',
                                style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      progressColor: timerState.isCompleted
                          ? AppTheme.calGreen
                          : colorScheme.primary,
                      backgroundColor:
                          colorScheme.outline.withOpacity(0.3),
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: false,
                    ),
                  ).animate().scale(
                      duration: 500.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 40),

                  if (!timerState.isCompleted) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: timerState.elapsed > 0
                              ? () => timerNotifier.resetTimer()
                              : null,
                          icon: const Icon(Icons.refresh_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.surface,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: timerState.isRunning
                              ? () => timerNotifier.pauseTimer()
                              : () => timerNotifier.startTimer(),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      colorScheme.primary.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              timerState.isRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: () => timerNotifier.completeTimer(),
                          icon: const Icon(Icons.skip_next_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.surface,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      timerState.isRunning
                          ? 'Brush all surfaces! 🔄'
                          : 'Tap to start your 2-min timer',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            isLoading || _isLogging ? null : _logBrushing,
                        icon: isLoading || _isLogging
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_rounded),
                        label: Text(isLoading || _isLogging
                            ? 'Logging...'
                            : 'Log This Brush! 🦷'),
                      ).animate().scale(
                          duration: 400.ms, curve: Curves.elasticOut),
                    ),
                  ],

                  const SizedBox(height: 32),
                  _buildBrushingTips(theme, isMorning),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadyBrushedCard(ThemeData theme) {
    final isMorning = DateTime.now().hour < 12;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.calGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: AppTheme.calGreen.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          const Text('✅', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            isMorning ? 'Morning Brush Done!' : 'Evening Brush Done!',
            style: theme.textTheme.displaySmall
                ?.copyWith(color: AppTheme.calGreen),
          ),
          const SizedBox(height: 8),
          Text(
            'You already logged this session.\nKeep up the great work! 🌟',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut);
  }

  Widget _buildBrushingTips(ThemeData theme, bool isMorning) {
    final tips = isMorning
        ? [
            '☀️ Brush before breakfast for best results',
            '🦷 Use fluoride toothpaste',
            '⏱️ 2 minutes ensures thorough cleaning',
            '💧 Rinse well with water',
          ]
        : [
            '🌙 Brush at least 30 mins after dinner',
            '🧵 Floss before brushing',
            '💤 Night brushing removes bacteria',
            '🚫 Avoid eating after evening brush',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pro Tips', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 12),
        ...tips.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(e.value.split(' ')[0],
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.value.substring(e.value.indexOf(' ') + 1),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (700 + e.key * 100).ms)),
      ],
    );
  }
}