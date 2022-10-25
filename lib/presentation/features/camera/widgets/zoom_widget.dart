import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/presentation/features/camera/bloc/camera_bloc.dart';

import '../bloc/camera_event.dart';

class ZoomWidget extends StatelessWidget {
  final CameraBloc cameraBloc;

  const ZoomWidget({required this.cameraBloc, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(MySizes.radius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(MySizes.verticalSpace),
            child: Text(
              '${cameraBloc.currentZoomLevel.toStringAsFixed(1)}x',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.white),
            ),
          ),
        ),
        Slider.adaptive(
          value: cameraBloc.currentZoomLevel,
          min: cameraBloc.minAvailableZoom,
          max: cameraBloc.maxAvailableZoom,
          activeColor: Colors.white,
          inactiveColor: Colors.white30,
          onChanged: (value) async {
            cameraBloc.add(
              ChangeZoomLeveEvent(currentZoomLevel: value),
            );

            await cameraBloc.controller!.setZoomLevel(value);
          },
        ),

      ],
    );
  }
}
