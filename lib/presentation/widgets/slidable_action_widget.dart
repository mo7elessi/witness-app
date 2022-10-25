import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/core/util/my_box_decoration.dart';

class ActionWidget extends StatelessWidget {
  final IconData icon;
  final Function function;
  final String title;

  const ActionWidget({
    Key? key,
    required this.icon,
    required this.function,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => function(),
      child: ListTile(
        leading: Icon(icon,color: Colors.black54),
        title: Text(title),
      ),
    );
  }
}
