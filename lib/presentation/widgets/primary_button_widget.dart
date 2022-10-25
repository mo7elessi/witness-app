import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:flutter/material.dart';

class PrimaryButtonWidget extends StatelessWidget {
  final double? width;
  final Color? background;
  final Function function;
  final String text;

  const PrimaryButtonWidget({
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
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(MySizes.radius),
      ),
      child: MaterialButton(
        onPressed: () => function(),
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.button!.copyWith(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
