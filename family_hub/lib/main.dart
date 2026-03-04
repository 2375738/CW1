import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'screens/calendar_screen.dart';
import 'screens/family_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/map_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/privacy_security_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/sos_screen.dart';
import 'screens/tasks_screen.dart';
import 'widgets/scaffold_shell.dart';
import 'providers/family_provider.dart';
import 'theme/app_theme.dart';

final FamilyProvider _familyProvider = FamilyProvider();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FamilyProvider>.value(value: _familyProvider),
      ],
      child: const FamilyHubApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/login',
  refreshListenable: _familyProvider,
  redirect: (context, state) {
    if (!_familyProvider.isInitialized) {
      return null;
    }
    final isLoggedIn = _familyProvider.isLoggedIn;
    final isLoggingIn = state.uri.toString().startsWith('/login');

    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }
    if (isLoggedIn && isLoggingIn) {
      return '/';
    }
    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const TasksScreen(),
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: '/sos',
          builder: (context, state) => const SosScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/family',
          builder: (context, state) => const FamilyScreen(),
        ),
        GoRoute(
          path: '/settings/notifications',
          builder: (context, state) => const NotificationSettingsScreen(),
        ),
        GoRoute(
          path: '/settings/privacy',
          builder: (context, state) => const PrivacySecurityScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);

class FamilyHubApp extends StatelessWidget {
  const FamilyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FamilyHub',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light, 
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
