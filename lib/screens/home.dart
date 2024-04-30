import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/main_menu_drawer.dart';

/// Add a stupid comment
/// Add anotheer stupid comment
class HomeScreen extends StatelessWidget {
  /// Constructs a [HomeScreen]
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => context.go('/auth'),
            child: const Text('Go to the auth page'),
          ),
        ],
      ),
    ));
  }
}
