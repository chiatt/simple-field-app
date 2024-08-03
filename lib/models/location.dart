import 'package:isar/isar.dart';

part 'location.g.dart';

@collection
class Location {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment
  String? name;
  float? x;
  float? y;
  List<Coordinate>? polyline = [];
}

@embedded
class Coordinate {
  Coordinate([
    this.x,
    this.y,
  ]);

  float? x;
  float? y;
}