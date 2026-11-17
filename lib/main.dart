import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/theme_provider.dart';


import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: SmileTrackApp(),
    ),
  );
}

class SmileTrackApp extends ConsumerWidget {
  const SmileTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(appRouterProvider);

    final theme = themeState.isDark
        ? AppTheme.darkTheme(themeState.type)
        : AppTheme.lightTheme(themeState.type);

    // Status bar & nav bar adapt to dark/light mode
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            themeState.isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
            themeState.isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: 'smileTrack',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
    );
  }
}