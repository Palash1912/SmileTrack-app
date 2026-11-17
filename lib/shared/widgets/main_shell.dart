import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../features/timer/presentation/providers/brushing_timer_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case AppRoutes.home:
        return 0;
      case AppRoutes.dentalTips:
        return 1;
      case AppRoutes.brushing:
        return 2;
      case AppRoutes.community:
        return 3;
      case AppRoutes.settings:
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _currentIndex(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.4),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  context,
                  0,
                  currentIndex,
                  Icons.home_rounded,
                  Icons.home_outlined,
                  'Home',
                  AppRoutes.home,
                ),
                _navItem(
                  context,
                  1,
                  currentIndex,
                  Icons.menu_book_rounded,
                  Icons.menu_book_outlined,
                  'Tips',
                  AppRoutes.dentalTips,
                ),
                _navTimerCenter(context, ref, currentIndex),
                _navItem(
                  context,
                  3,
                  currentIndex,
                  Icons.people_rounded,
                  Icons.people_outline,
                  'Community',
                  AppRoutes.community,
                ),
                _navItem(
                  context,
                  4,
                  currentIndex,
                  Icons.settings_rounded,
                  Icons.settings_outlined,
                  'Settings',
                  AppRoutes.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    int index,
    int currentIndex,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    String route,
  ) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => context.go(route),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primaryMint.withOpacity(0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                color: isActive
                    ? AppTheme.primaryMint
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Nunito',
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? AppTheme.primaryMint
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navTimerCenter(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
  ) {
    final isActive = currentIndex == 2;
    final timerState = ref.watch(brushingTimerProvider);
    final isRunning = timerState.isRunning;

    return GestureDetector(
      onTap: () => context.go(AppRoutes.brushing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 54,
            height: 38,
            decoration: BoxDecoration(
              gradient: isActive || isRunning
                  ? const LinearGradient(
                      colors: [AppTheme.primaryMint, AppTheme.accentBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        AppTheme.primaryMint.withOpacity(0.18),
                        AppTheme.accentBlue.withOpacity(0.12),
                      ],
                    ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: isActive || isRunning
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryMint.withOpacity(0.5),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                isRunning ? '🪥' : '⏱',
                style: TextStyle(fontSize: isActive ? 24 : 20),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isRunning ? timerState.timeString : 'Timer',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'Nunito',
              fontWeight:
                  isActive || isRunning ? FontWeight.w700 : FontWeight.w500,
              color: isActive || isRunning
                  ? AppTheme.primaryMint
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
            ),
          ),
        ],
      ),
    );
  }
}
