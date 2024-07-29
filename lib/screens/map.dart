import 'dart:ffi';
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

  LatLng? tappedCoords;
  Point<double>? tappedPoint;
  bool collectingLocation = false;
  Location location = Location();
  late StreamSubscription<LocationData> locationSubscription;

  Future<List<Marker>> getMarkersFromDb() async {
    var locations = await isarService.getLocations();
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
    return markers;
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance
        .addPostFrameCallback((_) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tap/click to set coordinate')),
            ));
  }

  createLocation() async {
      var userName = users[Random().nextInt(users.length)];
      var userLoc = await userLocation.getUserLocation();
      final newLocation = db.Location()
        ..name = userName
        ..x = userLoc?.longitude
        ..y = userLoc?.latitude;
      isarService.addNewLocation(newLocation);
      setState(() => tappedPoint = null);
      setState(() => collectingLocation = !collectingLocation);
  }

  recordTrack() async {
      bool serviceEnabled;
      serviceEnabled = await location.serviceEnabled();
      location.enableBackgroundMode(enable: true);

      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return null;
        }
      }
      collectingLocation = !collectingLocation;
      var userName = users[Random().nextInt(users.length)];
      location.changeSettings(
          accuracy: LocationAccuracy.high,
          interval: 100000, 
          distanceFilter: 1
      );
      locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
        print(currentLocation.longitude);
        final newLocation = db.Location()
          ..name = userName
          ..x = currentLocation.longitude
          ..y = currentLocation.latitude;
        if (collectingLocation) {
          isarService.addNewLocation(newLocation);
        }
      });
      print(collectingLocation);
      if (collectingLocation == false) {
        print('cancelling');
        locationSubscription.pause();
      } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Map')),
        floatingActionButton: FloatingActionButton(
            onPressed: recordTrack,
            child: const Icon(Icons.add)),
        body: FutureBuilder(
            future: getMarkersFromDb(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                var markers = snapshot.data;
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
                        MarkerLayer(markers: markers!),
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
        drawer: const MainMenu());
  }
}
