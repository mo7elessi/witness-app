import 'package:flutter/material.dart';
import 'package:nice_shot/core/themes/app_theme.dart';

import '../../../widgets/logo.dart';

class WrapperWidget extends StatelessWidget {
  final String title;
  final Widget body;

  const WrapperWidget({
    Key? key,
    required this.title,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(MySizes.widgetSideSpace),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Spacer(),
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage("assets/images/defaultVideoImage.png"),
                    ),
                  ],
                ),
                const SizedBox(height: MySizes.verticalSpace),
                body,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
