import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(MySizes.widgetSideSpace),
      child: SizedBox(
        width: double.infinity,
        child: Image(image: AssetImage("assets/images/red_logo.png")),
      ),
    );
  }
}
