import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../brushing/presentation/providers/brushing_provider.dart';

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage>
    with TickerProviderStateMixin {
  int _targetDuration = 120;
  int _elapsed = 0;
  bool _isRunning = false;
  bool _isCompleted = false;
  bool _isLogging = false; // ← added
  String _selectedSoundtrack = 'none';
  Timer? _timer;

  late AnimationController _toothController;
  late AnimationController _glowController;
  late AnimationController _teethOrbitController;
  late Animation<double> _toothBounce;
  late Animation<double> _glowPulse;

  final List<int> _durationOptions = [60, 90, 120, 150, 180];

  @override
  void initState() {
    super.initState();
    _toothController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _glowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _teethOrbitController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();
    _toothBounce = Tween<double>(begin: 0, end: 8).animate(
        CurvedAnimation(parent: _toothController, curve: Curves.easeInOut));
    _glowPulse = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _toothController.dispose();
    _glowController.dispose();
    _teethOrbitController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed++);
      if (_elapsed >= _targetDuration) _completeTimer();
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _elapsed = 0;
      _isRunning = false;
      _isCompleted = false;
      _isLogging = false; // ← reset logging state too
    });
  }

  void _completeTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isCompleted = true;
    });
    _toothController.stop();
    _showCompletionDialog();
  }

  Future<void> _logBrushing() async {
    BuildContext? dialogCtx;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogCtx = ctx;
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      final logFn = ref.read(logBrushingProvider);
      await logFn(_elapsed);
      if (mounted && dialogCtx != null) Navigator.pop(dialogCtx!);
      _showSuccessSnackbar('Brushing logged! ✅');
    } catch (e) {
      if (mounted && dialogCtx != null) Navigator.pop(dialogCtx!);
      _showErrorSnackbar('Error: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 8),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.calGreen,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showCompletionDialog() {
    final now = DateTime.now();
    final isMorning = now.hour < 12;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final primary = Theme.of(ctx).colorScheme.primary;
        final secondary = Theme.of(ctx).colorScheme.secondary;
        return StatefulBuilder( // ← needed to update button state inside dialog
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withOpacity(0.12),
                      secondary.withOpacity(0.06)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 64))
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 16),
                    Text('Brush Complete!',
                            style: Theme.of(ctx)
                                .textTheme
                                .displaySmall
                                ?.copyWith(color: primary))
                        .animate()
                        .fadeIn(delay: 200.ms),
                    const SizedBox(height: 8),
                    Text(
                      isMorning
                          ? '🌅 Morning session logged!\n+10 points earned!'
                          : '🌙 Evening session logged!\n+10 points earned!',
                      textAlign: TextAlign.center,
                      style: Theme.of(ctx).textTheme.bodyLarge,
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentYellow.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isMorning
                            ? '⚡ Calendar marked Yellow (morning done!)'
                            : '✅ Calendar marked Green (both sessions done!)',
                        style: Theme.of(ctx).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 24),
                    // ← changed: disabled when logging, shows spinner
                    ElevatedButton(
                      onPressed: _isLogging
                          ? null
                          : () async {
                              setDialogState(() {});
                              setState(() => _isLogging = true);
                              await _logBrushing();
                              if (mounted) {
                                Navigator.pop(ctx);
                                _resetTimer();
                              }
                            },
                      child: _isLogging
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Wonderful! 🌟'),
                    ).animate().fadeIn(delay: 500.ms),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String get _timeString {
    final remaining =
        (_targetDuration - _elapsed).clamp(0, _targetDuration);
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress => (_elapsed / _targetDuration).clamp(0.0, 1.0);

  Color get _progressColor {
    if (_isCompleted) return AppTheme.calGreen;
    if (_progress > 0.66) return AppTheme.calGreen;
    if (_progress > 0.33) return AppTheme.accentYellow;
    return AppTheme.accentCoral;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final isMorning = now.hour < 12;
    final todayStatus = ref.watch(todayStatusProvider);
    final alreadyBrushed =
        (isMorning && (todayStatus?.morningBrushed ?? false)) ||
            (!isMorning && (todayStatus?.eveningBrushed ?? false));

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A1628) : const Color(0xFFF0FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const AppHeader(),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isMorning
                          ? [
                              const Color(0xFFFF9A3C),
                              const Color(0xFFFFD166)
                            ]
                          : [
                              const Color(0xFF6C63FF),
                              const Color(0xFF4ECDC4)
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isMorning
                        ? '🌅 Morning Brush Session'
                        : '🌙 Evening Brush Session',
                    style: const TextStyle(
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 14),
                  ),
                ).animate().scale(duration: 400.ms),

                const SizedBox(height: 24),

                if (alreadyBrushed)
                  _buildAlreadyBrushedCard(theme, isMorning)
                else ...[
                  _buildVisualTimer(isDark, colorScheme),
                  const SizedBox(height: 28),

                  if (!_isRunning && !_isCompleted && _elapsed == 0) ...[
                    Text('Select Duration',
                        style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _durationOptions.map((dur) {
                          final isSelected = _targetDuration == dur;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _targetDuration = dur),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 9),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(colors: [
                                        colorScheme.primary,
                                        colorScheme.secondary
                                      ])
                                    : null,
                                color: isSelected
                                    ? null
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outline
                                          .withOpacity(0.5),
                                  width: isSelected ? 0 : 1.5,
                                ),
                              ),
                              child: Text(
                                dur == 60
                                    ? '1 min'
                                    : dur == 90
                                        ? '1.5 min'
                                        : dur == 120
                                            ? '2 min ⭐'
                                            : dur == 150
                                                ? '2.5 min'
                                                : '3 min',
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isSelected
                                      ? Colors.white
                                      : colorScheme.onSurface
                                          .withOpacity(0.7),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text('🎵 Soundtrack',
                        style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AppConstants.timerSoundtracks.map((track) {
                          final isSelected =
                              _selectedSoundtrack == track['value'];
                          return GestureDetector(
                            onTap: () => setState(
                                () => _selectedSoundtrack = track['value']!),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF6C63FF)
                                        .withOpacity(0.15)
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6C63FF)
                                      : colorScheme.outline
                                          .withOpacity(0.5),
                                  width: isSelected ? 2 : 1.5,
                                ),
                              ),
                              child: Text(
                                track['label']!,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: isSelected
                                      ? const Color(0xFF6C63FF)
                                      : colorScheme.onSurface
                                          .withOpacity(0.7),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (!_isCompleted) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ControlBtn(
                          icon: Icons.refresh_rounded,
                          onTap: _elapsed > 0 ? _resetTimer : null,
                          theme: theme,
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: _isRunning ? _pauseTimer : _startTimer,
                          child: AnimatedBuilder(
                            animation: _glowController,
                            builder: (_, child) => Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primary,
                                      colorScheme.secondary
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(
                                        _isRunning
                                            ? _glowPulse.value * 0.6
                                            : 0.3),
                                    blurRadius: _isRunning ? 24 : 14,
                                    spreadRadius: _isRunning ? 4 : 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isRunning
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 42,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        _ControlBtn(
                          icon: Icons.skip_next_rounded,
                          onTap: () {
                            _timer?.cancel();
                            setState(() {
                              _elapsed = _targetDuration;
                              _isCompleted = true;
                            });
                            _showCompletionDialog();
                          },
                          theme: theme,
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 14),
                    Text(
                      _isRunning
                          ? _brushingHint()
                          : (_elapsed > 0
                              ? 'Paused — tap to continue'
                              : 'Tap ▶ to start brushing!'),
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      // ← changed: disabled when logging
                      child: ElevatedButton.icon(
                        onPressed: _isLogging
                            ? null
                            : () async {
                                setState(() => _isLogging = true);
                                await _logBrushing();
                                _resetTimer();
                              },
                        icon: _isLogging
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_rounded),
                        label: const Text('Log This Session 🦷'),
                      ).animate().scale(
                          duration: 400.ms, curve: Curves.elasticOut),
                    ),
                  ],

                  const SizedBox(height: 28),
                  _buildBrushingGuide(theme, colorScheme),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualTimer(bool isDark, ColorScheme colorScheme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _teethOrbitController,
          builder: (_, __) {
            return SizedBox(
              width: 300,
              height: 300,
              child: CustomPaint(
                painter: _OrbitingTeethPainter(
                  progress: _teethOrbitController.value,
                  timerProgress: _progress,
                  isRunning: _isRunning,
                  isDark: isDark,
                  primaryColor: colorScheme.primary,
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _toothController,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, _isRunning ? -_toothBounce.value : 0),
            child: child,
          ),
          child: CircularPercentIndicator(
            radius: 100,
            lineWidth: 14,
            percent: _progress,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_isCompleted ? '✅' : _toothEmoji(),
                    style: const TextStyle(fontSize: 44)),
                const SizedBox(height: 4),
                Text(
                  _isCompleted ? 'Done!' : _timeString,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w800,
                    fontSize: _isCompleted ? 26 : 34,
                    color: _progressColor,
                  ),
                ),
                if (!_isCompleted)
                  Text(
                    _progress > 0
                        ? '${(_progress * 100).round()}%'
                        : 'ready',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: _progressColor.withOpacity(0.8)),
                  ),
              ],
            ),
            progressColor: _progressColor,
            backgroundColor: _progressColor.withOpacity(0.12),
            circularStrokeCap: CircularStrokeCap.round,
            animation: false,
          ),
        ),
      ],
    );
  }

  String _toothEmoji() {
    if (_progress == 0) return '🦷';
    if (_progress < 0.33) return '🪥';
    if (_progress < 0.66) return '✨';
    return '😁';
  }

  String _brushingHint() {
    final hints = [
      'Upper outer surfaces — gentle circles! 🔄',
      'Upper inner surfaces — tilt the brush! ↗',
      'Lower outer surfaces — small circles! ⭕',
      'Lower inner surfaces — up and down! ↕',
      'Chewing surfaces — back and forth! ↔',
      'Don\'t forget your tongue! 👅',
    ];
    final idx = ((_elapsed / _targetDuration) * hints.length)
        .floor()
        .clamp(0, hints.length - 1);
    return hints[idx];
  }

  Widget _buildAlreadyBrushedCard(ThemeData theme, bool isMorning) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppTheme.calGreen.withOpacity(0.12),
          theme.colorScheme.secondary.withOpacity(0.06)
        ]),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: AppTheme.calGreen.withOpacity(0.35), width: 2),
      ),
      child: Column(
        children: [
          const Text('✅', style: TextStyle(fontSize: 64))
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
              isMorning ? 'Morning Brush Done!' : 'Evening Brush Done!',
              style: theme.textTheme.displaySmall
                  ?.copyWith(color: AppTheme.calGreen)),
          const SizedBox(height: 8),
          Text('You already logged this session.\nKeep up the great work! 🌟',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium),
        ],
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut);
  }

  Widget _buildBrushingGuide(ThemeData theme, ColorScheme colorScheme) {
    final sections = [
      ('😁', 'Upper Front', '30s'),
      ('🦷', 'Lower Front', '30s'),
      ('🦴', 'Upper Back', '30s'),
      ('🔙', 'Lower Back', '30s'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('2-Minute Guide', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 10),
        Row(
          children: sections.map((s) {
            final sectionProgress = _elapsed / _targetDuration;
            final idx = sections.indexOf(s);
            final sectionStart = idx / sections.length;
            final sectionEnd = (idx + 1) / sections.length;
            final isDone = sectionProgress >= sectionEnd;
            final isActive = sectionProgress >= sectionStart &&
                sectionProgress < sectionEnd;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isDone
                      ? AppTheme.calGreen.withOpacity(0.15)
                      : isActive
                          ? colorScheme.primary.withOpacity(0.12)
                          : colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDone
                        ? AppTheme.calGreen.withOpacity(0.4)
                        : isActive
                            ? colorScheme.primary.withOpacity(0.5)
                            : colorScheme.outline.withOpacity(0.3),
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(isDone ? '✅' : s.$1,
                        style: TextStyle(fontSize: isActive ? 20 : 16)),
                    const SizedBox(height: 4),
                    Text(s.$2,
                        style: TextStyle(
                            fontSize: 9,
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.w700,
                            color: isDone
                                ? AppTheme.calGreen
                                : isActive
                                    ? colorScheme.primary
                                    : colorScheme.onSurface
                                        .withOpacity(0.5))),
                    Text(s.$3,
                        style: TextStyle(
                            fontSize: 9,
                            fontFamily: 'Nunito',
                            color:
                                colorScheme.onSurface.withOpacity(0.4))),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final ThemeData theme;
  const _ControlBtn(
      {required this.icon, required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: onTap != null
                ? theme.colorScheme.surface
                : theme.colorScheme.surface.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(
                color: theme.colorScheme.outline
                    .withOpacity(onTap != null ? 0.6 : 0.2)),
          ),
          child: Icon(icon,
              size: 24,
              color: onTap != null
                  ? theme.colorScheme.onSurface.withOpacity(0.7)
                  : theme.colorScheme.onSurface.withOpacity(0.25)),
        ),
      );
}

class _OrbitingTeethPainter extends CustomPainter {
  final double progress;
  final double timerProgress;
  final bool isRunning;
  final bool isDark;
  final Color primaryColor;

  _OrbitingTeethPainter({
    required this.progress,
    required this.timerProgress,
    required this.isRunning,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    const count = 8;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i / count) + (progress * 2 * pi);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      final filled = (i / count) <= timerProgress;
      paint.color = filled
          ? primaryColor.withOpacity(isDark ? 0.7 : 0.85)
          : (isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.18));

      canvas.drawCircle(Offset(x, y), 10, paint);

      final textPainter = TextPainter(
        text: TextSpan(
            text: filled ? '🦷' : '🩶',
            style: const TextStyle(fontSize: 14)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 7, y - 7));
    }
  }

  @override
  bool shouldRepaint(_OrbitingTeethPainter old) =>
      old.progress != progress ||
      old.timerProgress != timerProgress ||
      old.isRunning != isRunning ||
      old.primaryColor != primaryColor;
}