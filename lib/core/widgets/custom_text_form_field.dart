import 'package:flutter/material.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  Function(String)? onSubmite,
  Function(String)? onChange,
  VoidCallback? onTap,
  bool isPassword = false,
  validate,
  String? lable,
  IconData? prefx,
  IconData? suffix,
  VoidCallback? suffixPassword,
  Color? fillcolor,
  bool? isfilled,
  double borderradius = 4.0,
  String hint = " ",
  Color? iconColor,
  Color? textColor,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      onTap: onTap,
      onChanged: onChange,
      onFieldSubmitted: onSubmite,
      validator: validate,
      decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textColor),
          fillColor: fillcolor,
          filled: isfilled,
          labelText: lable,
          prefixIcon: prefx == null
              ? null
              : Icon(
                  prefx,
                  color: iconColor,
                ),
          suffixIcon: IconButton(
            onPressed: suffixPassword,
            icon: Icon(
              suffix,
              color: iconColor,
            ),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(borderradius)))),
    );