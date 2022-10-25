import 'package:flutter/material.dart';
import 'package:nice_shot/presentation/widgets/text_field_widget.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/util/my_box_decoration.dart';
import '../../../widgets/snack_bar_widget.dart';

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
    final usernameController = TextEditingController();
    return Container(
      decoration: myBoxDecoration,
      padding: const EdgeInsets.all(MySizes.widgetSideSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                text,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              // const Spacer(),
              // InkWell(
              //     onTap: () {
              //       showModalBottomSheet(
              //         enableDrag: true,
              //         context: context,
              //         backgroundColor: Colors.white,
              //         elevation: 8,
              //         isScrollControlled: true,
              //         shape: const RoundedRectangleBorder(
              //           borderRadius: BorderRadius.vertical(
              //             top: Radius.circular(10.0),
              //           ),
              //         ),
              //         builder: (context) {
              //           return SingleChildScrollView(
              //             child: Padding(
              //               padding: EdgeInsets.only(
              //                 bottom: MediaQuery.of(context).viewInsets.bottom,
              //               ),
              //               child: Container(
              //                 padding:
              //                     const EdgeInsets.all(MySizes.widgetSideSpace),
              //                 child: Column(
              //                   children: [
              //                     TextFieldWidget(
              //                       controller: usernameController,
              //                       hint: 'Enter new name',
              //                       keyboard: TextInputType.text,
              //                       prefixIcon: Icons.person,
              //                       validator: (value) {
              //                         if (value.isEmpty) {
              //                           return ScaffoldMessenger.of(context)
              //                               .showSnackBar(snackBarWidget(
              //                             message: "Enter your name",
              //                           ));
              //                         } else if (!value.isValidName) {
              //                           return ScaffoldMessenger.of(context)
              //                               .showSnackBar(snackBarWidget(
              //                             message: "Enter a valid name",
              //                           ));
              //                         }
              //                       },
              //                       onTap: () {},
              //                     ),
              //                     TextButton(
              //                       onPressed: () {},
              //                       child:const Text("SAVE"),
              //                     )
              //                   ],
              //                 ),
              //               ),
              //             ),
              //           );
              //         },
              //       );
              //     },
              //     child: const Icon(Icons.edit, size: 18))
            ],
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
