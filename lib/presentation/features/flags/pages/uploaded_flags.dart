import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/core/functions/functions.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/data/model/api/tag_model.dart';
import 'package:nice_shot/presentation/features/raw_videos/bloc/raw_video_bloc.dart';
import 'package:nice_shot/presentation/widgets/error_widget.dart';
import 'package:nice_shot/presentation/widgets/loading_widget.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/util/my_alert_dialog.dart';
import '../../../../core/util/my_box_decoration.dart';
import '../../../widgets/alert_dialog_widget.dart';
import '../../../widgets/action_widget.dart';

class UploadedFlagsPage extends StatelessWidget {
  final String rawVideoId;

  const UploadedFlagsPage({
    Key? key,
    required this.rawVideoId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      context.read<RawVideoBloc>().add(GetRawVideoEvent(id: rawVideoId));
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text("FLAGS"),
              const Spacer(),
              BlocBuilder<RawVideoBloc, RawVideoState>(
                builder: (context, state) {
                  if (state.flagRequest == RequestState.loaded) {
                    List<TagModel> tags = state.video?.data!.tags ?? [];

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${tags.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5.0),
                        const Icon(Icons.flag, color: Colors.white),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
        body: BlocBuilder<RawVideoBloc, RawVideoState>(builder: (context, state) {
          RawVideoBloc bloc = context.read<RawVideoBloc>();
          TextEditingController controller = TextEditingController();
          if (state.flagRequest == RequestState.loaded) {
            List<TagModel> tags = state.video?.data!.tags ?? [];
            return tags.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(MySizes.widgetSideSpace),
                    child: ListView.separated(
                      itemCount: tags.length,
                      itemBuilder: (context, index) {
                        TagModel flag = tags[index];
                        List startDuration = flag.startAt!.split(":");
                        final startTime = Duration(
                          seconds: int.parse(startDuration.last.toString().split(".").first),
                          minutes: int.parse(startDuration[1]),
                          hours: int.parse(startDuration.first),
                        );
                        
                        List endDuration = flag.endAt!.split(":");
                        final endTime = Duration(
                          seconds: int.parse(
                              endDuration.last.toString().split(".").first),
                          minutes: int.parse(endDuration[1]),
                          hours: int.parse(endDuration.first),
                        );

                        return Container(
                          decoration: myBoxDecoration,
                          child: InkWell(
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                                leading: Text("${index + 1}"),
                                title: Text(
                                  flag.tag!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  "STR: ${formatDuration(startTime)} - END: ${formatDuration(endTime)} ",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) {
                                  //       return TrimmerPage(
                                  //         file: File(videoModel.path!),
                                  //         flag: flagModel,
                                  //         data: videoModel,
                                  //         items: items,
                                  //         videoDuration: videoDuration,
                                  //         videoIndex: 0,
                                  //         flagIndex: index,
                                  //       );
                                  //     },
                                  //   ),
                                  // );
                                },
                                onLongPress: () {
                                  showModalBottomSheet(
                                    backgroundColor: Colors.white,
                                    elevation: 8,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10.0),
                                      ),
                                    ),
                                    builder: (context) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ActionWidget(
                                            title: "Delete",
                                            icon: Icons.delete_forever_rounded,
                                            function: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialogWidget(
                                                    message:
                                                        "are you sure delete flag",
                                                    title: "delete flag",
                                                    function: () async {
                                                      bloc.add(DeleteFlagEvent(
                                                          id: tags[index]
                                                              .id
                                                              .toString(),
                                                          rawVideoId:
                                                              rawVideoId));
                                                      Navigator.pop(context);
                                                    },
                                                  );
                                                },
                                              ).then((value) =>
                                                  Navigator.pop(context));
                                            },
                                          ),
                                          ActionWidget(
                                            title: "Edit title",
                                            icon: Icons.edit,
                                            function: () {
                                              myAlertDialog(
                                                controller: controller,
                                                context: context,
                                                function: () async {
                                                  TagModel tagModel = TagModel(
                                                    id: flag.id!,
                                                    tag: controller.text,
                                                    rawVideoId: flag.rawVideoId,
                                                  );
                                                  bloc.add(UpdateFlagEvent(
                                                      tag: tagModel,
                                                      rawVideoId: rawVideoId));
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                    context: context,
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(
                        height: MySizes.verticalSpace,
                      ),
                    ),
                  )
                : const Center(child: Text("No tags"));
          } else if (state.flagRequest == RequestState.loading) {
            return const LoadingWidget();
          } else if (state.flagRequest == RequestState.error) {
            return ErrorMessageWidget(message: state.message!);
          }
          return const LoadingWidget();
        }),
      );
    });
  }
}
