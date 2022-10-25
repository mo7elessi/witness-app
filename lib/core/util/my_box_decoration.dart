import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

BoxDecoration myBoxDecoration = BoxDecoration(
  color: MyColors.backgroundColor,
  borderRadius: BorderRadius.circular(MySizes.radius),
  border: const Border.fromBorderSide(
    BorderSide(
      color: MyColors.borderColor,
      width: MySizes.borderWidth,
    ),
  ),
);
