import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  final String text;
  final Color buttonColour;
  final Color textColour;
  final void Function() onPressed;
  final Icon? icon;

  FormButton(
      {required this.text,
      required this.buttonColour,
      required this.textColour,
      required this.onPressed,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: double.infinity,
      height: 55.0,
      color: buttonColour,
      onPressed: onPressed,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: textColour,
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (icon != null)
            Align(
              alignment: Alignment.centerRight,
              child: Container(child: icon),
            )
        ],
      ),
    );
  }
}
