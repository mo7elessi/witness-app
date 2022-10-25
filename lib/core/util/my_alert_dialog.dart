import 'package:flutter/material.dart';
import 'package:nice_shot/presentation/widgets/field_alert_dialog_widget.dart';

myAlertDialog({
  required BuildContext context,
  required Function function,
  required TextEditingController controller,
}) async {
  await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return FieldAlertDialogWidget(function: function, controller: controller);
    },
  ).then((value) => Navigator.pop(context));
}
