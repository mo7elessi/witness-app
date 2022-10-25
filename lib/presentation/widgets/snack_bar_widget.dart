import 'package:flutter/material.dart';

SnackBar snackBarWidget(
    {required String message, String? label, Function? onPressed}) {
  return SnackBar(
    content: Text(message),
    action: SnackBarAction(
      onPressed: () =>  onPressed == null? {}:onPressed(),
      label: label ?? "",
    ),
  );
}
