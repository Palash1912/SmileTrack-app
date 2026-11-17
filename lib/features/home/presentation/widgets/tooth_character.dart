import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../brushing/data/models/brushing_log.dart';

class ToothCharacter extends StatefulWidget {
  final DailyBrushingStatus? todayStatus; // ← changed from DayStatus status

  const ToothCharacter({super.key, required this.todayStatus}); // ← changed

  @override
  State<ToothCharacter> createState() => _ToothCharacterState();
}

class _ToothCharacterState extends State<ToothCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  (String emoji, String title, String message, Color color, Color bgColor)
      get _characterData {
    final hour = DateTime.now().hour;
    final isMorning = hour < 12;
    final status = widget.todayStatus?.status ?? DayStatus.white; // ← derive status

    switch (status) {
      case DayStatus.green:
        return (
          '🦷✨',
          'All Clean! 🎉',
          "You're a brushing superstar!\nKeep smiling! 🌟",
          AppTheme.calGreen,
          AppTheme.calGreen.withOpacity(0.12),
        );

      case DayStatus.yellow:
        if (isMorning) {
          return (
            '🦷☀️',
            'Hello there!',
            "Great job on one session!\nMorning brush time 🌅",
            AppTheme.calYellow,
            AppTheme.calYellow.withOpacity(0.12),
          );
        } else {
          // ← FIX: check which session was actually done
          final eveningDone = widget.todayStatus?.eveningBrushed ?? false;
          if (eveningDone) {
            return (
              '🦷🌙',
              'Hello there!',
              "Evening brush done!\nDon't forget morning tomorrow 🌅",
              AppTheme.calYellow,
              AppTheme.calYellow.withOpacity(0.12),
            );
          } else {
            return (
              '🦷🌙',
              'Hello there!',
              "Don't forget your\nevening brush! 🌙",
              AppTheme.calYellow,
              AppTheme.calYellow.withOpacity(0.12),
            );
          }
        }

      case DayStatus.red:
        if (isMorning) {
          return (
            '🦷☀️',
            'Hello there!',
            "Time for your morning brush!\nStart your day fresh 🌅",
            AppTheme.calRed,
            AppTheme.calRed.withOpacity(0.12),
          );
        } else {
          return (
            '😞🦷',
            'Hello there!',
            "You missed your morning brush.\nDon't skip the evening one! 🌙",
            AppTheme.calRed,
            AppTheme.calRed.withOpacity(0.12),
          );
        }

      case DayStatus.white:
      default:
        if (isMorning) {
          return (
            '🦷☀️',
            'Good morning!',
            "Time to brush!\nStart your day with a smile 😁",
            AppTheme.primaryMint,
            AppTheme.primaryMint.withOpacity(0.12),
          );
        } else {
          return (
            '🦷🌙',
            'Good evening!',
            "Don't forget to brush!\nYour teeth are waiting... 🦷",
            AppTheme.primaryMint,
            AppTheme.primaryMint.withOpacity(0.12),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final (emoji, title, message, color, bgColor) = _characterData;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -6 * _bounceController.value),
                child: child,
              );
            },
            child: Text(emoji, style: const TextStyle(fontSize: 60)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(color: color),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}