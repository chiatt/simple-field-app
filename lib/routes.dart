/// The route configuration.
import 'package:go_router/go_router.dart';
import 'screens/auth.dart';
import 'screens/home.dart';
import 'screens/settings.dart';
import 'screens/map.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'auth',
            builder: (BuildContext context, GoRouterState state) {
              return const AuthScreen();
            },
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'map',
            builder: (context, state) => const MapScreen(),
          ),
        ],
      ),
    ],
  );

  static GoRouter get router => _router;
}
