import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class VideoPlayerPage extends StatefulWidget {
  final String? url;
  final String? path;

  const VideoPlayerPage({
    Key? key,
    this.url,
    this.path,
  }) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  Future _initVideoPlayer() async {
    print("rama");
    print(widget.path);
    _videoPlayerController = widget.path != null
        ? VideoPlayerController.file(File(
            widget.path!,
          ))
        : VideoPlayerController.network(
            widget.url!,
          );
    await _videoPlayerController!.initialize();
    await _videoPlayerController!.setLooping(false);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
    );
    _videoPlayerController!.play();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        body: FutureBuilder(
          future: _initVideoPlayer(),
          builder: (context, state) {
            if (state.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Chewie(
                controller: _chewieController!,
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController!.dispose();
    super.dispose();
  }
}
