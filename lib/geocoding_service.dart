import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class GeocodingService {
  static const String baseUrl = 'https://nominatim.openstreetmap.org';

  /// Request and check location permissions
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable them in settings.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Get coordinates from city name
  static Future<GeocodingResponse> getCoordinates(String cityName) async {
    final url = Uri.parse('$baseUrl/search?q=$cityName&format=json&limit=1');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'User-Agent': 'WeatherApp/1.0',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) {
          throw Exception('City not found');
        }
        return GeocodingResponse.fromJson(data[0]);
      } else {
        throw Exception('Failed to get coordinates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to geocoding service: $e');
    }
  }

  /// Get city name from coordinates
  static Future<String> getCityName(double latitude, double longitude) async {
    final url = Uri.parse(
        '$baseUrl/reverse?lat=$latitude&lon=$longitude&format=json&addressdetails=1');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'User-Agent': 'WeatherApp/1.0',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>;
        return address['city'] ??
            address['town'] ??
            address['village'] ??
            address['suburb'] ??
            'Unknown Location';
      } else {
        throw Exception('Failed to get city name: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get city name: $e');
    }
  }
}

class GeocodingResponse {
  final double latitude;
  final double longitude;
  final String displayName;

  GeocodingResponse({
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });

  factory GeocodingResponse.fromJson(Map<String, dynamic> json) {
    return GeocodingResponse(
      latitude: double.parse(json['lat']),
      longitude: double.parse(json['lon']),
      displayName: json['display_name'] ?? 'Unknown Location',
    );
  }
}
class ReverseGeocodingResponse {
  final String displayName;
  final String? city;
  final String? town;
  final String? village;
  final String? locality;
  final String? state;
  final String? country;

  ReverseGeocodingResponse({
    required this.displayName,
    this.city,
    this.town,
    this.village,
    this.locality,
    this.state,
    this.country,
  });

  factory ReverseGeocodingResponse.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>;
    return ReverseGeocodingResponse(
      displayName: json['display_name'] ?? 'Unknown Location',
      city: address['city'],
      town: address['town'],
      village: address['village'],
      locality: address['locality'],
      state: address['state'],
      country: address['country'],
    );
  }

  String getPrimaryLocationName() {
    return city ?? town ?? village ?? locality ?? 'Unknown City';
  }
}