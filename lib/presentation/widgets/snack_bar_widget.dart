import 'package:flutter/material.dart';
import 'package:nice_shot/core/themes/app_theme.dart';

SnackBar snackBarWidget({
  required String message,
  String? label,
  Function? onPressed,
}) {
  return SnackBar(
    elevation: MySizes.elevation,
    content: Text(
      message,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12.5,
      ),
    ),
    action: SnackBarAction(
      onPressed: () => onPressed == null ? {} : onPressed(),
      label: label ?? "",
    ),
  );
}
