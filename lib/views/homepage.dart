import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String apiKey = "3e925a0703914365ba793037241512";
  String selectedCity = "Москва";
  List<String> cities = [
    "Лондон",
    "Нью-Йорк",
    "Токио",
    "Париж",
    "Москва",
    "Ханты-Мансийск",
    "Сургут",
  ];

  DateTime currentTime = DateTime.now();

  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    final url = Uri.parse(
        "https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$selectedCity&days=5&aqi=no&alerts=no&lang=ru");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        weatherData = json.decode(utf8.decode(response.bodyBytes));
        currentTime = DateTime.now();
      });
    } else {
      print("Ошибка при получении данных: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "WeatherApp",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: weatherData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                DropdownButton<String>(
                  value: selectedCity,
                  items: cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value!;
                      fetchWeather();
                    });
                  },
                ),
                Text(
                  "${weatherData!["location"]["name"]}, ${weatherData!["location"]["country"]}",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            "${weatherData!["current"]["temp_c"]}°C",
                            style: const TextStyle(fontSize: 32),
                          ),
                          Image.network(
                            "https:${weatherData!["current"]["condition"]["icon"]}",
                          ),
                          Text(
                              "${weatherData!["current"]["condition"]["text"]}"),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.water_drop),
                              Text(
                                  "Влажность: ${weatherData!["current"]["humidity"]}%")
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.compress),
                              Text(
                                  "Давление: ${weatherData!["current"]["pressure_mb"]} hPa")
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.air),
                              Text(
                                  "Ветер: ${weatherData!["current"]["wind_kph"]} км/ч")
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text("Обновлено: ${DateFormat.Hm().format(currentTime)}"),
                Expanded(
                  child: ListView.builder(
                    itemCount: weatherData!["forecast"]["forecastday"].length,
                    itemBuilder: (context, index) {
                      final forecast =
                          weatherData!["forecast"]["forecastday"][index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          leading: Image.network(
                            "https:${forecast["day"]["condition"]["icon"]}",
                          ),
                          title: Text(
                            "${forecast["date"]}: ${forecast["day"]["condition"]["text"]}",
                          ),
                          subtitle: Text(
                            "Мин: ${forecast["day"]["mintemp_c"]}°C, Макс: ${forecast["day"]["maxtemp_c"]}°C",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
