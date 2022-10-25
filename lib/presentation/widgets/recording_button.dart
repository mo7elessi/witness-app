import 'package:flutter/material.dart';
import 'package:nice_shot/core/themes/app_theme.dart';

class RecordingButtonWidget extends StatelessWidget {
  final Function onPressed;
  final IconData icon;

  const RecordingButtonWidget({
    Key? key,
    required this.onPressed,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: InkWell(
          onTap: () => onPressed(),
          child: Container(width: 70.0,height: 70.0,
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5.0)),
            child: Icon(
              icon,
              color: MyColors.primaryColor,
              size: 30 ,
            ),
          )),
    );
  }
}
