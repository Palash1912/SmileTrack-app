import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smiletrack/features/brushing/presentation/pages/brushing_log_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/timer/presentation/pages/timer_page.dart';
import '../../features/dental_tips/presentation/pages/dental_tips_page.dart';
import '../../features/community/presentation/pages/community_page.dart';
import '../../features/community/presentation/pages/question_detail_page.dart';
import '../../features/community/data/models/question_model.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/quiz/presentation/pages/quiz_page.dart';
import '../../shared/widgets/main_shell.dart';
import '../constants/app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          final email = extra?['email'];
          if (email == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid OTP request')),
            );
          }

          return OtpPage(email: email);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.timer,
            builder: (context, state) => const TimerPage(),
          ),
          GoRoute(
            path: AppRoutes.brushing,
            builder: (context, state) => const BrushingLogPage(),
          ),
          GoRoute(
            path: AppRoutes.dentalTips,
            builder: (context, state) => const DentalTipsPage(),
          ),
          GoRoute(
            path: AppRoutes.community,
            builder: (context, state) => const CommunityPage(),
            routes: [
              GoRoute(
                path: 'question/:questionId',
                builder: (context, state) {
                  final questionId = state.pathParameters['questionId'] ?? '';
                  final extra = state.extra as Map<String, dynamic>?;
                  final question = extra?['question'] as Question?;

                  if (question == null) {
                    return const Scaffold(
                      body: Center(child: Text('Question not found')),
                    );
                  }

                  return QuestionDetailPage(
                    questionId: questionId,
                    question: question,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: AppRoutes.quiz,
            builder: (context, state) => const QuizPage(),
          ),
        ],
      ),
    ],
  );
});
