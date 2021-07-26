import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  final String text;
  final Color colour;
  final String goToRoute;

  FormButton(
      {required this.text, required this.colour, required this.goToRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: double.infinity,
      height: 55.0,
      color: colour,
      onPressed: () {
        Navigator.pushReplacementNamed(context, goToRoute);
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
