import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/util/boxes.dart';
import '../../../widgets/video_item_widget.dart';

class EditedVideoPage extends StatelessWidget {
  const EditedVideoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VideoItemWidget(
      box: Boxes.exportedVideoBox,
      isEditedVideo: true,
    );
  }
}
