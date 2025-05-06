
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:weather_app/daily_forecast.dart';
import 'package:weather_app/geocoding_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Manage Locations',style:TextStyle(fontSize: 16)),
            leading: const Icon(Icons.location_city),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageLocationsPage(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Daily Forecast',style:TextStyle(fontSize: 16)),
            leading: const Icon(Icons.cloud),
            onTap: () {Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DailyForecast(),
              ),
            );
            },
          ),
        ],
      ),
    );
  }
}

class ManageLocationsPage extends StatefulWidget {
  const ManageLocationsPage({super.key});

  @override
  _ManageLocationsPageState createState() => _ManageLocationsPageState();
}

class _ManageLocationsPageState extends State<ManageLocationsPage> {
  List<Location> locations = [];
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/locations.txt');
  }

  Future<void> _loadLocations() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        List<String> locationList = contents.split('\n').where((line) => line.isNotEmpty).toList();
        setState(() {
          locations = locationList.map((loc) {
            final parts = loc.split(',');
            return Location(
              name: parts[0],
              isFavorite: parts[1] == 'true',
            );
          }).toList();
        });
      }
    } catch (e) {
      print("Error loading locations: $e");
    }
  }

  Future<void> _saveLocations() async {
    try {
      final file = await _getLocalFile();
      final content = locations.map((loc) => '${loc.name},${loc.isFavorite}').join('\n');
      await file.writeAsString(content);
    } catch (e) {
      print("Error saving locations: $e");
    }
  }

  // void _addLocation(String city) {
  //   setState(() {
  //     locations.add(Location(name: city, isFavorite: false));
  //   });
  //   _saveLocations();
  // }
// In ManageLocationsPage
  Future<void> _addLocation(String city) async {
    try {
      setState(() => _isLoading = true);

      // Validate location exists
      final location = await GeocodingService.getCoordinates(city);

      // Get standardized city name
      final validatedCityName = await GeocodingService.getCityName(
        location.latitude,
        location.longitude,
      );

      setState(() {
        locations.add(Location(
          name: validatedCityName,
          isFavorite: false,
        ));
        _isLoading = false;
      });

      await _saveLocations();

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid location: $city')),
      );
    }
  }
  void _toggleFavorite(int index) {
    setState(() {
      locations[index].isFavorite = !locations[index].isFavorite;
    });
    _saveLocations();
  }

  void _deleteLocation(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this location?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  locations.removeAt(index);
                });
                _saveLocations();
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteLocations = locations.where((loc) => loc.isFavorite).toList();
    final otherLocations = locations.where((loc) => !loc.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Locations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // const Text(
            //   'Manage Locations',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'Add a city',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _addLocation(value);
                  _locationController.clear();
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  if (favoriteLocations.isNotEmpty) ...[
                    const Text(
                      'Favorites',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    ...favoriteLocations.map((location) {
                      final index = locations.indexOf(location);
                      return _buildLocationTile(location, index);
                    }),
                  ],
                  if (favoriteLocations.isNotEmpty && otherLocations.isNotEmpty)
                    const Divider(),
                  if (otherLocations.isNotEmpty) ...[
                    const Text(
                      'Others',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    ...otherLocations.map((location) {
                      final index = locations.indexOf(location);
                      return _buildLocationTile(location, index);
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTile(Location location, int index) {
    return ListTile(
      title: Text(location.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              location.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: location.isFavorite ? Colors.red : null,
            ),
            onPressed: () => _toggleFavorite(index),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteLocation(index),
          ),
        ],
      ),
    );
  }
}

class Location {
  String name;
  bool isFavorite;

  Location({
    required this.name,
    required this.isFavorite,
  });
}
