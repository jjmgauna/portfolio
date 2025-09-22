import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:collection';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  List<Map<String, dynamic>> _forecast = [];
  String _errorMessage = 'Cargando...';

  // ¡Pon tu clave API aquí!
  final String _apiKey = dotenv.env['API_KEY']!;

  final Map<String, Map<String, dynamic>> _dailyForecast =
      LinkedHashMap<String, Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();
    _fetchForecastData();
  }

  Future<void> _fetchForecastData() async {
    final String url =
        'https://api.openweathermap.org/data/2.5/forecast?q=Rosario,AR&appid=$_apiKey&units=metric&lang=es';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['list'];

        _dailyForecast.clear();

        for (var item in list) {
          final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          final dateKey = '${date.year}-${date.month}-${date.day}';

          if (!_dailyForecast.containsKey(dateKey)) {
            _dailyForecast[dateKey] = {
              'date': date,
              'temp': item['main']['temp'],
              'description': item['weather'][0]['description'],
              'icon': item['weather'][0]['icon'], // Agregamos el ícono
              'temp_max': item['main']['temp_max'],
              'temp_min': item['main']['temp_min'],
            };
          }
        }

        setState(() {
          _forecast = _dailyForecast.values.toList();
          _errorMessage = '';
        });
      } else {
        setState(() {
          _errorMessage =
              'Error: No se pudo obtener el pronóstico. Código: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión. Revisa tus permisos o clave API.';
      });
    }
  }

  String _getFormattedDate(DateTime date) {
    if (date.day == DateTime.now().day) {
      return 'Hoy';
    } else if (date.day == DateTime.now().add(const Duration(days: 1)).day) {
      return 'Mañana';
    } else if (date.day == DateTime.now().add(const Duration(days: 2)).day) {
      return 'Pasado Mañana';
    } else {
      return '';
    }
  }

  Widget _buildDailyForecastCard(Map<String, dynamic> dayData, int index) {
    final date = dayData['date'] as DateTime;
    final String description = dayData['description'];
    final double temp = dayData['temp'];
    final String iconCode = dayData['icon'];

    final formattedDate = _getFormattedDate(date);
    if (formattedDate.isEmpty) {
      return const SizedBox.shrink();
    }

    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Image.network(
                'https://openweathermap.org/img/wn/$iconCode@2x.png',
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
              ),
              const SizedBox(height: 8),
              Text(
                '${temp.toInt()}°C',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pronóstico del tiempo')),
      body: _errorMessage.isNotEmpty
          ? Center(
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  for (
                    int i = 0;
                    i < (_forecast.length > 3 ? 3 : _forecast.length);
                    i++
                  )
                    _buildDailyForecastCard(_forecast[i], i),
                ],
              ),
            ),
    );
  }
}
