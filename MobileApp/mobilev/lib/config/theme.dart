import 'package:flutter/material.dart';
import 'package:mobilev/config/styles.dart';

final ThemeData theme = ThemeData(
  colorScheme: ColorScheme.light().copyWith(
    primary: kPrimaryColour,
    primaryVariant: kDarkPrimaryColour,
    secondary: kAccentColour,
    secondaryVariant: kDarkAccentColour,
  ),
  fontFamily: 'Roboto',
  dividerColor: Colors.transparent,
  appBarTheme: AppBarTheme(
    color: kPrimaryColour,
    textTheme: TextTheme(
      headline6: TextStyle(
        fontFamily: 'PTSans',
        fontWeight: FontWeight.w700,
        fontSize: 23.0,
      ),
    ),
  ),
);
