import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class FlagCountWidget extends StatelessWidget {
  final int count;
  final Color? color;
  final bool? isUploaded;

  const FlagCountWidget({
    Key? key,
    required this.count,
    this.color,
    this.isUploaded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 5,
        right: 5,
        top: 3,
        bottom: 3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MySizes.radius),
        border: Border.fromBorderSide(
          BorderSide(
            color: isUploaded == true
                ? Colors.green
                : color != null
                    ? color!
                    : MyColors.primaryColor,
            width: MySizes.borderWidth,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$count",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: isUploaded == true
                      ? Colors.green
                      : color != null
                          ? color!
                          : MyColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 5.0),
          Icon(
            Icons.flag,
            color: isUploaded == true
                ? Colors.green
                : color != null
                    ? color!
                    : MyColors.primaryColor,
            size: 16,
          ),
        ],
      ),
    );
  }
}
