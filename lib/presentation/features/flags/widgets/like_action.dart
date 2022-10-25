import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';

class LikeActionWidget extends StatelessWidget {
  final IconData icon;
  final bool? isLike;
  final bool value;
  final Function function;

  const LikeActionWidget({
    Key? key,
    required this.icon,
    required this.isLike,
    required this.value,
    required this.function,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Icon(
        icon,
        color: isLike == value ? MyColors.primaryColor : Colors.grey,
        size: 28,
      ),
      onTap: () => function(),
    );
  }
}
