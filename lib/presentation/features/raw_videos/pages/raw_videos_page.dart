import 'package:flutter/material.dart';
import '../../../../core/util/boxes.dart';
import '../../../widgets/video_item_widget.dart';

class RawVideosPage extends StatelessWidget {
  const RawVideosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VideoItemWidget(
      box: Boxes.videoBox,
      isEditedVideo: false,
    );
  }
}
