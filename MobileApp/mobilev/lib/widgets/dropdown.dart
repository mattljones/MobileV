// Dart & Flutter imports
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/config/constants.dart';

class MyDropdown extends StatelessWidget {
  final List<String> items;
  final String prompt;
  final String? dropdownValue;
  final void Function(String?)? onChanged;

  MyDropdown(
      {required this.items,
      required this.prompt,
      required this.dropdownValue,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton(
        hint: Text(prompt),
        value: dropdownValue,
        style: TextStyle(
          color: kPrimaryTextColour,
          fontSize: 16.0,
        ),
        icon: Icon(Icons.keyboard_arrow_down_outlined),
        underline: Container(
          height: 2,
          color: kSecondaryTextColour,
        ),
        onChanged: onChanged,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
