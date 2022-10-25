import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/core/util/my_box_decoration.dart';
import 'package:nice_shot/presentation/features/camera/bloc/bloc.dart';
import 'package:nice_shot/presentation/features/camera/widgets/settings_widget.dart';
import 'package:nice_shot/presentation/widgets/action_widget.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../../../core/functions/functions.dart';
import '../../../../core/themes/app_theme.dart';
import '../widgets/resolutions_widget.dart';

class CameraSettingsPage extends StatelessWidget {
  final CameraBloc cameraBloc;

  const CameraSettingsPage({
    Key? key,
    required this.cameraBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CAMERA SETTINGS"),
      ),
      body: BlocBuilder<CameraBloc, CameraState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(MySizes.widgetSideSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: boxDecoration,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "RESOLUTION",
                        style: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      ResolutionsWidget(cameraBloc: cameraBloc),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: boxDecoration,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "VIDEO DURATION",
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
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
                                          "VIDEO DURATION",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                      ],
                                    ),
                                    content:
                                        BlocBuilder<CameraBloc, CameraState>(
                                      builder: (context, state) {
                                        return NumberPicker(
                                            selectedTextStyle: const TextStyle(
                                              color: MyColors.primaryColor,
                                            ),
                                            value: cameraBloc
                                                .selectedDuration.inMinutes,
                                            minValue: 1,
                                            maxValue: 60,
                                            textStyle: const TextStyle(
                                                color: Colors.white60),
                                            itemWidth: 50,
                                            infiniteLoop: true,
                                            axis: Axis.horizontal,
                                            onChanged: (value) {
                                              cameraBloc.mainDuration =
                                                  Duration(minutes: value);
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
                                            color: Colors.white,
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
                            formatDurationByName(cameraBloc.selectedDuration),
                            style: const TextStyle(
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ]),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: boxDecoration,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "SHOT DURATION",
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            showDialog<int>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.black54,
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "SHOT DURATION",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                        const SizedBox(
                                          height: MySizes.verticalSpace,
                                        ),
                                        Text(
                                          "Select the duration of shot you want to tag, if you choose 10 seconds, 5 seconds before and 5 seconds after will be highlighted",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
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
                                              color: MyColors.primaryColor,
                                            ),
                                            value: cameraBloc
                                                .afterTimeShot.inSeconds,
                                            minValue: 10,
                                            step: 10,
                                            maxValue: 30,
                                            textStyle: const TextStyle(
                                                color: Colors.white60),
                                            infiniteLoop: true,
                                            axis: Axis.horizontal,
                                            onChanged: (value) {
                                              cameraBloc.afterTimeShot =
                                                  Duration(seconds: value);
                                              cameraBloc.add(
                                                ChangeSelectedShotDurationEvent(
                                                  after: true,
                                                    duration: Duration(
                                                        seconds: value)),
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
                            formatDurationByName(cameraBloc.afterTimeShot),
                            style: const TextStyle(
                              color: MyColors.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}
BoxDecoration boxDecoration = const BoxDecoration(
  color: MyColors.backgroundColor,
  border: Border.fromBorderSide(
    BorderSide(
      color: MyColors.borderColor,
      width: MySizes.borderWidth,
    ),
  ),
);
