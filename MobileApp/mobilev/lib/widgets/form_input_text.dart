// Dart & Flutter imports
import 'package:flutter/material.dart';

class FormInputText extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureInput;
  final TextInputType keyboard;
  final String? Function(String?)? validator;

  FormInputText(
      {required this.controller,
      required this.label,
      required this.icon,
      required this.obscureInput,
      required this.keyboard,
      this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon),
          labelText: label),
      style: TextStyle(fontSize: 20.0),
      obscureText: obscureInput,
      keyboardType: keyboard,
    );
  }
}
