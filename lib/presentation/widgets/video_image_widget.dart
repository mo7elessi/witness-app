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
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(50.0),
            ),
            width: 50.0,
            height: 50.0,
            child: Icon(
              Icons.play_arrow,
              color: Colors.white.withOpacity(0.8),
              size: 50.0,
            ),
          ),
        ],
      ),
    );
  }
}
