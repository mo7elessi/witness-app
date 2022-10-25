import 'package:flutter/material.dart';
import 'package:nice_shot/core/themes/app_theme.dart';

class FieldAlertDialogWidget extends StatelessWidget {
  final Function function;
  final TextEditingController controller;

  const FieldAlertDialogWidget({
    Key? key,
    required this.function,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(MySizes.widgetSideSpace),
      content: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              cursorColor: MyColors.primaryColor,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.title),
                labelText: 'Edit title',
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'SAVE',
            style: TextStyle(color: MyColors.primaryColor),
          ),
          onPressed: () => function(),
        ),
      ],
    );
  }
}
