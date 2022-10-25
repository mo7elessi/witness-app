import 'package:hive/hive.dart';

import '../../../../../data/model/video_model.dart';

class Boxes {
  static Box<VideoModel> videoBox = Hive.box<VideoModel>(
    'video_db',
  );
  static Box<VideoModel> exportedVideoBox = Hive.box<VideoModel>(
    'exported_video_db',
  );
}
