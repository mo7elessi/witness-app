import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class UserImageWidget extends StatelessWidget {
  final String imageUri;

  const UserImageWidget({Key? key, required this.imageUri}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(MySizes.imageRadius),
      child: CachedNetworkImage(
        progressIndicatorBuilder: (context, url, progress) => Container(
          width: MySizes.imageWidth,
          height: MySizes.imageHeight,
          color: Colors.red.shade100,
        ),
        width: MySizes.imageWidth,
        height: MySizes.imageHeight,
        fit: BoxFit.cover,
        imageUrl: imageUri,
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}
