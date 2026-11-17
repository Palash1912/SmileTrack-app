import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/dental_tip_model.dart';

class FoodSection extends StatelessWidget {
  const FoodSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A – Damaging foods
          const _SectionHeader(
            emoji: '⚠️',
            title: 'Foods That Damage Teeth',
            subtitle: "Why they're harmful & what to do after",
            color: AppTheme.accentCoral,
          ).animate().fadeIn(),
          const SizedBox(height: 10),
          ...DentalTipsData.damagingFoods.asMap().entries.map((e) =>
              _DamagingCard(food: e.value)
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: e.key * 70))),

          const SizedBox(height: 22),

          // B1 – Avoid before morning brush
          const _SectionHeader(
            emoji: '🌅',
            title: 'Avoid Before Morning Brush',
            subtitle: 'These foods compromise your oral hygiene routine',
            color: AppTheme.accentYellow,
          ).animate().fadeIn(),
          const SizedBox(height: 10),
          const _ListCard(
            items: DentalTipsData.avoidBeforeMorningBrush,
            color: AppTheme.accentYellow,
          ).animate().fadeIn(delay: const Duration(milliseconds: 80)),

          const SizedBox(height: 22),

          // B2 – Avoid before evening brush
          const _SectionHeader(
            emoji: '🌙',
            title: 'Avoid Before Evening Brush',
            subtitle: 'Especially harmful overnight when saliva decreases',
            color: Color(0xFF6C63FF),
          ).animate().fadeIn(),
          const SizedBox(height: 10),
          const _ListCard(
            items: DentalTipsData.avoidBeforeEveningBrush,
            color: Color(0xFF6C63FF),
          ).animate().fadeIn(delay: const Duration(milliseconds: 80)),

          const SizedBox(height: 22),

          // C – Strong teeth foods
          const _SectionHeader(
            emoji: '💪',
            title: 'Foods for Strong Teeth & Gums',
            subtitle: 'Nutrition that actively protects and rebuilds enamel',
            color: AppTheme.primaryMint,
          ).animate().fadeIn(),
          const SizedBox(height: 10),
          const _ListCard(
            items: DentalTipsData.strongTeethFoods,
            color: AppTheme.primaryMint,
          ).animate().fadeIn(delay: const Duration(milliseconds: 80)),

          const SizedBox(height: 22),

          // D – After brushing
          const _SectionHeader(
            emoji: '🪥',
            title: 'Avoid 2 Hours After Brushing',
            subtitle:
                "Protect the fluoride film actively strengthening your enamel",
            color: AppTheme.accentBlue,
          ).animate().fadeIn(),
          const SizedBox(height: 10),
          const _ListCard(
            items: DentalTipsData.afterBrushingAvoid,
            color: AppTheme.accentBlue,
          ).animate().fadeIn(delay: const Duration(milliseconds: 80)),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color color;
  const _SectionHeader({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      theme.textTheme.headlineMedium?.copyWith(color: color)),
              Text(subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Damaging Food Card (expandable) ──────────────────────────────────────────

class _DamagingCard extends StatefulWidget {
  final FoodTip food;
  const _DamagingCard({required this.food});

  @override
  State<_DamagingCard> createState() => _DamagingCardState();
}

class _DamagingCardState extends State<_DamagingCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentCoral.withOpacity(0.22)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text(widget.food.emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(widget.food.name,
                          style: theme.textTheme.bodyLarge)),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.accentCoral),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text('Why harmful:',
                      style: theme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.accentCoral, fontSize: 12)),
                  const SizedBox(height: 6),
                  ...widget.food.reasons.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(
                                    color: AppTheme.accentCoral,
                                    fontWeight: FontWeight.bold)),
                            Expanded(
                                child: Text(r,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(height: 1.4))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryMint.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.primaryMint.withOpacity(0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡 ', style: TextStyle(fontSize: 14)),
                        Expanded(
                            child: Text(widget.food.afterCare,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(height: 1.4))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Simple bullet list card ───────────────────────────────────────────────────

class _ListCard extends StatelessWidget {
  final List<String> items;
  final Color color;
  const _ListCard({required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Column(
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(top: 5, right: 10),
                        decoration:
                            BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      Expanded(
                        child: Text(item,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(height: 1.4)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
