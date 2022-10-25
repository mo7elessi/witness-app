import 'package:flutter/material.dart';

PreferredSizeWidget appBarWidget({required String title}) {
  return AppBar(
    title: Text(title.toUpperCase()),
    actions: [],
  );
}
