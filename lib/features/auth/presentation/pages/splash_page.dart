import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final activeUser = await authRepo.fetchCurrentUser();

      if (mounted) {
        if (activeUser != null) {
          ref.read(currentUserProvider.notifier).state = activeUser;
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.login);
        }
      }
    } catch (_) {
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryMint,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🦷', style: TextStyle(fontSize: 56)),
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            Text(
              'smileTrack',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            )
                .animate()
                .slideY(
                    begin: 0.3,
                    duration: 500.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut)
                .fadeIn(duration: 400.ms, delay: 300.ms),
            const SizedBox(height: 8),
            Text(
              'Your daily smile coach 🌟',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
            ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
            const SizedBox(height: 60),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.5,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 900.ms),
          ],
        ),
      ),
    );
  }
}
