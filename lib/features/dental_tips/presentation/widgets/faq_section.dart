import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/dental_tip_model.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      children: [
        // Header banner
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color(0xFF6C63FF).withOpacity(0.10),
              AppTheme.primaryMint.withOpacity(0.05),
            ]),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: const Color(0xFF6C63FF).withOpacity(0.22)),
          ),
          child: Row(
            children: [
              const Text('❓', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequently Asked Questions',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(color: const Color(0xFF6C63FF)),
                    ),
                    Text(
                      'Evidence-based answers from dental research',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(),

        // FAQ tiles
        ...DentalTipsData.faqs.asMap().entries.map((e) => _FaqTile(faq: e.value)
            .animate()
            .fadeIn(delay: Duration(milliseconds: e.key * 55))
            .slideY(begin: 0.1)),

        const SizedBox(height: 80),
      ],
    );
  }
}

// ── Individual FAQ tile ───────────────────────────────────────────────────────

class _FaqTile extends StatefulWidget {
  final FaqItem faq;
  const _FaqTile({required this.faq});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _expanded
              ? AppTheme.primaryMint.withOpacity(0.45)
              : theme.colorScheme.outline.withOpacity(0.38),
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (v) => setState(() => _expanded = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  (_expanded ? AppTheme.primaryMint : theme.colorScheme.outline)
                      .withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _expanded ? Icons.remove_rounded : Icons.add_rounded,
              size: 16,
              color: _expanded
                  ? AppTheme.primaryMint
                  : theme.colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
          title: Text(
            widget.faq.question,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: _expanded ? AppTheme.primaryMint : null,
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryMint.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppTheme.primaryMint.withOpacity(0.18)),
              ),
              child: Text(
                widget.faq.answer,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
