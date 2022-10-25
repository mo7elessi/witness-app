import 'package:flutter/material.dart';
import '../../../../core/util/my_box_decoration.dart';

class UploadButtonWidget extends StatelessWidget {
  final Function function;
  final Color? color;

  const UploadButtonWidget(
      {Key? key,
      required this.function,
       this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: (){},
          onTap: () => function(),
          child: Container(
            decoration: myBoxDecoration.copyWith(color: color),
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.upload),
                Text(
                  "UPLOAD",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
