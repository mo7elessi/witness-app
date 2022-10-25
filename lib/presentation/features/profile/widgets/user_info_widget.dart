import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/util/my_box_decoration.dart';

class UserInfoWidget extends StatelessWidget {
  final String text;
  final String? info;

  const UserInfoWidget({
    Key? key,
    required this.text,
    required this.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: myBoxDecoration,
      padding: const EdgeInsets.all(MySizes.widgetSideSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: MySizes.verticalSpace),
          Text(
            info ?? "Not found",
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
