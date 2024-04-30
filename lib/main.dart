// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'routes.dart';

/// The buttons use context.go() to navigate to each destination. On mobile
/// devices, each destination is deep-linkable and on the web, can be navigated
/// to using the address bar.
void main() => runApp(const ReactionTrackerApp());

/// The main app.
class ReactionTrackerApp extends StatelessWidget {
  /// Constructs a [ReactionTrackerApp]
  const ReactionTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        routerConfig: AppRouter.router,
        title: "Simple Field App",
        theme: ThemeData(
          colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Colors.blueGrey, //Main text
              onPrimary: Colors.indigo,
              primaryContainer: Color.fromARGB(255, 68, 163, 240),
              onPrimaryContainer:
                  Color.fromARGB(255, 163, 220, 247), //ListTile text
              // Colors that are not relevant to AppBar in LIGHT mode:
              secondary: Colors.white,
              onSecondary: Colors.red,
              background: Colors.white,
              onBackground: Colors.purple,
              surface: Colors.white,
              onSurface: Colors.teal,
              error: Colors.white,
              onError: Colors.orange),
        ));
  }
}
