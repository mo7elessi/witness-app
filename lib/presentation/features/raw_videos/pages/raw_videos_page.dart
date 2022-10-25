import 'package:flutter/material.dart';
import '../../../../core/util/boxes.dart';
import '../../../widgets/video_item_widget.dart';

class RawVideosPage extends StatelessWidget {
  const RawVideosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    // return Padding(
    //   padding: const EdgeInsets.all(MySizes.widgetSideSpace),
    //   child: ValueListenableBuilder(
    //     valueListenable: Boxes.videoBox.listenable(),
    //     builder: (context, Box<VideoModel> items, _) {
    //       List<int> keys = items.keys.cast<int>().toList();
    //       return items.length > 0
    //           ? ListView.separated(
    //               separatorBuilder: (context, index) => const SizedBox(
    //                 height: MySizes.verticalSpace,
    //               ),
    //               itemCount: keys.length,
    //               scrollDirection: Axis.vertical,
    //               physics: const BouncingScrollPhysics(),
    //               itemBuilder: (_, index) {
    //                 final int key = keys[index];
    //                 final VideoModel data = items.get(key)!;
    //                 final String time =
    //                     DateFormat().add_jm().format(data.dateTime!);
    //                 final String date =
    //                     DateFormat().add_yMEd().format(data.dateTime!);
    //                 List duration = data.videoDuration!.split(":");
    //                 final videoDuration = Duration(
    //                   seconds:
    //                       int.parse(duration.last.toString().split(".").first),
    //                   minutes: int.parse(duration[1]),
    //                   hours: int.parse(duration.first),
    //                 );
    //                 if (File(data.path!).existsSync() == true) {
    //                   String minutes = strDigits(
    //                     videoDuration.inMinutes.remainder(60),
    //                   );
    //                   String seconds = strDigits(
    //                     videoDuration.inSeconds.remainder(60),
    //                   );
    //                   return Slidable(
    //                     closeOnScroll: true,
    //                     endActionPane: ActionPane(
    //                       motion: const ScrollMotion(),
    //                       children: [
    //                         SlidableActionWidget(
    //                           color: MyColors.primaryColor,
    //                           context: context,
    //                           function: () async {
    //                             await File(data.path!).delete();
    //                             items.deleteAt(index);
    //                           },
    //                           icon: Icons.delete,
    //                         ),
    //                         SlidableActionWidget(
    //                           color: Colors.blueAccent,
    //                           context: context,
    //                           function: () async {
    //                             myAlertDialog(
    //                               controller: controller,
    //                               context: context,
    //                               function: () async {
    //                                 if (controller.text.isNotEmpty) {
    //                                   await items
    //                                       .putAt(
    //                                         index,
    //                                         data..title = controller.text,
    //                                       )
    //                                       .then(
    //                                         (value) => Navigator.pop(context),
    //                                       );
    //                                 }
    //                               },
    //                             );
    //                           },
    //                           icon: Icons.edit,
    //                         ),
    //                       ],
    //                     ),
    //                     child: Container(
    //                       height: 120.0,
    //                       width: double.infinity,
    //                       padding: const EdgeInsets.all(
    //                         MySizes.widgetSideSpace / 2,
    //                       ),
    //                       decoration: myBoxDecoration,
    //                       child: InkWell(
    //                         onTap: () {
    //                           Navigator.push(
    //                             context,
    //                             MaterialPageRoute(
    //                               builder: (context) => data.flags!.isNotEmpty
    //                                   ? FlagsByVideoPage(
    //                                       flags: data.flags ?? [],
    //                                       path: data.path ?? "",
    //                                       data: data,
    //                                       videoIndex: index,
    //                                     )
    //                                   : TrimmerPage(
    //                                       file: File(data.path!),
    //                                       flag: FlagModel(
    //                                           endDuration: Duration(
    //                                               seconds: int.parse(seconds),
    //                                               minutes: int.parse(minutes)),
    //                                           startDuration:
    //                                               const Duration(seconds: 0),
    //                                           videoDuration: data.videoDuration,
    //                                           flagPoint: Duration(seconds: int.parse(seconds)~/2)),
    //                                       data: data,
    //                                       items: items,
    //                                       flagIndex: 0,
    //                                       videoIndex: index,
    //                                       videoDuration: videoDuration,
    //                                     ),
    //                             ),
    //                           );
    //                         },
    //                         child: Row(
    //                           children: [
    //                             Expanded(
    //                               child: Stack(
    //                                 alignment: Alignment.center,
    //                                 children: [
    //                                   Container(
    //                                     width: double.infinity,
    //                                     height: double.infinity,
    //                                     decoration: myBoxDecoration,
    //                                     child: data.videoThumbnail != null
    //                                         ? Image.file(
    //                                             File(data.videoThumbnail!),
    //                                             fit: BoxFit.cover,
    //                                           )
    //                                         : const SizedBox(),
    //                                   ),
    //                                   Icon(
    //                                     Icons.play_arrow,
    //                                     color: Colors.white.withOpacity(0.8),
    //                                     size: 64.0,
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                             const SizedBox(
    //                               width: MySizes.widgetSideSpace,
    //                             ),
    //                             Expanded(
    //                               flex: 2,
    //                               child: Column(
    //                                 mainAxisSize: MainAxisSize.min,
    //                                 crossAxisAlignment:
    //                                     CrossAxisAlignment.start,
    //                                 children: [
    //                                   Row(
    //                                     children: [
    //                                       Expanded(
    //                                         flex: 4,
    //                                         child: Text(
    //                                           data.title ?? "No title",
    //                                           style: Theme.of(context)
    //                                               .textTheme
    //                                               .titleMedium,
    //                                           overflow: TextOverflow.ellipsis,
    //                                         ),
    //                                       ),
    //                                       const Spacer(),
    //                                       FlagCountWidget(
    //                                           count: data.flags!.length),
    //                                     ],
    //                                   ),
    //                                   Text(
    //                                     "$date At $time",
    //                                     style: Theme.of(context)
    //                                         .textTheme
    //                                         .bodySmall!
    //                                         .copyWith(fontSize: 10.0),
    //                                   ),
    //                                   const Spacer(),
    //                                   BlocConsumer<RawVideoBloc, RawVideoState>(
    //                                     listener: (context, state) {
    //                                       if (state.requestState ==
    //                                           RequestState.loaded) {}
    //                                     },
    //                                     builder: (context, state) {
    //                                       return InkWell(
    //                                         onTap: () {
    //                                           context
    //                                               .read<RawVideoBloc>()
    //                                               .add(UploadRawVideoEvent(
    //                                                 video: video.VideoModel(
    //                                                   categoryId: "1",
    //                                                   name: data.title ??
    //                                                       "No title",
    //                                                   userId:
    //                                                       "${currentUserData!.user!.id}",
    //                                                   file: File(data.path!),
    //                                                 ),
    //                                               ));
    //                                         },
    //                                         child: Container(
    //                                           decoration: myBoxDecoration,
    //                                           padding:
    //                                               const EdgeInsets.all(4.0),
    //                                           child: Row(
    //                                             mainAxisAlignment:
    //                                                 MainAxisAlignment.center,
    //                                             children: const [
    //                                               Icon(Icons.upload),
    //                                               Text(
    //                                                 "UPLOAD",
    //                                                 style: TextStyle(
    //                                                   fontSize: 12,
    //                                                   color: Colors.grey,
    //                                                 ),
    //                                               ),
    //                                             ],
    //                                           ),
    //                                         ),
    //                                       );
    //                                     },
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   );
    //                 }
    //                 return const SizedBox();
    //               },
    //             )
    //           : const Center(
    //               child: ErrorMessageWidget(
    //               message: "You have not recorded any video yet!",
    //             ));
    //     },
    //   ),
    // );
    return VideoItemWidget(
      box: Boxes.videoBox,
      isEditedVideo: false,
    );
  }
}
