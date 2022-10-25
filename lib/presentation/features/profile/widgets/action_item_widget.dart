import 'package:flutter/material.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/core/util/my_box_decoration.dart';

class ActionItemWidget extends StatelessWidget {
  final IconData icon;
  final Function function;
  final String text;

  const ActionItemWidget({
    Key? key,
    required this.icon,
    required this.function,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => function(),
      child: Container(
        decoration: myBoxDecoration,
        padding: const EdgeInsets.all(MySizes.widgetSideSpace),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(width: MySizes.verticalSpace),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
