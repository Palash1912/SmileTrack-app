import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/dental_tip_model.dart';

class TechniqueSection extends StatelessWidget {
  const TechniqueSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2-minute rule banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppTheme.primaryMint.withOpacity(0.13),
                AppTheme.accentBlue.withOpacity(0.07),
              ]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primaryMint.withOpacity(0.28)),
            ),
            child: Row(
              children: [
                const Text('⏱', style: TextStyle(fontSize: 34)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('2-Minute Rule',
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(color: AppTheme.primaryMint)),
                      Text(
                        '30 sec per jaw quadrant × 4 sections = 2 min total',
                        style:
                            theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 18),

          Text('Brushing Techniques', style: theme.textTheme.headlineLarge)
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 80)),
          Text('Step-by-step guide for every tooth surface',
                  style: theme.textTheme.bodyMedium)
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 120)),
          const SizedBox(height: 10),

          ...DentalTipsData.techniques.asMap().entries.map((e) =>
              _TechniqueCard(technique: e.value, colorIndex: e.key)
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 180 + e.key * 70))),

          const SizedBox(height: 18),

          Text('Brush Type Guide', style: theme.textTheme.headlineLarge)
              .animate()
              .fadeIn(),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: const _BrushCard(
                  type: 'Soft Bristle ✅',
                  recommended: true,
                  info: DentalTipsData.softBrushInfo,
                  color: AppTheme.calGreen,
                ).animate().fadeIn(delay: const Duration(milliseconds: 80)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: const _BrushCard(
                  type: 'Hard Bristle ⚠️',
                  recommended: false,
                  info: DentalTipsData.hardBrushInfo,
                  color: AppTheme.accentCoral,
                ).animate().fadeIn(delay: const Duration(milliseconds: 160)),
              ),
            ],
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ── Technique Card (expandable) ───────────────────────────────────────────────

class _TechniqueCard extends StatefulWidget {
  final BrushingTechnique technique;
  final int colorIndex;
  const _TechniqueCard({required this.technique, required this.colorIndex});

  @override
  State<_TechniqueCard> createState() => _TechniqueCardState();
}

class _TechniqueCardState extends State<_TechniqueCard> {
  bool _expanded = false;

  static const List<Color> _colors = [
    AppTheme.primaryMint,
    AppTheme.accentBlue,
    AppTheme.accentYellow,
    AppTheme.accentCoral,
    Color(0xFF9B59B6),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colors[widget.colorIndex % _colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.12), shape: BoxShape.circle),
                    child: Center(
                        child: Text(widget.technique.emoji,
                            style: const TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.technique.title,
                            style: theme.textTheme.bodyLarge),
                        Text(
                          '${widget.technique.durationSeconds}s · ${widget.technique.area}',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontSize: 11, color: color),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child:
                        Icon(Icons.keyboard_arrow_down_rounded, color: color),
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
                  Divider(color: color.withOpacity(0.20)),
                  ...widget.technique.steps.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    color: color, shape: BoxShape.circle),
                                child: Center(
                                  child: Text(
                                    '${e.key + 1}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Sora',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(e.value,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(height: 1.45)),
                              ),
                            ],
                          ),
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

// ── Brush Type Card (tap to expand) ──────────────────────────────────────────

class _BrushCard extends StatefulWidget {
  final String type, info;
  final bool recommended;
  final Color color;
  const _BrushCard({
    required this.type,
    required this.recommended,
    required this.info,
    required this.color,
  });

  @override
  State<_BrushCard> createState() => _BrushCardState();
}

class _BrushCardState extends State<_BrushCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.color.withOpacity(0.28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.type,
                style:
                    theme.textTheme.bodyLarge?.copyWith(color: widget.color)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: widget.recommended
                    ? widget.color
                    : widget.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                widget.recommended ? 'ADA Recommended' : 'Use with Caution',
                style: TextStyle(
                  color: widget.recommended ? Colors.white : widget.color,
                  fontSize: 10,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 280),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(widget.info,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontSize: 11, height: 1.45)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _expanded ? 'Collapse ↑' : 'Read more ↓',
              style: TextStyle(
                  fontSize: 10,
                  color: widget.color,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
