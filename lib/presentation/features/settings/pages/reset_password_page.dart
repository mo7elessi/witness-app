import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/core/routes/routes.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/presentation/features/profile/bloc/user_bloc.dart';
import 'package:nice_shot/presentation/widgets/error_widget.dart';
import 'package:nice_shot/presentation/widgets/form_widget.dart';
import 'package:nice_shot/presentation/widgets/loading_widget.dart';
import 'package:nice_shot/presentation/widgets/primary_button_widget.dart';
import 'package:nice_shot/presentation/widgets/snack_bar_widget.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var oldPasswordController = TextEditingController();
    var newPasswordController = TextEditingController();
    var confirmPasswordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
        appBar: AppBar(
          title: const Text("RESET PASSWORD"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(MySizes.widgetSideSpace),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: FormWidget(
                  route: Routes.resetPassword,
                  passwordController: oldPasswordController,
                  newPasswordController: newPasswordController,
                  confirmPasswordController: confirmPasswordController,
                  context: context,
                  resetPassword: true,
                ),
              ),
              const SizedBox(height: MySizes.verticalSpace * 2),
              BlocConsumer<UserBloc, UserState>(listener: (context, state) {
                if (state.resetPasswordState == RequestState.loaded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    snackBarWidget(
                      message: state.message!,
                    ),
                  );
                }
              }, builder: (context, state) {
                switch (state.resetPasswordState) {
                  case RequestState.loading:
                    return const LoadingWidget();

                  case RequestState.error:
                    return ErrorMessageWidget(message: "${state.message}");
                  default:
                    return Column(
                      children: [
                        PrimaryButtonWidget(
                          function: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<UserBloc>().add(
                                    ResetPasswordEvent(
                                      oldPassword: oldPasswordController.text,
                                      newPassword: newPasswordController.text,
                                    ),
                                  );
                            }
                          },
                          text: "reset",
                        ),
                      ],
                    );
                }
              })
            ],
          ),
        ));
  }
}
