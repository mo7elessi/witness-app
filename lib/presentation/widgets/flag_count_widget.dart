import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class FlagCountWidget extends StatelessWidget {
  final int count;
  final Color? color;

  const FlagCountWidget({
    Key? key,
    required this.count,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 5,
        right: 5,
        top: 2,
        bottom: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        border: Border.fromBorderSide(
          BorderSide(
            color: color != null ? color! : MyColors.primaryColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$count",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: color != null ? color! : MyColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 5.0),
          Icon(
            Icons.flag,
            color: color != null ? color! : MyColors.primaryColor,
            size: 16,
          ),
        ],
      ),
    );
  }
}
