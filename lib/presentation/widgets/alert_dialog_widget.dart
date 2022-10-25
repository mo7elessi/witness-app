import 'package:flutter/material.dart';

class AlertDialogWidget extends StatelessWidget {
  final Function function;
  final String message;
  final String title;

  const AlertDialogWidget({
    Key? key,
    required this.message,
    required this.title,
    required this.function,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.all(4.0),
      alignment: AlignmentDirectional.center,
      title: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
      ),
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyText2,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "NO",
                  style: TextStyle(color: Colors.grey),
                )),
            TextButton(
                onPressed: () {
                  function();
                },
                child: const Text("YES")),
          ],
        ),
        // Row(
        //   children: [
        //     Expanded(
        //         child: SecondaryButtonWidget(
        //       function: () => Navigator.pop(context),
        //       text: "NO",
        //     )),
        //     const SizedBox(width: 5.0),
        //     Expanded(
        //         child: PrimaryButtonWidget(
        //       function: () => function(),
        //       text: "YES",
        //     )),
        //   ],
        // ),
      ],
    );
  }
}
