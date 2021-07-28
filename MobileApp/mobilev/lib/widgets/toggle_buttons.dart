import 'package:flutter/material.dart';
import 'package:mobilev/config/constants.dart';

class MyToggleButtons extends StatelessWidget {
  final List<String> fields;
  final List<bool> isSelected;
  final void Function(int) onPressed;

  MyToggleButtons(
      {required this.fields,
      required this.isSelected,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(5.0),
        selectedBorderColor: kPrimaryColour,
        constraints: BoxConstraints.tightFor(
            width: (MediaQuery.of(context).size.width - 70.0) / fields.length,
            height: 50.0),
        children: [
          for (String field in fields)
            Text(
              field,
              style: TextStyle(
                  fontSize: 18.0,
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
