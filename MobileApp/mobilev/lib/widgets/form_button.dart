import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  final String text;
  final Color buttonColour;
  final Color textColour;
  final String goToRoute;

  FormButton(
      {required this.text,
      required this.buttonColour,
      required this.textColour,
      required this.goToRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: double.infinity,
      height: 55.0,
      color: buttonColour,
      onPressed: () {
        Navigator.pushReplacementNamed(context, goToRoute);
      },
      child: Text(
        text,
        style: TextStyle(
          color: textColour,
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
