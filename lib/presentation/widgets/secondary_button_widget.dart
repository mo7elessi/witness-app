import 'package:flutter/material.dart';
import 'package:nice_shot/core/util/my_box_decoration.dart';

import '../../core/themes/app_theme.dart';

class SecondaryButtonWidget extends StatelessWidget {
  final double? width;
  final Color? background;
  final Function function;
  final String text;

  const SecondaryButtonWidget({
    Key? key,
    this.width = double.infinity,
    this.background = MyColors.primaryColor,
    required this.function,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: MySizes.buttonHeight,
      decoration: myBoxDecoration.copyWith(
        color: MyColors.scaffoldBackgroundColor,
        border: const Border.fromBorderSide(
          BorderSide(
            color: MyColors.primaryColor,
            width: MySizes.borderWidth,
          ),
        ),
      ),
      child: OutlinedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(
                side: BorderSide(
              color: MyColors.primaryColor,
            )),
          ),
        ),
        onPressed: () => function(),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }
}
