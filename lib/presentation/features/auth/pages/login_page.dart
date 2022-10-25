import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/core/routes/routes.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:nice_shot/presentation/features/auth/widgets/wrapper.dart';
import 'package:nice_shot/presentation/widgets/form_widget.dart';
import 'package:nice_shot/presentation/widgets/loading_widget.dart';
import 'package:nice_shot/presentation/widgets/primary_button_widget.dart';
import 'package:nice_shot/presentation/widgets/secondary_button_widget.dart';
import 'package:nice_shot/presentation/widgets/snack_bar_widget.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return WrapperWidget(
        title: "Login",
        body: Column(
          children: [
            Form(
              key: _formKey,
              child: FormWidget(
                route: Routes.loginPage,
                emailController: emailController,
                passwordController: passwordController,
                context: context,
              ),
            ),
            const SizedBox(height: MySizes.verticalSpace),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state.loginState == RequestState.loaded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    snackBarWidget(message: state.message!),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.homePage,
                    (route) => false,
                  );

                }
              },
              builder: (context, state) {
                switch (state.loginState) {
                  case RequestState.loading:
                    return const LoadingWidget();
                  case RequestState.loaded:
                    break;
                  case RequestState.error:
                    SchedulerBinding.instance.addPostFrameCallback((_) async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBarWidget(message: state.message!),
                      );
                    });
                    break;
                  default:
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PrimaryButtonWidget(
                      function: () async {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                                LoginEvent(
                                  email: emailController.text,
                                  password: passwordController.text,
                                ),
                              );
                        }
                      },
                      text: "login",
                    ),
                    const SizedBox(height: MySizes.verticalSpace),
                    SecondaryButtonWidget(
                      function: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        Routes.registerPage,
                        (route) => false,
                      ),
                      text: "register",
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
