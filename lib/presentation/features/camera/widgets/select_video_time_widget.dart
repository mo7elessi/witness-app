import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import '../bloc/camera_bloc.dart';


class SelectVideoTimeWidget extends StatelessWidget {
  final CameraBloc cameraBloc;
  final List<int> times = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  SelectVideoTimeWidget({
    Key? key,
    required this.cameraBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      elevation: MySizes.elevation.toInt(),
      alignment: Alignment.topRight,
      dropdownColor: Colors.black54,
      underline: Container(),
      //   value: cameraBloc.currentResolutionPreset,
      items: [
        for (int time in times)
          DropdownMenuItem(
            alignment: Alignment.center,
            value: time,
            child: Text(
              "$time min",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.white),
            ),
          ),
      ],
      onChanged: (value) {},
    );
  }
}
