import 'package:flutter/material.dart';
import 'package:mobilev/config/constants.dart';

class MonthDropdown extends StatelessWidget {
  final List<String> months;
  final String? dropdownValue;
  final void Function(String?)? onChanged;

  MonthDropdown(
      {required this.months,
      required this.dropdownValue,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.only(top: 10.0),
        child: DropdownButton(
          hint: Text(
            'Select a month',
          ),
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
          items: months.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
