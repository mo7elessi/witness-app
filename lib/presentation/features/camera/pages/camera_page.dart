import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/presentation/features/camera/widgets/zoom_widget.dart';
import 'package:nice_shot/presentation/widgets/loading_widget.dart';
import 'package:nice_shot/presentation/features/camera/bloc/bloc.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../../../core/routes/routes.dart';
import '../../../../data/model/video_model.dart';
import '../../../widgets/flag_count_widget.dart';
import '../widgets/actions_widget.dart';
import '../widgets/resolutions_widget.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    CameraBloc cameraBloc = context.read<CameraBloc>();
    VideoModel video = VideoModel(
      dateTime: DateTime.now(),
      videoDuration: cameraBloc.videoDuration.toString(),
      flags: cameraBloc.flags,
    );

    if (state == AppLifecycleState.paused) {
      cameraBloc.add(
        StopRecordingEvent(
          video: video,
          fromUser: true,
        ),
      );
      cameraBloc.add(OpenFlashEvent(open: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    CameraBloc controller = BlocProvider.of<CameraBloc>(context, listen: true);
    CameraBloc cameraBloc = BlocProvider.of<CameraBloc>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: controller.controller != null
            ? Stack(
                children: [
                  BlocBuilder<CameraBloc, CameraState>(
                      builder: (context, state) {
                    return GestureDetector(
                      onTapUp: (details) {
                        if (cameraBloc.controller!.value.isRecordingVideo) {
                          cameraBloc.add(FocusEvent(
                            details: details,
                            context: context,
                          ));
                        }
                      },
                      child: Stack(
                        children: [
                          CameraPreview(cameraBloc.controller!),
                          if (cameraBloc.showFocusCircle)
                            Positioned(
                                top: cameraBloc.y - 20,
                                left: cameraBloc.x - 20,
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.yellowAccent,
                                        width: 2,
                                      )),
                                )),
                        ],
                      ),
                    );
                  }),
                  if (!cameraBloc.controller!.value.isRecordingVideo)
                    BlocBuilder<CameraBloc, CameraState>(
                      builder: (context, state) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  cameraBloc.add(OpenFlashEvent(open: true));
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    Routes.homePage,
                                    (route) => false,
                                  );
                                },
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                              ResolutionsWidget(cameraBloc: cameraBloc),
                              TextButton(
                                onPressed: () async {
                                  showDialog<int>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.black54,
                                          title: Row(
                                            children: [
                                              Text(
                                                "Video Duration",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1!
                                                    .copyWith(
                                                      color: Colors.white70,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          content: BlocBuilder<CameraBloc,
                                              CameraState>(
                                            builder: (context, state) {
                                              return NumberPicker(
                                                  selectedTextStyle:
                                                      const TextStyle(
                                                    color: Colors.yellowAccent,
                                                  ),
                                                  value: cameraBloc
                                                      .selectedDuration
                                                      .inMinutes,
                                                  minValue: 1,
                                                  maxValue: 40,
                                                  textStyle: const TextStyle(
                                                      color: Colors.white60),
                                                  itemWidth: 50,
                                                  infiniteLoop: true,
                                                  axis: Axis.horizontal,
                                                  onChanged: (value) {
                                                    cameraBloc.add(
                                                      ChangeSelectedDurationEvent(
                                                          duration: Duration(
                                                              minutes: value)),
                                                    );
                                                  });
                                            },
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text(
                                                "OK",
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        );
                                      });
                                },
                                child: Text(
                                  "${cameraBloc.selectedMinutes} MIN",
                                  style: const TextStyle(
                                    color: Colors.yellowAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  cameraBloc.add(OpenFlashEvent(
                                    open: cameraBloc.flashOpened,
                                  ));
                                },
                                icon: Icon(
                                  cameraBloc.flashOpened
                                      ? Icons.flash_on
                                      : Icons.flash_off_outlined,
                                  color: cameraBloc.flashOpened
                                      ? Colors.yellowAccent
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  if (cameraBloc.controller!.value.isRecordingVideo)
                    BlocBuilder<CameraBloc, CameraState>(
                      builder: (context, state) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "${cameraBloc.selectedMinutes} MIN",
                                  style: const TextStyle(
                                    color: MyColors.primaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(
                                child: Row(
                                  children: [
                                    const Icon(Icons.circle,
                                        color: Colors.red, size: 18.0),
                                    const SizedBox(
                                        width: MySizes.horizontalSpace),
                                    Text(
                                      '${cameraBloc.minutes}:${cameraBloc.second}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              FlagCountWidget(
                                count: cameraBloc.flags.length,
                                color: MyColors.primaryColor,
                              ),
                              IconButton(
                                onPressed: () {
                                  cameraBloc.add(OpenFlashEvent(
                                    open: cameraBloc.flashOpened,
                                  ));
                                },
                                icon: Icon(
                                  cameraBloc.flashOpened
                                      ? Icons.flash_on
                                      : Icons.flash_off_outlined,
                                  color: cameraBloc.flashOpened
                                      ? Colors.yellowAccent
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.all(MySizes.widgetSideSpace),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BlocBuilder<CameraBloc, CameraState>(
                            builder: (context, state) {
                              return ZoomWidget(cameraBloc: cameraBloc);
                            },
                          ),
                          BlocBuilder<CameraBloc, CameraState>(
                            builder: (context, state) {
                              return ActionsWidget(cameraBloc: cameraBloc);
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            : const LoadingWidget(),
      ),
    );
  }
}
