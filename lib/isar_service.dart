// ignore_for_file: avoid_print

import 'dart:async';

import 'package:trackme/models/location.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<List<Location>> getLocations() async {
    final isar = await db;
    // IsarCollection<Location> locations = isar.location;
    IsarCollection<Location> locationCollection = isar.collection<Location>();
    final location = locationCollection.where().findAll();
    return location;
  }

  Future<void> addNewLocation(Location newLocation) async {
    final isar = await db;

    isar.writeTxnSync<int>(() => isar.locations.putSync(newLocation));
  }

  Future<void> updateLocation(int id, Location updatedLocation) async {
    final isar = await db;

    await isar.writeTxn(() async {
      final contactToUpdate = await isar.locations.get(id);

      if (contactToUpdate != null) {
        await isar.locations.put(updatedLocation);
      } else {
        print('Location with ID not found.');
      }
    });
  }

  Future<void> deleteLocation(int id) async {
    final isar = await db;

    await isar.writeTxn(() async {
      final success = await isar.locations.delete(id);
      print('Location deleted: $success');
    });
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open(
        [LocationSchema],
        directory: dir.path,
        inspector: true,
      );

      return isar;
    }

    return Future.value(Isar.getInstance());
  }
}
