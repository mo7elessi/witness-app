import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nice_shot/core/util/boxes.dart';
import 'package:nice_shot/data/model/flag_model.dart';
import 'package:nice_shot/data/model/video_model.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../icons/icons.dart';
import '../widgets/flag_item_widget.dart';

class FlagsByVideoPage extends StatelessWidget {
  final List<FlagModel> flags;
  final String path;
  final VideoModel data;
  final int videoIndex;

  const FlagsByVideoPage({
    Key? key,
    required this.flags,
    required this.path,
    required this.data,
    required this.videoIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("FLAGS"),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${data.flags!.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5.0),
                const Icon(
                  MyIcons.flag,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Boxes.videoBox.listenable(),
        builder: (context, Box<VideoModel> items, _) => Padding(
          padding: const EdgeInsets.all(MySizes.widgetSideSpace),
          child: flags.isNotEmpty
              ? ListView.separated(
                  itemCount: flags.length,
                  itemBuilder: (context, index) {
                    return FlagItemWidget(
                      flagIndex: index,
                      videoIndex: videoIndex,
                      flagModel: flags[index],
                      items: items,
                      videoModel: data,
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                    height: MySizes.verticalSpace,
                  ),
                )
              : const Center(
                  child: Text("No flags"),
                ),
        ),
      ),
    );
  }
}
