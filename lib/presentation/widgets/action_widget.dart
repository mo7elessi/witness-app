import 'package:flutter/material.dart';

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
        leading: Icon(icon, color: Colors.black54),
        title: Text(title),
      ),
    );
  }
}
