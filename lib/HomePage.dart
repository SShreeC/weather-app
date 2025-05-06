
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/SettingsPage.dart';
import 'package:weather_app/geocoding_service.dart';
import 'package:weather_app/locationProvider.dart';
import 'api_service.dart';
import 'weather_api_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  WeatherApiService? _weatherData;
  GeocodingResponse? _geoLocationData;
  bool _isLoading = false;
  String _cityName = "";

  @override
  void initState() {
    super.initState();
    _fetchWeatherForCurrentLocation();
  }

  Future<void> _fetchWeather(String city) async {
    try {
      setState(() {
        _isLoading = true;
        _cityName = city.toUpperCase();
      });

      final location = await GeocodingService.getCoordinates(city);
      final weather = await ApiService.getWeatherData(
        location.latitude,
        location.longitude,
      );

      setState(() {
        _weatherData = weather;
        _geoLocationData = location;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherForCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Check location permission
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

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final weather = await ApiService.getWeatherData(
        position.latitude,
        position.longitude,
      );

      final locationDetails = await GeocodingService.getCityName(
        position.latitude,
        position.longitude,
      );

      if (kDebugMode) {
        print(locationDetails);
      } // Add this to see the details returned
      if (locationDetails != null) {
        setState(() {
          _weatherData = weather;
          _cityName = locationDetails.toUpperCase();
          _fetchWeather(_cityName ?? 'Unknown Location');
        });
      } else {
        // Handle the case where locationDetails is null
        setState(() {
          _cityName = 'Unknown Location';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getWeatherIcon(int weatherCode, {required bool isNight}) {
    // WMO Weather interpretation codes (WW)
    switch (weatherCode) {
      case 0: // Clear sky
        return isNight ? Icons.nights_stay : Icons.wb_sunny;
      case 1: // Mainly clear
      case 2: // Partly cloudy
        if (isNight) {
          return Icons.nights_stay;
        } else {
          return Icons.cloud;
        }
      case 3: // Overcast
        return Icons.cloud;
      case 45: // Foggy
      case 48: // Depositing rime fog
        return Icons.foggy;
      case 51: // Light drizzle
      case 53: // Moderate drizzle
      case 55: // Dense drizzle
        return Icons.grain;
      case 61: // Slight rain
      case 63: // Moderate rain
      case 65: // Heavy rain
        return Icons.cloudy_snowing;
      case 71: // Slight snow fall
      case 73: // Moderate snow fall
      case 75: // Heavy snow fall
        return Icons.ac_unit;
      case 77: // Snow grains
        return Icons.ac_unit;
      case 80: // Slight rain showers
      case 81: // Moderate rain showers
      case 82: // Violent rain showers
        return Icons.thunderstorm;
      case 85: // Slight snow showers
      case 86: // Heavy snow showers
        return Icons.ac_unit;
      case 95: // Thunderstorm
        return Icons.flash_on;
      case 96: // Thunderstorm with slight hail
      case 99: // Thunderstorm with heavy hail
        return Icons.flash_on;
      default:
        return isNight ? Icons.nights_stay : Icons.wb_sunny;
    }
  }

  String _getBackgroundImage(WeatherApiService? weather) {
    // If weather data is null, return default background
    if (weather == null) {
      return 'lib/assets/sunny.png';
    }

    final currentHour = DateTime.now().hour;
    final isNight = currentHour >= 18 || currentHour < 6;

    final isPolarRegion = weather.latitude.abs() > 66.5;

    if (isPolarRegion) {
      final dayOfYear =
          DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
      final isPolarNight =
          (dayOfYear < 80 || dayOfYear > 265) && weather.latitude < 0 ||
              (dayOfYear > 80 && dayOfYear < 265) && weather.latitude > 0;
      if (isPolarNight) {
        return 'lib/assets/polar_night.png';
      }
      return 'lib/assets/polar_day.png';
    }

    if (isNight) {
      return 'lib/assets/night.png';
    }
    if (!isNight) {
      return 'lib/assets/sunny.png';
    }
    // Handle normal weather conditions
    switch (weather.current.weatherCode) {
      case 0:
      case 1:
        return 'lib/assets/sunny.png';
      case 2:
      case 3:
        return 'lib/assets/cloudy_Bg.png';
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
        return 'lib/assets/rainy.png';
      case 71:
      case 73:
      case 75:
      case 77:
        return 'lib/assets/cold.png';
      default:
        return 'lib/assets/cloudy_2.png';
    }
  }

  String _formatTime(int hour) {
    // Display time in 24-hour format, adding 1 to hour for display after 24
    return "${(hour > 23 ? hour - 24 : hour).toString().padLeft(2, '0')}:00";
  }

  @override
  Widget build(BuildContext context) {
    final currentHour = DateTime.now().hour;
    final isNight =
        currentHour >= 18 || currentHour < 6; // Check if it's night time

    if (kDebugMode) {
      print(isNight);
    }
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Search city...',
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    // Provider.of<LocationProvider>(context, listen: false)
                    //   .addLocation(_cityName, context);
                    _fetchWeather(value);
                  }
                },
              )
            : const Text('Weather App', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Dynamic Background Image
          Opacity(
            opacity: 0.9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_getBackgroundImage(_weatherData)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_weatherData == null || _geoLocationData == null)
            const Center(
              child: Text(
                'Search for a city to view weather data',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location and Date Card
                  Card(
                    color: Colors.black.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: Text(
                        _cityName,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Current Weather Card
                  Card(
                    color: Colors.black.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Weather',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                _getWeatherIcon(
                                  _weatherData?.current.cloudCover ?? 0,
                                  isNight: isNight,
                                ),
                                size: 30,
                                color: Colors.white,
                              ),
                              Text(
                                'Temperature: ${_weatherData?.current.temperature2m.toStringAsFixed(1)}°C',
                                style: const TextStyle(color: Colors.white),
                              ),
                              // Text(
                              //   _getForecastDescription(
                              //       _weatherData?.current.cloudCover.toDouble() ?? 0),
                              //   style: const TextStyle(color: Colors.white),
                              // ),
                              Text(
                                _getForecastDescription(
                                  cloudCover: _weatherData?.current.cloudCover
                                          .toDouble() ??
                                      0,
                                  temperature: _weatherData
                                          ?.current.temperature2m
                                          .toDouble() ??
                                      0,
                                  precipitation: _weatherData
                                          ?.current.precipitation
                                          .toDouble() ??
                                      0,
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Humidity: ${_weatherData?.current.relativeHumidity2m.toStringAsFixed(0)}%',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Wind: ${_weatherData?.current.windSpeed10m.toStringAsFixed(1)} km/h',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pressure: ${_weatherData?.current.pressureMsl.toStringAsFixed(0)} hPa',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Rain: ${_weatherData?.current.rain.toStringAsFixed(1)} mm',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hourly Forecast Card
                  Card(
                    color: Colors.black.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hourly Forecast',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                6,
                                (index) => Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    border: Border.all(color: Colors.white),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatTime(
                                            DateTime.now().hour + index),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Icon(
                                        _getWeatherIcon(
                                          _weatherData
                                                  ?.hourly.cloudCover[index] ??
                                              0,
                                          isNight: isNight,
                                        ),
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_weatherData?.hourly.temperature2m[index].toStringAsFixed(1)}°C',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getForecastDescription(
      {required double cloudCover,
      required double temperature,
      required double precipitation}) {
    if (precipitation > 70) {
      return 'Raining heavily';
    } else if (precipitation > 30) {
      return 'Drizzling';
    } else if (temperature < 0) {
      return 'Very cold and clear skies';
    } else if (temperature <= 10) {
      return 'Cold with clear skies';
    } else if (cloudCover > 70) {
      return 'Very cloudy';
    } else if (cloudCover > 30) {
      return 'Partly cloudy';
    } else if (temperature > 35) {
      return 'Hot and clear skies';
    } else {
      return 'Clear skies';
    }
  }
}

