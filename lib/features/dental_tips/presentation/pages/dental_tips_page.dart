import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/widgets/app_header.dart';
import '../widgets/age_group_section.dart';
import '../widgets/food_section.dart';
import '../widgets/technique_section.dart';
import '../widgets/faq_section.dart';

class DentalTipsPage extends StatefulWidget {
  const DentalTipsPage({super.key});

  @override
  State<DentalTipsPage> createState() => _DentalTipsPageState();
}

class _DentalTipsPageState extends State<DentalTipsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    ('👶', 'Age Care'),
    ('🥦', 'Food'),
    ('🦷', 'Technique'),
    ('❓', 'FAQ'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppHeader(),
                  Text('Dental Tips', style: theme.textTheme.displaySmall)
                      .animate().fadeIn(),
                  Text('Evidence-based dental knowledge 🔬',
                          style: theme.textTheme.bodyMedium)
                      .animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 14),
                ],
              ),
            ),

            // ✅ Tab bar uses theme primary gradient for active indicator
            Container(
              height: 46,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: colorScheme.outline.withOpacity(0.4)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor:
                    colorScheme.onSurface.withOpacity(0.45),
                labelStyle: const TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w700,
                    fontSize: 11),
                unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 11),
                tabs: _tabs
                    .map((t) => Tab(text: '${t.$1} ${t.$2}'))
                    .toList(),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  AgeGroupSection(),
                  FoodSection(),
                  TechniqueSection(),
                  FaqSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
