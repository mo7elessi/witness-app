import 'package:flutter/material.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/presentation/features/auth/widgets/wrapper.dart';

import '../../../../core/routes/routes.dart';
import '../../../widgets/form_widget.dart';
import '../../../widgets/primary_button_widget.dart';
import '../../../widgets/secondary_button_widget.dart';

class VerifyCodePage extends StatelessWidget {
  const VerifyCodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController codeController = TextEditingController();
    return WrapperWidget(
        title: "Verify code",
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "A 6-digit message has been sent to the number:",
              style: Theme.of(context).textTheme.bodyText2,
            ),
            const SizedBox(height: MySizes.verticalSpace),
            Text(
              "+972 59 2879633",
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: MySizes.verticalSpace),
            FormWidget(
              route: Routes.verifyCodePage,
              codeController: codeController,
              context: context,
            ),
            const SizedBox(height: MySizes.verticalSpace),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {},
                child: const Text("Re-send code"),
              ),
            ),
            const SizedBox(height: MySizes.verticalSpace),
            PrimaryButtonWidget(
              function: () {},
              text: "verify",
            ),
            const SizedBox(height: MySizes.verticalSpace),
            SecondaryButtonWidget(
              function: () => Navigator.pop(context),
              text: "change phone",
            ),
          ],
        ));
  }
}
