import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/main_menu_drawer.dart';

/// The profile screen
class AuthScreen extends StatelessWidget {
  /// Constructs a [AuthScreen]
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <ElevatedButton>[
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go back to the Home screen'),
              ),
            ],
          ),
        ),
        drawer: const MainMenu());
  }
}
