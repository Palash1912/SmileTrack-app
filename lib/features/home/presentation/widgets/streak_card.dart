import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StreakCard extends StatelessWidget {
  final int currentStreak;
  final int maxStreak;

  const StreakCard({
    super.key,
    required this.currentStreak,
    required this.maxStreak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B35).withOpacity(0.15),
            const Color(0xFFFF8E53).withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _streakStat(
              emoji: '🔥',
              label: 'Current Streak',
              value: currentStreak,
              color: const Color(0xFFFF6B35),
              theme: theme,
            ),
          ),
          Container(
            width: 1.5,
            height: 60,
            color: const Color(0xFFFF6B35).withOpacity(0.2),
          ),
          Expanded(
            child: _streakStat(
              emoji: '🏆',
              label: 'Best Streak',
              value: maxStreak,
              color: AppTheme.accentYellow,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _streakStat({
    required String emoji,
    required String label,
    required int value,
    required Color color,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 4),
              child: Text(
                value == 1 ? 'day' : 'days',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
      ],
    );
  }
}