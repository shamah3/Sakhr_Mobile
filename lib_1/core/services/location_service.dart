import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  final loc.Location _location = loc.Location();

  /// Requests permission and gets the current user location
  Future<loc.LocationData?> getCurrentLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    // Check if service is enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return null;
    }

    // Check permissions
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) return null;
    }

    try {
      return await _location.getLocation();
    } catch (e) {
      debugPrint("Error getting location: $e");
      return null;
    }
  }

  /// Converts coordinates into a human-readable address string
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      await setLocaleIdentifier("ar");
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Formatting: Street, SubLocality, Locality, Country
        String address = "${place.street != null && place.street!.isNotEmpty ? place.street : ''}"
            "${place.subLocality != null && place.subLocality!.isNotEmpty ? ', ${place.subLocality}' : ''}"
            "${place.locality != null && place.locality!.isNotEmpty ? ', ${place.locality}' : ''}"
            "${place.country != null && place.country!.isNotEmpty ? ', ${place.country}' : ''}";
            
        // Clean up leading commas if street was empty
        if (address.startsWith(',')) address = address.substring(1).trim();
        
        return address.isNotEmpty ? address : "عنوان غير معروف";
      }
    } catch (e) {
      debugPrint("GEOLOCATION ERROR: $e");
      if (e.toString().contains("API key")) {
        debugPrint("HELP: Ensure Geocoding API is enabled and your API Key is correct.");
      } else if (e.toString().contains("network")) {
        debugPrint("HELP: Check your internet connection.");
      }
    }
    return "فشل في تحديد العنوان";
  }
}
