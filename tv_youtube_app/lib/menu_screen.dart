import 'package:flutter/material.dart';
import 'package:tv_youtube_app/video_player_screen.dart';
import 'package:tv_youtube_app/weather_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tv_youtube_app/movies_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Variables de estado para el clima y la hora
  String _temperature = '--°C';
  String _currentTime = '--:--';
  late Timer _timer;

  // ¡Pon tu clave API aquí!
  final String _apiKey = dotenv.env['API_KEY']!;

  // --- Lista de canales y categorías actualizada ---
  final Map<String, List<Map<String, String>>> _categorizedChannels = const {
    'Informativos Argentina': [
      {'name': 'Canal 3 Rosario', 'id': 'E8O9xdRhmeQ'},
      {'name': 'Canal 5', 'id': '2kiVqBBW8JM'},
      {'name': 'LN+', 'id': '5f__Ls4_VYQ'},
      {'name': 'A24', 'id': 'ArKbAx1K-2U'},
      {'name': 'C5N', 'id': 'Uo-ziJhrTvI'},
      {'name': 'América TV', 'id': 'VndAuMaJnJQ'},
      {'name': 'Crónica TV', 'id': 'avly0uwZzOE'},
      {'name': 'Telefe Noticias', 'id': 'xo8GkZXtNV0'},
      {'name': 'Todo Noticias', 'id': 'cb12KmMMDJA'},
      {'name': 'El 12 Córdoba', 'id': 'nndzeKDSjuc'},
      {'name': 'Radio Mitre', 'id': 'ybXIVVg6epw'},
      {'name': 'Canal 7', 'id': 'Vh8xmLBJtR8'},
      {'name': 'Canal 26', 'id': 'TxL6eFJq8NE'},
    ],
    'Internacional': [
      {'name': 'Milenio', 'id': 'VQjwWILv7rM'},
      {'name': 'Televisa Zacatecas', 'id': 'J8JZkN6D9nY'},
      {'name': 'Televisa Guadalajara', 'id': 'CT0Aq5ZU5H8'},
      {'name': 'CHV Noticias Chile', 'id': 'zjkta6QmqzI'},
      {'name': 'MegaNoticias Chile', 'id': 'QXMQ4eEMMoI'},
      {'name': 'TV Perú Noticias', 'id': '_rcJXSnXD7Y'},
      {'name': 'Telediario Canal 6 Mexico', 'id': '_orqdljDUuM'},
      {'name': 'Noticias 24/7 Mexico', 'id': 'p2AzyIEuFak'},
      {'name': 'France 24 Español Francia', 'id': 'Y-IlMeCCtIg'},
      {'name': 'Euronews Europa', 'id': 'O9mOtdZ-nSk'},
    ],
    'Películas': [
      {'name': 'Suspenso Channel', 'id': 'AYuYukZDtcE'},
      {'name': 'ClipZone', 'id': 'KbqR2QnysKE'},
      {'name': 'Películas de culto y acción', 'id': 'IkRHdNOwNtk'},
      {'name': 'Mad Max', 'id': 'nJVS2N6-X34'},
    ],
    'Documentales': [
      {'name': 'Planeta Hostil Documental', 'id': 'S5cN8Nfm9qw'},
      {'name': 'Love Nature Documental', 'id': 'mkJHnno0gdk'},
      {'name': 'Maussan Tv', 'id': 'IhTecbhM1PE'},
    ],
    'Música': [
      {'name': 'Rock FM', 'id': 'Nt27aBceerI'},
      {'name': 'La Nación 104.9 Más Música', 'id': '-6yoM_X2MwA'},
      {'name': 'FM Vida', 'id': 'dGQ25rVfUH4'},
      {'name': 'Best of Nostalgia', 'id': 'BuB9SaS2cWE'},
      {'name': 'Classic Rock Collection', 'id': 'OIzP_pM_mgs'},
      {'name': 'Top Old Songs', 'id': 'X2ZJ3Z0SXjo'},
      {'name': 'Selected Mood', 'id': 'spbdBNDqrzA'},
      {'name': 'Deep Beats', 'id': 'kxW-HJNjs8w'},
      {'name': 'Good Live Radio', 'id': '36YnV9STBqc'},
      {'name': 'Metal 24/7 Live Stream', 'id': '3LWMFjRZQ6k'},
    ],
    'Inglés': [
      {'name': 'Learn English with EnglishClass101 TV', 'id': 'ZYTPGn21ak0'},
      {'name': 'Best Teacher', 'id': 'ly-Dv5n8aJ8'},
      {'name': 'ABC Learning English', 'id': 'VTPjNB21Vd4'},
    ],
    'Niños': [
      {'name': 'Caracol Televisión', 'id': 'sKZH7OZYC_M'},
      {'name': 'Pokemon TV', 'id': 'Y5ZTvyMR8s0'},
    ],
    'Deportes': [
      {'name': 'Deportes RCN', 'id': 'bC4Xf_KD0dA'},
    ],
  };
  // --- Fin de la lista de canales y categorías actualizada ---

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();

    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _fetchWeatherData();
    });
  }

  Future<void> _fetchWeatherData() async {
    final String url =
        'https://api.openweathermap.org/data/2.5/weather?q=Rosario,AR&appid=$_apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data['main']['temp'].toInt();
        final now = DateTime.now();
        final formattedTime =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

        setState(() {
          _temperature = '$temp°C';
          _currentTime = formattedTime;
        });
      } else {
        setState(() {
          _temperature = 'Error';
          _currentTime = 'Error';
        });
      }
    } catch (e) {
      setState(() {
        _temperature = 'Error';
        _currentTime = 'Error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TV App - Menú Principal'),
        actions: [
          Row(
            children: [
              Text(
                '$_currentTime  $_temperature',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.movie),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MoviesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.wb_sunny_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeatherScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _categorizedChannels.keys.length,
          itemBuilder: (context, index) {
            String categoryName = _categorizedChannels.keys.elementAt(index);
            List<Map<String, String>> channelsInCategory =
                _categorizedChannels[categoryName]!;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: channelsInCategory.length,
                      itemBuilder: (context, channelIndex) {
                        final channel = channelsInCategory[channelIndex];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(
                                    channels: channelsInCategory,
                                    initialIndex: channelIndex,
                                    categorizedChannels: _categorizedChannels,
                                    currentCategoryName: categoryName,
                                  ),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all(
                                Colors.white,
                              ),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              textStyle: MaterialStateProperty.all(
                                const TextStyle(fontSize: 18),
                              ),
                              side:
                                  MaterialStateProperty.resolveWith<BorderSide>(
                                    (Set<MaterialState> states) {
                                      if (states.contains(
                                            MaterialState.focused,
                                          ) ||
                                          states.contains(
                                            MaterialState.pressed,
                                          )) {
                                        return const BorderSide(
                                          width: 3.0,
                                          color: Colors.white,
                                        );
                                      }
                                      return const BorderSide(
                                        width: 1.0,
                                        color: Colors.transparent,
                                      );
                                    },
                                  ),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color?>((
                                    Set<MaterialState> states,
                                  ) {
                                    if (states.contains(
                                      MaterialState.focused,
                                    )) {
                                      return Colors.grey.shade400;
                                    }
                                    if (states.contains(
                                      MaterialState.pressed,
                                    )) {
                                      return Colors.blue.shade900;
                                    }
                                    return Colors.blue.shade700;
                                  }),
                              elevation:
                                  MaterialStateProperty.resolveWith<double>((
                                    Set<MaterialState> states,
                                  ) {
                                    if (states.contains(
                                          MaterialState.focused,
                                        ) ||
                                        states.contains(
                                          MaterialState.pressed,
                                        )) {
                                      return 8.0;
                                    }
                                    return 2.0;
                                  }),
                            ),
                            child: Text(channel['name']!),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(color: Colors.white30, height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
