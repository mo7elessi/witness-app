import 'package:flutter/material.dart';
class EmptyVideoListWidget extends StatelessWidget {
  const EmptyVideoListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Image(
        image: AssetImage("assets/images/empty_list.png"),
        height: 50,
      ),
    );
  }
}
