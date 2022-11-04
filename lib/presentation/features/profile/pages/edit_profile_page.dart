import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/core/routes/routes.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/data/model/api/User_model.dart';
import 'package:nice_shot/presentation/features/profile/bloc/user_bloc.dart';
import 'package:nice_shot/presentation/widgets/form_widget.dart';
import 'package:nice_shot/presentation/widgets/loading_widget.dart';
import 'package:nice_shot/presentation/widgets/primary_button_widget.dart';
import '../../../widgets/snack_bar_widget.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController dobController = TextEditingController();
    TextEditingController nationalityController = TextEditingController();
    return Scaffold(
        appBar: AppBar(
          title: const Text("EDIT PROFILE"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(MySizes.widgetSideSpace),
          child: Column(
            children: [
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  UserModel? user = state.user!.data;
                  usernameController.text = user?.name ?? "";
                  phoneController.text = user?.mobile ?? "";
                  emailController.text = user?.email ?? "";
                  dobController.text = user?.birthDate ?? "";
                  nationalityController.text = user?.nationality ?? "";

                  return FormWidget(
                    route: Routes.editProfilePage,
                    phoneController: phoneController,
                    usernameController: usernameController,
                    emailController: emailController,
                    dobController: dobController,
                    nationalityController: nationalityController,
                    context: context,
                  );
                },
              ),
              const SizedBox(height: MySizes.verticalSpace * 2),
              BlocConsumer<UserBloc, UserState>(
                listener: (context, state) {
                  // if (state.updateDataState == RequestState.loaded ||
                  //     state.updateDataState == RequestState.error) {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     snackBarWidget(message: state.message!),
                  //   );
                  // }
                },
                builder: (context, state) {
                  if (state.updateDataState == RequestState.loading) {
                    return const LoadingWidget();
                  } else {
                    return Column(
                      children: [
                        PrimaryButtonWidget(
                          function: () {
                            UserModel? user = state.user!.data;

                            if (usernameController.text != user?.name ||
                                phoneController.text != user?.mobile ||
                                emailController.text != user?.email ||
                                dobController.text != user?.birthDate ||
                                nationalityController.text !=
                                    user?.nationality) {
                              context.read<UserBloc>().add(
                                UpdateUserDataEvent(
                                  user: UserModel(
                                    email: emailController.text,
                                    userName: usernameController.text
                                        .replaceAll(" ", "_")
                                        .toLowerCase(),
                                    nationality: nationalityController.text,
                                    mobile: phoneController.text
                                        .replaceAll("+", "")
                                        .trim(),
                                    birthDate: dobController.text,
                                    name: usernameController.text,
                                  ),
                                ),
                              );
                            }

                          },
                          text: "update",
                        ),
                      ],
                    );
                  }
                },
              )
            ],
          ),
        ));
  }
}
