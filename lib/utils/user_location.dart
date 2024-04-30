import 'package:location/location.dart';

class UserLocation {
  Future<LocationData?> getUserLocation() async {
    Location location = Location();

    print('got a location');

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;
    print('awaaiting service');
    serviceEnabled = await location.serviceEnabled();
    print('service??');

    if (!serviceEnabled) {
      print('reequesting service');
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('no service available');
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
    print('did you print anything??');

    return locationData;
  }
}
