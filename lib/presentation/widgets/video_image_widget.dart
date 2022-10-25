import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/util/my_box_decoration.dart';

class VideoImageWidget extends StatelessWidget {
  final String? videoThumbnailPath;

  const VideoImageWidget({Key? key, required this.videoThumbnailPath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: myBoxDecoration,
            child: videoThumbnailPath != null
                ? Image.file(File(videoThumbnailPath!), fit: BoxFit.cover)
                : const SizedBox(),
          ),
          Icon(
            Icons.play_arrow,
            color: Colors.white.withOpacity(0.8),
            size: 64.0,
          ),
        ],
      ),
    );
  }
}
