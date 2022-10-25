import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension extString on String {
  bool get isValidEmail {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(this);
  }

  bool get isValidName {
    final nameRegExp =
        RegExp(r"^\s*[A-Za-z]");
    return nameRegExp.hasMatch(this);
  }

  bool get isValidPassword {
    final passwordRegExp = RegExp(r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$");
    return passwordRegExp.hasMatch(this);
  }

  bool get isNotNull {
    return this != null;
  }

  bool get isValidPhone {
    final phoneRegExp = RegExp(r"[0-9]{10}$");
    return phoneRegExp.hasMatch(this);
  }

  bool get isValidDate {
    final dateRegExp = RegExp("[0-9/]");
    return dateRegExp.hasMatch(this);
  }
}

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboard;
  final Function(String) validator;
  final String hint;
  final IconData? prefixIcon;
  final bool isPassword;
  final bool isClick;
  final IconData? suffixIcon;
  final Function? onTap;
  final Function? suffixIconPressed;
  final Function? onSubmit;
  final Function? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const TextFieldWidget({
    Key? key,
    required this.controller,
    required this.keyboard,
    required this.validator,
    required this.hint,
    this.prefixIcon,
    this.isPassword = false,
    this.isClick = true,
    this.suffixIcon,
    this.onTap,
    this.suffixIconPressed,
    this.inputFormatters,
    this.onSubmit,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: inputFormatters,
      controller: controller,
      keyboardType: keyboard,
      obscureText: isPassword,
      enabled: isClick,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
              color: Colors.grey,
            ),
        prefixIcon: Icon(prefixIcon),
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon), onPressed: () => suffixIconPressed!())
            : null,
      ),
      onTap: () => onTap!(),
      validator: (value) => validator(value!),
      onFieldSubmitted: (value) => onSubmit ?? (value),
      onChanged: (value) => onChanged ?? (value),
    );
  }
}
