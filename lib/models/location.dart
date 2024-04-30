import 'dart:ffi';

import 'package:isar/isar.dart';

part 'location.g.dart';

@collection
class Location {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment
  String? name;
  float? x;
  float? y;
  List<float>? polyline;
}
