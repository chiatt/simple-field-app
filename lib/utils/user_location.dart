import 'package:location/location.dart';

class UserLocation {
  Future<LocationData?> getUserLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;
    serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      print('sorry no permission - requesting perm');
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('no permission');
        return null;
      }
    }
    print('waiting for location');
    locationData = await location.getLocation();
    print('got location');
    print(locationData);
    return locationData;
  }
}
