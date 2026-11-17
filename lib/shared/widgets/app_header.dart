import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class AppHeader extends ConsumerWidget {
  final bool showBackButton;

  const AppHeader({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final isDark = themeState.isDark;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBackButton)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )
          else
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, secondary],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('🦷', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'smileTrack',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: primary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),

          // ── Right side buttons ────────────────────────────────
          Row(
            children: [
              // Dark mode toggle button
              GestureDetector(
                onTap: () =>
                    ref.read(themeProvider.notifier).toggleDarkMode(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? primary.withOpacity(0.15)
                        : primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primary.withOpacity(0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        key: ValueKey(isDark),
                        color: primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Theme cycle button — palette icon
              GestureDetector(
                onTap: () =>
                    ref.read(themeProvider.notifier).toggleTheme(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.palette_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}