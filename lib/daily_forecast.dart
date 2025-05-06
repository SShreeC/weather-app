
import 'package:flutter/material.dart';
import 'package:weather_app/sunrise_sunset.dart';
import 'api_service.dart';
import 'geocoding_service.dart';
import 'weather_api_model.dart';

class DailyForecast extends StatefulWidget {
  const DailyForecast({super.key});

  @override
  _DailyForecastState createState() => _DailyForecastState();
}

class _DailyForecastState extends State<DailyForecast> {
  int selectedDays = 1;
  final List<int> dayOptions = [1, 3, 5, 7];
  WeatherApiService? weatherData;
  String locationName = '';
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final position = await GeocodingService.getCurrentLocation();
      final city = await GeocodingService.getCityName(
        position.latitude,
        position.longitude,
      );
      await _getWeatherData(position.latitude, position.longitude);
      setState(() => locationName = city);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final coordinates = await GeocodingService.getCoordinates(query);
      await _getWeatherData(coordinates.latitude, coordinates.longitude);
      setState(() => locationName = coordinates.displayName);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _getWeatherData(double lat, double lon) async {
    try {
      final data = await ApiService.getWeatherData(lat, lon);
      setState(() {
        weatherData = data;
        // Ensure selectedDays doesn't exceed available data
        selectedDays = selectedDays.clamp(1, data.daily.temperature2mMax.length);
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  int get availableDays => weatherData?.daily.temperature2mMax.length ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(locationName.isNotEmpty ? locationName : "Daily Forecast"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_sharp),
            onPressed: weatherData != null ? _showDaysDialog : null,
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/cloudy_2.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search location...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _searchLocation(_searchController.text),
                    ),
                  ),
                  onSubmitted: _searchLocation,
                ),
              ),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (error != null)
                Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              else if (weatherData != null && availableDays > 0)
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedDays.clamp(0, availableDays),
                      itemBuilder: (context, index) {
                        return _buildForecastCard(index);
                      },
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(int index) {
    final daily = weatherData!.daily;
    // Double-check index is within bounds
    if (index >= daily.temperature2mMax.length) return const SizedBox();
    DateTime now = DateTime.now();
    // Safely get values with null checks
    final temperature = daily.temperature2mMax.length > index ? daily.temperature2mMax[index] : null;
    final feelsLike = daily.apparentTemperatureMax.length > index ? daily.apparentTemperatureMax[index] : null;
    final sunrise = daily.sunrise.length > index ? daily.sunrise[index] : null;
    final sunset = daily.sunset.length > index ? daily.sunset[index] : null;
    final precipitation = daily.precipitationSum.length > index ? daily.precipitationSum[index] : null;
    final snowfall = daily.snowfallSum.length > index ? daily.snowfallSum[index] : null;
    final precipHours = daily.precipitationHours.length > index ? daily.precipitationHours[index] : null;

    if (temperature == null) return const SizedBox();
    String currentTime = "${now.hour}:${now.minute < 10 ? '0' : ''}${now.minute} ${now.hour >= 12 ? 'PM' : 'AM'}";


    return Card(
      color: Colors.black.withOpacity(0.2),
      margin: const EdgeInsets.all(8),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getFormattedDate(index),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _getWeatherIcon(index),
                Text(
                  "${temperature.toStringAsFixed(1)}°C",
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ],
            ),
            const Divider(color: Colors.white30),
            if (sunrise != null)
              _buildDetailRow("Sunrise", sunrise, Icons.wb_sunny),
            if (sunset != null)
              _buildDetailRow("Sunset", sunset, Icons.wb_twilight),
          // SunriseSunsetWidget(
          //     sunriseTime: sunrise.toString(), sunsetTime: sunset.toString(), currentTime:currentTime.toString(),
          //   ),
            const Divider(color: Colors.white30),
            if (feelsLike != null)
              _buildDetailRow(
                "Feels Like",
                "${feelsLike.toStringAsFixed(1)}°C",
                Icons.thermostat,
              ),
            if (precipitation != null)
              _buildDetailRow(
                "Precipitation",
                "${precipitation.toStringAsFixed(1)}mm",
                Icons.water_drop,
              ),
            if (snowfall != null)
              _buildDetailRow(
                "Snow",
                "${snowfall.toStringAsFixed(1)}cm",
                Icons.ac_unit,
              ),
            if (precipHours != null)
              _buildDetailRow(
                "Rain Hours",
                "${precipHours.toStringAsFixed(1)}h",
                Icons.watch_later,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          Text(label, style: const TextStyle(color: Colors.white)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _getWeatherIcon(int index) {
    final weatherCodes = weatherData!.daily.weatherCode;
    final weatherCode = weatherCodes.length > index ? weatherCodes[index] : 0;
    IconData icon;
    if (weatherCode < 3) {
      icon = Icons.wb_sunny;
    } else if (weatherCode < 50) {
      icon = Icons.cloud;
    } else if (weatherCode < 70) {
      icon = Icons.water_drop;
    } else {
      icon = Icons.ac_unit;
    }
    return Icon(icon, size: 40, color: Colors.orange);
  }

  String _getFormattedDate(int daysFromNow) {
    final date = DateTime.now().add(Duration(days: daysFromNow));
    return "${date.month}/${date.day}/${date.year}";
  }

  void _showDaysDialog() {
    final maxDays = availableDays;
    final validDayOptions = dayOptions.where((days) => days <= maxDays).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.9),
        title: const Text("Select Days"),
        content: DropdownButton<int>(
          value: selectedDays.clamp(1, maxDays),
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedDays = value);
              Navigator.pop(context);
            }
          },
          items: validDayOptions.map((day) {
            return DropdownMenuItem<int>(
              value: day,
              child: Text("$day Days"),
            );
          }).toList(),
        ),
      ),
    );
  }
}
