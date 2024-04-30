import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85, //20.0,
      child: Drawer(
        child: ListView(
          children: <Widget>[
            const SizedBox(
              //height: 120,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 1, 70, 27),
                ),
                child: Text(
                  'Drawer Header',
                  style: TextStyle(
                    color: Color.fromARGB(255, 28, 120, 143),
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.location_on_rounded),
              title: const Text('Map'),
              onTap: () {
                context.go('/map');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insights),
              title: const Text('Settings'),
              onTap: () {
                context.go('/settings');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
