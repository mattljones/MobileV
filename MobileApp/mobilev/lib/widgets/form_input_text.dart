import 'package:flutter/material.dart';

class FormInputText extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscureInput;
  final TextInputType keyboard;

  FormInputText(
      {required this.label,
      required this.icon,
      required this.obscureInput,
      required this.keyboard});

  @override
  Widget build(BuildContext context) {
    return TextField(
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
