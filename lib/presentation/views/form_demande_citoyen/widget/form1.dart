import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final double padding;
  String? error;
  final String? Function(String?)? validator;

  CustomTextField(
      {Key? key,
      required this.controller,
      required this.labelText,
      required this.prefixIcon,
      this.isPassword = false,
      this.padding = 0,
      this.validator,
      this.error})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                
                maxLines: null,
                validator: validator,
                controller: controller,
                obscureText: isPassword,
                decoration: InputDecoration(
                  prefixIcon: Icon(prefixIcon, color: const Color(0XFF1501A6)),
                  labelText: labelText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorText: error,
                ),
              ),
            ),
          ],
        ));
  }
}
