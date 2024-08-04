import 'package:flutter/material.dart';
import 'package:trackme/isar_service.dart';
import '../components/main_menu_drawer.dart';

final isarService = IsarService();

Future<List<String>> getTracesFromDb() async {
  return [for (var l in await isarService.getLocations()) l.name.toString()];
}

class HomeScreen extends StatelessWidget {
  /// Constructs a [HomeScreen]
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracks')),
      body: FutureBuilder(
        future: getTracesFromDb(),
        builder: (context, snapshot) {
        if(snapshot.hasData){
          final locations = snapshot.data;
          return Stack(
            children: [
              ListView.builder(
              itemCount: locations!.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 50,
                  margin: const EdgeInsets.all(2),
                  color: const Color.fromARGB(255, 219, 255, 252),
                  child: Center(
                    child: Text(locations[index],
                      style: const TextStyle(fontSize: 18),
                    )
                  ),
                );
              }
              )
            ],
          );
        } else {
          return const Stack(
            children: [],
          );
        }
      }),
    drawer: const MainMenu());
  }
}
