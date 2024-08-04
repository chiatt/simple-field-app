import 'dart:async';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:trackme/components/main_menu_drawer.dart';
import 'package:trackme/isar_service.dart';
import 'package:trackme/models/location.dart' as db;
import 'package:trackme/tile_providers.dart';
import 'package:trackme/utils/user_location.dart';
import 'dart:math';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const double pointSize = 65;

  final mapController = MapController();
  final isarService = IsarService();
  final userLocation = UserLocation();
  final users = [
    "Richard Matheson",
    "Jerome Bixby",
    "Rod Serling",
    "Charles Beaumont",
    "Ray Bradbury"
  ];
  var locations = List<Location>;
  
  // var locationName = users[Random().nextInt(users.length)];
  final locationName = DateTime.now().toString();

  LatLng? tappedCoords;
  Point<double>? tappedPoint;
  bool collectingLocation = false;
  Location location = Location();
  late StreamSubscription<LocationData> locationSubscription;

  Future<(List<Marker>, List<Polyline>)> getMarkersFromDb() async {
    var locations = await isarService.getLocations();
    List<Polyline> polylines = [];
    var markers = [
      for (var location in locations)
        Marker(
          point: LatLng(location.y!, location.x!),
          width: pointSize,
          height: pointSize,
          child: const Icon(
            Icons.location_on_rounded,
            size: 36,
            color: Color.fromARGB(255, 179, 30, 20),
          ),
        )
    ];
    for (final location in locations) {
        if (location.polyline != null && location.polyline!.isNotEmpty) {
          List<LatLng> latlngs = [];
          for (var coord in location.polyline!) {
            latlngs.add(LatLng(coord.y!.toDouble(), coord.x!.toDouble()));
          }
          polylines.add(          
            Polyline(
            points: latlngs,
            color: Colors.blue
          ));
        }
    }
    return (markers, polylines);
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance
        .addPostFrameCallback((_) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tap/click to set coordinate')),
            ));
  }

  Future<void> updateOrCreateLocation(String name) async {
      var existingLocation = await isarService.getLocationByName(name);
      var userLoc = await userLocation.getUserLocation();
      if (existingLocation == null) {
        final newLocation = db.Location()
          ..name = name
          ..x = userLoc?.longitude
          ..y = userLoc?.latitude;
        isarService.addNewLocation(newLocation);
      } else {
        existingLocation.x = userLoc?.longitude;
        existingLocation.y = userLoc?.latitude;
        await isarService.updateLocation(existingLocation.id, existingLocation);
      }
      setState(() => tappedPoint = null);
  }
  List<db.Coordinate> coordinates = [];
  recordTrack() async {
      setState(() => collectingLocation = !collectingLocation);
      bool serviceEnabled;
      serviceEnabled = await location.serviceEnabled();
      location.enableBackgroundMode(enable: true);

      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return null;
        }
      }

      location.changeSettings(
          accuracy: LocationAccuracy.high,
          interval: 100000, 
          distanceFilter: 1
      );

      print(locationName);
      if (collectingLocation) {
        await updateOrCreateLocation(locationName);
        locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
          if (collectingLocation) {
            print('adding coordinates');
            final coordinate = db.Coordinate()
              ..x = currentLocation.longitude
              ..y = currentLocation.latitude;
            coordinates.add(coordinate);
          }
        });
      } else {
        final startLocation = await isarService.getLocationByName(locationName);
        if (startLocation != null) {
          startLocation.polyline = coordinates;
          await isarService.updateLocation(startLocation.id, startLocation);
        } else {
          print("Could not find $locationName");
        }
        coordinates = [];
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Map')),
        floatingActionButton: FloatingActionButton(
            onPressed: recordTrack,
            backgroundColor: collectingLocation ? Colors.green : Colors.blue,
            child: const Icon(Icons.add)),
        body: FutureBuilder(
            future: getMarkersFromDb(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                var mapData = snapshot.data;
                return Stack(
                  children: [
                    FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(36.973, -121.9475),
                        initialZoom: 11,
                        interactionOptions: const InteractionOptions(
                          flags: ~InteractiveFlag.doubleTapZoom,
                        ),
                        onTap: (_, latLng) {
                          final point = mapController.camera
                              .latLngToScreenPoint(tappedCoords = latLng);
                          setState(() => tappedPoint = Point(point.x, point.y));
                        },
                      ),
                      children: [
                        landscapeTileLayer,
                        PolylineLayer(polylines: mapData!.$2),
                        MarkerLayer(markers: mapData.$1),
                        CurrentLocationLayer(),
                        if (tappedCoords != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: pointSize,
                                height: pointSize,
                                point: tappedCoords!,
                                child: const Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                      ],
                    ),
                    if (tappedPoint != null)
                      Positioned(
                        left: tappedPoint!.x - 60 / 2,
                        top: tappedPoint!.y - 60 / 2,
                        child: const IgnorePointer(
                          child: Icon(
                            Icons.center_focus_strong_outlined,
                            color: Colors.black,
                            size: 60,
                          ),
                        ),
                      )
                  ],
                );
              } else {
                return const CircularProgressIndicator();
              }
            }),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: <Widget>[
              IconButton(
                tooltip: 'Open navigation menu',
                icon: const Icon(Icons.home),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'Download',
                icon: const Icon(Icons.download),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'Open navigation menu',
                icon: const Icon(Icons.menu),
                onPressed: () {},
              ),
            ],
          ),
        ),
        drawer: const MainMenu());
  }
}
