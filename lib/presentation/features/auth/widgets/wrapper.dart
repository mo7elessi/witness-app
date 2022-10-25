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
              //  const LogoWidget(),
              //  const SizedBox(height: MySizes.verticalPadding),
                Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Divider(
                  height: 5,
                  color: MyColors.primaryColor,
                  thickness: 5,
                  endIndent: 310,
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
