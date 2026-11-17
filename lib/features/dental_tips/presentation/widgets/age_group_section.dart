import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/dental_tip_model.dart';

class AgeGroupSection extends StatelessWidget {
  const AgeGroupSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: DentalTipsData.ageGroups.length,
      itemBuilder: (ctx, i) => _AgeGroupCard(
        tip: DentalTipsData.ageGroups[i],
        colorIndex: i,
      ).animate().fadeIn(delay: Duration(milliseconds: i * 70)).slideY(begin: 0.1),
    );
  }
}

class _AgeGroupCard extends StatefulWidget {
  final AgeGroupTip tip;
  final int colorIndex;
  const _AgeGroupCard({required this.tip, required this.colorIndex});

  @override
  State<_AgeGroupCard> createState() => _AgeGroupCardState();
}

class _AgeGroupCardState extends State<_AgeGroupCard> {
  bool _expanded = false;

  static const List<Color> _colors = [
    AppTheme.primaryMint,
    AppTheme.accentBlue,
    AppTheme.accentYellow,
    AppTheme.accentCoral,
    Color(0xFF9B59B6),
    Color(0xFF3498DB),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colors[widget.colorIndex % _colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.30)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          // ── Header (tap to expand) ──────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.10), color.withOpacity(0.03)],
                ),
                borderRadius: _expanded
                    ? const BorderRadius.vertical(top: Radius.circular(20))
                    : BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.14),
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withOpacity(0.30), width: 2),
                    ),
                    child: Center(
                      child: Text(widget.tip.emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.tip.ageGroup,
                            style: theme.textTheme.headlineMedium?.copyWith(color: color)),
                        Text(widget.tip.ageRange, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 28),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable body ─────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: color.withOpacity(0.20)),
                  _sectionLabel('🦷 Care Tips', color, theme),
                  const SizedBox(height: 8),
                  ...widget.tip.careTips.map((t) => _Bullet(text: t, color: color)),
                  const SizedBox(height: 10),
                  _sectionLabel('🌿 Gum Care', color, theme),
                  const SizedBox(height: 8),
                  ...widget.tip.gumCareTips.map((t) => _Bullet(text: t, color: color)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: theme.textTheme.labelLarge?.copyWith(color: color, fontSize: 13)),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  final Color color;
  const _Bullet({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}