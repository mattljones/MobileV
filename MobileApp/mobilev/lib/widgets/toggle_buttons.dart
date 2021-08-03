// Dart & Flutter imports
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/config/constants.dart';

class MyToggleButtons extends StatelessWidget {
  final List<String> fields;
  final List<bool> isSelected;
  final double fontSize;
  final void Function(int) onPressed;

  MyToggleButtons({
    required this.fields,
    required this.isSelected,
    required this.onPressed,
    this.fontSize = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(5.0),
        fillColor: kCardColour,
        selectedColor: Colors.black,
        selectedBorderColor: kSecondaryTextColour,
        constraints: BoxConstraints.tightFor(
            width: (MediaQuery.of(context).size.width - 70.0) / fields.length,
            height: 50.0),
        children: [
          for (String field in fields)
            Text(
              field,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isSelected[fields.indexOf(field)]
                      ? FontWeight.w700
                      : null),
            ),
        ],
        onPressed: onPressed,
        isSelected: isSelected,
      ),
    );
  }
}
