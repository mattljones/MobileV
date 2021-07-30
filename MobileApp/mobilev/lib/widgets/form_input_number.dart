import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormInputNumber extends StatelessWidget {
  final String label;
  FormInputNumber({required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
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
