import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tv_youtube_app/movie_channels.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final String _youtubeApiKey = dotenv.env['YOUTUBE_API_KEY']!;

  final Map<String, List<Map<String, String>>> _channelsWithVideos = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAndCacheAllChannelVideos();
  }

  // --- LÓGICA DE CACHÉ Y API ---
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/movie_cache.json');
  }

  Future<void> _fetchAndCacheAllChannelVideos({
    bool forceRefresh = false,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final file = await _localFile;
      bool cacheExists = await file.exists();

      if (cacheExists && !forceRefresh) {
        // 1. Cargar desde el archivo de caché
        final contents = await file.readAsString();
        final decoded = json.decode(contents) as Map<String, dynamic>;

        // Reconstruir el mapa de caché
        _channelsWithVideos.clear();
        decoded.forEach((key, value) {
          _channelsWithVideos[key] = List<Map<String, String>>.from(
            value.map((item) => Map<String, String>.from(item)),
          );
        });
        print('Datos cargados desde el caché.');
      } else {
        // 2. Cargar desde la API y guardar en el caché
        final tempChannelsWithVideos = <String, List<Map<String, String>>>{};

        for (var categoryEntry in categorizedMovieChannels.entries) {
          final categoryName = categoryEntry.key;
          tempChannelsWithVideos[categoryName] = [];

          for (var channel in categoryEntry.value) {
            final channelId = channel['id'];
            if (channelId != null) {
              final response = await http.get(
                Uri.parse(
                  'https://www.googleapis.com/youtube/v3/search?key=$_youtubeApiKey&channelId=$channelId&part=snippet,id&order=date&maxResults=5&type=video',
                ),
              );

              if (response.statusCode == 200) {
                final data = json.decode(response.body);
                for (var item in data['items']) {
                  tempChannelsWithVideos[categoryName]!.add({
                    'name': item['snippet']['title'],
                    'id': item['id']['videoId'],
                    'thumbnail': item['snippet']['thumbnails']['high']['url'],
                    'channelName': channel['name']!,
                  });
                }
              } else {
                print(
                  'Error al cargar videos del canal ${channel['name']}: ${response.statusCode}',
                );
                _errorMessage = 'Error al cargar algunos videos.';
              }
            }
          }
        }
        _channelsWithVideos.clear();
        _channelsWithVideos.addAll(tempChannelsWithVideos);

        // Guardar el nuevo caché en el archivo
        await file.writeAsString(json.encode(_channelsWithVideos));
        print('Datos cargados de la API y guardados en el caché.');
      }
    } catch (e) {
      print('Error en _fetchAndCacheAllChannelVideos: $e');
      _errorMessage =
          'Error de conexión. Verifica tu conexión a internet o claves API.';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- WIDGETS DE LA INTERFAZ ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selección de Películas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchAndCacheAllChannelVideos(forceRefresh: true),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _channelsWithVideos.keys.length,
                    itemBuilder: (context, categoryIndex) {
                      final categoryName = _channelsWithVideos.keys.elementAt(
                        categoryIndex,
                      );
                      final videosInCategory =
                          _channelsWithVideos[categoryName]!;

                      if (videosInCategory.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              categoryName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 164,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: videosInCategory.length,
                              itemBuilder: (context, videoIndex) {
                                final video = videosInCategory[videoIndex];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            YoutubePlayerFullScreen(
                                              videoId: video['id']!,
                                              videoTitle: video['name']!,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 200,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.network(
                                            video['thumbnail']!,
                                            height: 100,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      height: 100,
                                                      color: Colors.grey,
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.error,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              video['name']!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class YoutubePlayerFullScreen extends StatelessWidget {
  final String videoId;
  final String videoTitle;

  const YoutubePlayerFullScreen({
    super.key,
    required this.videoId,
    required this.videoTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(videoTitle)),
      body: Center(
        child: YoutubePlayer(
          controller: YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
          ),
          showVideoProgressIndicator: true,
        ),
      ),
    );
  }
}
