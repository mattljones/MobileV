// Dart & Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormInputNumber extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final String? initialValue;

  FormInputNumber({
    required this.controller,
    required this.label,
    this.validator,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      initialValue: initialValue,
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
          labelText: label),
      style: TextStyle(fontSize: 18.0),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
    );
  }
}
