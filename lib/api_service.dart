import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_api_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  static Future<WeatherApiService> getWeatherData(
      double lat, double lon) async {
    final url = Uri.parse('$baseUrl?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,pressure_msl,wind_speed_10m'
        '&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,rain,pressure_msl,cloud_cover,wind_speed_80m,soil_moisture_0_to_1cm,is_day'
        '&daily=temperature_2m_max,apparent_temperature_max,sunrise,sunset,precipitation_sum,snowfall_sum,precipitation_hours'
        '&timezone=auto');
    // final url = Uri.parse('$baseUrl?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,cloud_cover,pressure_msl,wind_speed_10m&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,rain,pressure_msl,cloud_cover,wind_speed_80m,soil_moisture_0_to_1cm,is_day&daily=temperature_2m_max,apparent_temperature_max,sunrise,sunset,precipitation_sum,snowfall_sum,precipitation_hours&past_days=5&forecast_days=14');
     try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return WeatherApiService.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to weather service: $e');
    }
  }
}
