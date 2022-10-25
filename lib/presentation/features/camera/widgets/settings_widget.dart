import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/presentation/features/camera/bloc/bloc.dart';
import 'package:nice_shot/presentation/features/camera/bloc/bloc.dart';

class SettingsWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final String value;
  final Function onTap;

  const SettingsWidget({
    Key? key,
    required this.icon,
    required this.text,
    required this.value,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        return InkWell(
          onTap: () => onTap(),
          child: Container(
            padding: const EdgeInsets.all(MySizes.widgetSideSpace),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(icon),
                const SizedBox(width: MySizes.horizontalSpace),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: MySizes.verticalSpace),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
