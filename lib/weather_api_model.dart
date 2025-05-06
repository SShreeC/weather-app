
class WeatherApiService {
  WeatherApiService({
    required this.latitude,
    required this.longitude,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherApiService.fromJson(Map<String, dynamic> json) {
    return WeatherApiService(
      latitude: json['latitude'] as num,
      longitude: json['longitude'] as num,
      current: Current.fromJson(json['current']),
      hourly: Hourly.fromJson(json['hourly']),
      daily: Daily.fromJson(json['daily']),
    );
  }

  final num latitude;
  final num longitude;
  final Current current;
  final Hourly hourly;
  final Daily daily;

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'current': current.toJson(),
    'hourly': hourly.toJson(),
    'daily': daily.toJson(),
  };
}

class Current {
  Current({
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.isDay,
    required this.precipitation,
    required this.rain,
    required this.pressureMsl,
    required this.windSpeed10m,
    required this.cloudCover,
    required this.weatherCode,
  });

  factory Current.fromJson(Map<String, dynamic> json) {
    return Current(
      temperature2m: json['temperature_2m'] ?? 0.0,
      relativeHumidity2m: json['relative_humidity_2m'] ?? 0.0,
      apparentTemperature: json['apparent_temperature'] ?? 0.0,
      isDay: json['is_day'] ?? 0,
      precipitation: json['precipitation'] ?? 0.0,
      rain: json['rain'] ?? 0.0,
      pressureMsl: json['pressure_msl'] ?? 0.0,
      windSpeed10m: json['wind_speed_10m'] ?? 0.0,
      cloudCover: json['cloud_cover'] ?? 0.0,
      weatherCode: json['weather_code'] ?? 0,
    );
  }

  final num temperature2m;
  final num relativeHumidity2m;
  final num apparentTemperature;
  final int isDay;
  final num precipitation;
  final num rain;
  final num pressureMsl;
  final num windSpeed10m;
  final int cloudCover;
  final int weatherCode;



  Map<String, dynamic> toJson() => {
    'temperature_2m': temperature2m,
    'relative_humidity_2m': relativeHumidity2m,
    'apparent_temperature': apparentTemperature,
    'is_day': isDay,
    'precipitation': precipitation,
    'rain': rain,
    'pressure_msl': pressureMsl,
    'wind_speed_10m': windSpeed10m,
    'cloud_cover': cloudCover,
    'weather_code': weatherCode,
  };
}

class Hourly {
  Hourly({
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.precipitationProbability,
    required this.rain,
    required this.pressureMsl,
    required this.cloudCover,
    required this.windSpeed80m,
    required this.soilMoisture,
    required this.isDay,
    required this.weatherCode,
  });

  factory Hourly.fromJson(Map<String, dynamic> json) {
    return Hourly(
      temperature2m: json['temperature_2m'] != null ? List<num>.from(json['temperature_2m']) : [],
      relativeHumidity2m: json['relative_humidity_2m'] != null ? List<num>.from(json['relative_humidity_2m']) : [],
      precipitationProbability: json['precipitation_probability'] != null ? List<num>.from(json['precipitation_probability']) : [],
      rain: json['rain'] != null ? List<num>.from(json['rain']) : [],
      pressureMsl: json['pressure_msl'] != null ? List<num>.from(json['pressure_msl']) : [],
      cloudCover: json['cloud_cover'] != null ? List<int>.from(json['cloud_cover']) : [],
      windSpeed80m: json['wind_speed_80m'] != null ? List<num>.from(json['wind_speed_80m']) : [],
      soilMoisture: json['soil_moisture_0_to_1cm'] != null ? List<num>.from(json['soil_moisture_0_to_1cm']) : [],
      isDay: json['is_day'] != null ? List<int>.from(json['is_day']) : [],
      weatherCode: json['weather_code'] != null ? List<int>.from(json['weather_code']) : [],
    );
  }

  final List<num> temperature2m;
  final List<num> relativeHumidity2m;
  final List<num> precipitationProbability;
  final List<num> rain;
  final List<num> pressureMsl;
  final List<int> cloudCover;
  final List<num> windSpeed80m;
  final List<num> soilMoisture;
  final List<int> isDay;
  final List<int> weatherCode;

  Map<String, dynamic> toJson() => {
    'temperature_2m': temperature2m,
    'relative_humidity_2m': relativeHumidity2m,
    'precipitation_probability': precipitationProbability,
    'rain': rain,
    'pressure_msl': pressureMsl,
    'cloud_cover': cloudCover,
    'wind_speed_80m': windSpeed80m,
    'soil_moisture_0_to_1cm': soilMoisture,
    'is_day': isDay,
    'weather_code': weatherCode,
  };
}

class Daily {
  Daily({
    required this.temperature2mMax,
    required this.apparentTemperatureMax,
    required this.sunrise,
    required this.sunset,
    required this.precipitationSum,
    required this.snowfallSum,
    required this.precipitationHours,
    required this.weatherCode,
  });

  factory Daily.fromJson(Map<String, dynamic> json) {
    return Daily(
      temperature2mMax: json['temperature_2m_max'] != null ? List<num>.from(json['temperature_2m_max']) : [],
      apparentTemperatureMax: json['apparent_temperature_max'] != null ? List<num>.from(json['apparent_temperature_max']) : [],
      sunrise: json['sunrise'] != null ? List<String>.from(json['sunrise']) : [],
      sunset: json['sunset'] != null ? List<String>.from(json['sunset']) : [],
      precipitationSum: json['precipitation_sum'] != null ? List<num>.from(json['precipitation_sum']) : [],
      snowfallSum: json['snowfall_sum'] != null ? List<num>.from(json['snowfall_sum']) : [],
      precipitationHours: json['precipitation_hours'] != null ? List<num>.from(json['precipitation_hours']) : [],
      weatherCode: json['weather_code'] != null ? List<int>.from(json['weather_code']) : [],
    );
  }

  final List<num> temperature2mMax;
  final List<num> apparentTemperatureMax;
  final List<String> sunrise;
  final List<String> sunset;
  final List<num> precipitationSum;
  final List<num> snowfallSum;
  final List<num> precipitationHours;
  final List<int> weatherCode;

  Map<String, dynamic> toJson() => {
    'temperature_2m_max': temperature2mMax,
    'apparent_temperature_max': apparentTemperatureMax,
    'sunrise': sunrise,
    'sunset': sunset,
    'precipitation_sum': precipitationSum,
    'snowfall_sum': snowfallSum,
    'precipitation_hours': precipitationHours,
    'weather_code': weatherCode,
  };
}
