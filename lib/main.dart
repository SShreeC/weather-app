import 'package:flutter/material.dart';
import 'package:weather_app/HomePage.dart';
import 'package:weather_app/daily_forecast.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home:  const HomePage(),
    );
  }
}

