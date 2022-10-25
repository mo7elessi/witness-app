// ignore_for_file: must_be_immutable

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:nice_shot/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:nice_shot/presentation/widgets/snack_bar_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../core/themes/app_theme.dart';
import '../../logic/ui_bloc/ui_bloc.dart';
import '../features/auth/bloc/auth_bloc.dart';
import 'text_field_widget.dart';

enum Inputs {
  username,
  email,
  phone,
  password,
  image,
  code,
  promoCode,
  gender,
  dob,
  confirmPassword,
  newPassword,
  nationality,
  profile,
}

class FormWidget extends StatelessWidget {
  TextEditingController? usernameController;
  TextEditingController? emailController;
  TextEditingController? passwordController;
  TextEditingController? phoneController;
  TextEditingController? codeController;
  TextEditingController? promoCodeController;
  TextEditingController? dobController;
  TextEditingController? confirmPasswordController;
  TextEditingController? nationalityController;
  TextEditingController? newPasswordController;
  final BuildContext context;
  final String route;
  bool? isRegister;
  bool? resetPassword;

  FormWidget({
    Key? key,
    this.emailController,
    this.phoneController,
    this.passwordController,
    this.usernameController,
    this.codeController,
    this.promoCodeController,
    this.dobController,
    required this.context,
    this.confirmPasswordController,
    this.nationalityController,
    this.newPasswordController,
    required this.route,
    this.isRegister = false,
    this.resetPassword = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _forms(),
    );
  }

  List<Widget> _forms() {
    if (route == Routes.loginPage) {
      return [
        textFields(Inputs.email),
        const SizedBox(height: MySizes.verticalSpace),
        textFields(Inputs.password),
      ];
    } else if (route == Routes.profilePage) {
      return [
        textFields(Inputs.image),
      ];
    } else if (route == Routes.resetPassword) {
      return [
        textFields(Inputs.password),
        const SizedBox(height: MySizes.verticalSpace),
        textFields(Inputs.newPassword),
        const SizedBox(height: MySizes.verticalSpace),
        textFields(Inputs.confirmPassword),
      ];
    } else if (route == Routes.registerPage) {
      return [
        textFields(Inputs.image),
        const SizedBox(height: MySizes.verticalSpace),
        textFields(Inputs.username),
        const SizedBox(height: MySizes.verticalSpace),
        textFields(Inputs.email),
        const SizedBox(height: MySizes.verticalSpace),
        textFields(Inputs.phone),
        const SizedBox(height: MySizes.verticalSpace),
        Row(
          children: [
            Expanded(child: textFields(Inputs.dob)),
            const SizedBox(width: MySizes.horizontalSpace),
            Expanded(child: textFields(Inputs.nationality)),
          ],
        ),
        const SizedBox(height: MySizes.verticalSpace),
        textFields(Inputs.password),
        const SizedBox(height: MySizes.verticalSpace),
        textFields(Inputs.confirmPassword),
      ];
    } else if (route == Routes.editProfilePage) {
      return [
        textFields(Inputs.username),
        const SizedBox(height: MySizes.verticalSpace),
        textFields(Inputs.email),
        const SizedBox(height: MySizes.verticalSpace),
        textFields(Inputs.phone),
        const SizedBox(height: MySizes.verticalSpace),
        Row(
          children: [
            Expanded(child: textFields(Inputs.dob)),
            const SizedBox(width: MySizes.horizontalSpace),
            Expanded(child: textFields(Inputs.nationality)),
          ],
        ),
      ];
    } else if (route == Routes.verifyEmailPage) {
      return [
        textFields(Inputs.email),
      ];
    } else if (route == Routes.verifyCodePage) {
      return [
        textFields(Inputs.code),
      ];
    } else if (route == Routes.resetPasswordPage) {
      return [
        textFields(Inputs.password),
      ];
    }
    return [
      textFields(Inputs.username),
    ];
  }

  Widget textFields(Inputs e) {
    switch (e) {
      case Inputs.username:
        return TextFieldWidget(
          controller: usernameController!,
          hint: 'Enter name',
          keyboard: TextInputType.text,
          prefixIcon: Icons.person,
          validator: (value) {
            if (value.isEmpty) {
              return ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                message: "Enter your name",
              ));
            } else if (!value.isValidName) {
              return ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                message: "Enter a valid name",
              ));
            }
          },
          onTap: () {},
        );
      case Inputs.email:
        return TextFieldWidget(
          controller: emailController!,
          hint: 'Enter email',
          keyboard: TextInputType.emailAddress,
          prefixIcon: Icons.email,
          validator: (value) {
            if (value.isEmpty) {
              return ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                message: "Enter your email",
              ));
            } else if (!value.isValidEmail) {
              return ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                message: "Enter a valid email",
              ));
            }
          },
          onTap: () {},
        );
      case Inputs.nationality:
        return TextFieldWidget(
          controller: nationalityController!,
          hint: 'Enter nationality',
          keyboard: TextInputType.text,
          prefixIcon: Icons.home_sharp,
          validator: (value) {
            if (value.isEmpty) {
              return ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                message: "Enter your nationality",
              ));
            } else if (!value.isValidName) {
              return ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                message: "Enter a valid nationality",
              ));
            }
          },
          onTap: () {},
        );
      case Inputs.phone:
        return TextFieldWidget(
          controller: phoneController!,
          hint: 'Enter mobile number',
          keyboard: TextInputType.phone,
          prefixIcon: Icons.phone,
          validator: (value) {
            if (value.isEmpty) {
              return ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                message: "Enter your mobile number",
              ));
            } else if (!value.isValidPhone) {
              return ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                message: "Enter a valid mobile number",
              ));
            }
          },
          onTap: () {},
        );
      // return IntlPhoneField(
      //   initialCountryCode: 'IN',
      //   controller: phoneController,
      //   disableLengthCheck: true,
      //   pickerDialogStyle: PickerDialogStyle(
      //     countryNameStyle: Theme.of(context).textTheme.bodySmall,
      //     countryCodeStyle: Theme.of(context).textTheme.bodySmall,
      //     listTileDivider: Container(),
      //     searchFieldInputDecoration: const InputDecoration(
      //       hintText: 'search',
      //       border: OutlineInputBorder(),
      //     ),
      //   ),
      //   showCountryFlag: true,
      //   decoration: const InputDecoration(
      //     border: OutlineInputBorder(),
      //   ),
      //   onChanged: (phone) {},
      //   onCountryChanged: (country) {},
      // );
      case Inputs.password:
        return Builder(builder: (context) {
          context.read<UiBloc>().add(
                ChangeIconSuffixEvent(isPassword: false),
              );
          return BlocConsumer<UiBloc, UiState>(
            listener: (context, state) {
              // if (state.showPassword) {
              //   isPassword = !isPassword;
              // }
            },
            builder: (context, state) {
              return TextFieldWidget(
                controller: passwordController!,
                hint: 'Enter password',
                keyboard: TextInputType.text,
                prefixIcon: Icons.lock,
                isPassword: context.read<UiBloc>().isPassword,
                suffixIcon: state.icon,
                suffixIconPressed: () {
                  context.read<UiBloc>().add(
                        ChangeIconSuffixEvent(
                          isPassword: context.read<UiBloc>().isPassword,
                        ),
                      );
                },
                validator: (value) {
                  if (isRegister == true) {
                    if (value.isEmpty) {
                      return ScaffoldMessenger.of(context)
                          .showSnackBar(snackBarWidget(
                        message: "Enter the password",
                      ));
                    } else if (!value.isValidPassword) {
                      return ScaffoldMessenger.of(context)
                          .showSnackBar(snackBarWidget(
                        message:
                            "The password must contain at least eight characters, at least one letter and one number",
                      ));
                    }
                  } else if (value.isEmpty) {
                    return ScaffoldMessenger.of(context)
                        .showSnackBar(snackBarWidget(
                      message: "Enter the password",
                    ));
                  }
                },
                onTap: () {},
              );
            },
          );
        });
      case Inputs.confirmPassword:
        return TextFieldWidget(
          controller: confirmPasswordController!,
          hint: 'Confirm password',
          keyboard: TextInputType.text,
          prefixIcon: Icons.lock,
          isPassword: true,
          validator: (value) {
            if (value.isEmpty) {
              return ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                message: "Confirm password",
              ));
            } else if (value !=
                (resetPassword == true
                    ? newPasswordController!.text
                    : passwordController!.text)) {
              return ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                message: "Passwords do not match",
              ));
            }
          },
          onTap: () {},
        );
      case Inputs.newPassword:
        return TextFieldWidget(
          controller: newPasswordController!,
          hint: 'New password',
          keyboard: TextInputType.text,
          prefixIcon: Icons.lock,
          isPassword: true,
          validator: (value) {
            if (value.isEmpty) {
              return ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                message: "Enter new password",
              ));
            } else if (!value.isValidPassword) {
              return ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                message:
                    "The password must contain at least eight characters, at least one letter and one number:",
              ));
            }
          },
          onTap: () {},
        );
      case Inputs.dob:
        return TextFieldWidget(
          controller: dobController!,
          hint: 'Enter date of birth',
          keyboard: TextInputType.datetime,
          prefixIcon: Icons.date_range_rounded,
          validator: (value) {
            if (value.isEmpty) {
              return ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                message: "Enter date of birth",
              ));
            } else if (!value.isValidDate) {
              return ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                message: "Enter a valid date of birth",
              ));
            }
          },
          onTap: () {
            showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.parse('1900-01-01'),
              lastDate: DateTime.now(),
            ).then((value) {
              dobController!.text = DateFormat().add_yMd().format(value!);
            });
          },
        );
      case Inputs.image:
        return BlocBuilder<UiBloc, UiState>(
          builder: (context, state) {
            return Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  height: MySizes.imageHeight,
                  width: MySizes.imageWidth,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(MySizes.imageRadius),
                      image: state.file != null
                          ? DecorationImage(
                              image: FileImage(state.file!),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage(
                                "assets/images/defaultImage.jpg",
                              ),
                              fit: BoxFit.cover,
                            )),
                ),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.all(MySizes.verticalSpace),
                    decoration: BoxDecoration(
                      color: MyColors.primaryColor,
                      borderRadius: BorderRadius.circular(MySizes.imageRadius),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  onTap: () => context.read<UiBloc>().add(
                        PickUserImageEvent(),
                      ),
                ),
              ],
            );
          },
        );
      case Inputs.code:
        return SizedBox(
          height: 55,
          child: PinCodeTextField(
            length: 6,
            obscureText: false,
            enablePinAutofill: false,
            pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(MySizes.radius),
                fieldHeight: 55,
                fieldWidth: 55,
                borderWidth: .3,
                activeColor: MyColors.borderColor,
                selectedColor: MyColors.primaryColor,
                inactiveColor: MyColors.borderColor),
            backgroundColor: MyColors.backgroundColor,
            animationDuration: const Duration(milliseconds: 300),
            controller: codeController,
            onCompleted: (v) {},
            onChanged: (value) {},
            beforeTextPaste: (text) {
              return true;
            },
            appContext: context,
          ),
        );
      case Inputs.promoCode:
        return Container();
      default:
        return Container();
    }
  }
}
