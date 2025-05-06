import 'package:flutter/material.dart';
import 'package:weather_app/SettingsPage.dart';
import 'package:weather_app/geocoding_service.dart';

class LocationProvider with ChangeNotifier {
  final List<Location> _locations = [];

  List<Location> get locations => List.unmodifiable(_locations);

  Future<void> addLocation(String city, BuildContext context) async {
    try {
      final location = await GeocodingService.getCoordinates(city);
      final validatedCityName = await GeocodingService.getCityName(
        location.latitude,
        location.longitude,
      );

      _locations.add(Location(name: validatedCityName, isFavorite: false));
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$validatedCityName added!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid location: $city')),
      );
    }
  }
}
