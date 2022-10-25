import 'package:flutter/material.dart';
import 'package:nice_shot/core/themes/app_theme.dart';

class ErrorMessageWidget extends StatelessWidget {
  final String message;
  final IconData? icon;

  const ErrorMessageWidget({
    Key? key,
    required this.message,
     this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.backgroundColor,
      padding: const EdgeInsets.all(MySizes.widgetSideSpace),
      child: Text(message),
    );
  }
}
