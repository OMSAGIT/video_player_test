import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VideoPlayer test'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context,
                  VideoScreen.route('assets/404x480.mp4', VideoMode.aspect)),
              child: const Text(
                "small (aspectRatio)",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  VideoScreen.route('assets/604x720.mp4', VideoMode.aspect)),
              child: const Text(
                "medium (aspectRatio)",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  VideoScreen.route('assets/1080x1286.mp4', VideoMode.aspect)),
              child: const Text(
                "large (aspectRatio)",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  VideoScreen.route('assets/404x480.mp4', VideoMode.size)),
              child: const Text(
                "small (sized box)",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  VideoScreen.route('assets/604x720.mp4', VideoMode.size)),
              child: const Text(
                "medium (sized box)",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  VideoScreen.route('assets/1080x1286.mp4', VideoMode.size)),
              child: const Text(
                "large (sized box)",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum VideoMode { aspect, size }

class VideoScreen extends StatelessWidget {
  static Route route(String asset, VideoMode mode) {
    return MaterialPageRoute<void>(
      builder: (_) => VideoScreen(asset: asset, mode: mode),
    );
  }

  const VideoScreen({Key? key, required this.asset, required this.mode})
      : super(key: key);

  final String asset;
  final VideoMode mode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('VideoPlayer test'),
        ),
        body: SingleChildScrollView(
            child: MyVideoPlayer(asset: asset, mode: mode)));
  }
}

class MyVideoPlayer extends StatefulWidget {
  const MyVideoPlayer({Key? key, required this.asset, required this.mode})
      : super(key: key);

  final String asset;
  final VideoMode mode;
  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.asset);
    _initializeVideoPlayerFuture = _controller.initialize();
    _initializeVideoPlayerFuture.then((value) => _controller.play());
  }

  @override
  void dispose() {
    Future.delayed(Duration.zero, () async {
      await _controller.pause();
      await _controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(alignment: FractionalOffset.bottomCenter, children: [
            if (widget.mode == VideoMode.aspect)
              AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller))
            else if (widget.mode == VideoMode.size)
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: (MediaQuery.of(context).size.width /
                      (_controller.value.size.width /
                          _controller.value.size.height)),
                  child: VideoPlayer(_controller)),
            VideoProgressIndicator(_controller, allowScrubbing: false)
          ]);
        } else {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width / (404.0 / 480.0),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
