import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class VideoPlayerScreen extends StatefulWidget {
  final List<Map<String, String>> channels;
  final int initialIndex;
  final Map<String, List<Map<String, String>>> categorizedChannels;
  final String currentCategoryName;

  const VideoPlayerScreen({
    super.key,
    required this.channels,
    required this.initialIndex,
    required this.categorizedChannels,
    required this.currentCategoryName,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  late int _currentIndex;
  late Timer _timer;

  String _currentCategoryName = '';
  List<Map<String, String>> _currentChannelList = [];

  String _temperature = '--°C';
  String _currentTime = '--:--';
  final String _apiKey = dotenv.env['API_KEY']!;

  @override
  void initState() {
    super.initState();
    _currentCategoryName = widget.currentCategoryName;
    _currentChannelList = widget.channels;
    _currentIndex = widget.initialIndex;
    _initializeController(_currentChannelList[_currentIndex]['id']!);
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

  void _initializeController(String videoId) {
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  void _changeChannel(int newIndex) {
    int nextIndex;
    if (newIndex >= _currentChannelList.length) {
      nextIndex = 0;
    } else if (newIndex < 0) {
      nextIndex = _currentChannelList.length - 1;
    } else {
      nextIndex = newIndex;
    }
    _controller.dispose();
    setState(() {
      _currentIndex = nextIndex;
    });
    _initializeController(_currentChannelList[_currentIndex]['id']!);
  }

  void _changeCategory(bool next) {
    final categoryNames = widget.categorizedChannels.keys.toList();
    final currentCategoryIndex = categoryNames.indexOf(_currentCategoryName);

    int newCategoryIndex;
    if (next) {
      newCategoryIndex = (currentCategoryIndex + 1) % categoryNames.length;
    } else {
      newCategoryIndex =
          (currentCategoryIndex - 1 + categoryNames.length) %
          categoryNames.length;
    }

    final newCategoryName = categoryNames[newCategoryIndex];
    final newChannelList = widget.categorizedChannels[newCategoryName]!;

    if (newChannelList.isNotEmpty) {
      _controller.dispose();
      setState(() {
        _currentCategoryName = newCategoryName;
        _currentChannelList = newChannelList;
        _currentIndex = 0;
      });
      _initializeController(_currentChannelList[_currentIndex]['id']!);
    }
  }

  void _onKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _changeChannel(_currentIndex - 1);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _changeChannel(_currentIndex + 1);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _changeCategory(false);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _changeCategory(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_currentChannelList[_currentIndex]['name']!}',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  _currentCategoryName,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '$_currentTime  $_temperature',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => _changeChannel(_currentIndex - 1),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => _changeChannel(_currentIndex + 1),
          ),
        ],
      ),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: _onKey,
        child: Center(
          child: YoutubePlayer(
            key: ValueKey(_currentChannelList[_currentIndex]['id']),
            controller: _controller,
            showVideoProgressIndicator: true,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }
}
