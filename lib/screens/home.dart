import 'package:flutter/material.dart';
import 'package:trackme/isar_service.dart';
import '../components/main_menu_drawer.dart';
import 'package:geobase/geobase.dart';

final isarService = IsarService();

class LocationSummary {
  late String name;
  late double distance;
}

Future<List<LocationSummary>> getTracesFromDb() async {
  var locations = await isarService.getLocations();
  List<LocationSummary> results = [];

  for (var l in locations) {
      List<double> latlngs = [];
      if (l.polyline != null && l.polyline!.isNotEmpty) {
        for (var coord in l.polyline!) {
          latlngs.add(coord.x!.toDouble());
          latlngs.add(coord.x!.toDouble());
        }
        var line = LineString.build(latlngs);
        final forward = WGS84.webMercator.forward;
        var line3857 = line.project(forward);
        final locationSummary = LocationSummary()
          ..name = l.name.toString()
          ..distance = line3857.length2D();
        results.add(locationSummary);
      }
  }
  return results;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                  height: 70,
                  margin: const EdgeInsets.all(2),
                  color: const Color.fromARGB(255, 40, 108, 160),
                  child: Center(
                    child: Text('Date: ${locations[index].name}\nMeters: ${locations[index].distance.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
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