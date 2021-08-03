// Dart & Flutter imports
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/config/constants.dart';

final ThemeData theme = ThemeData(
  colorScheme: ColorScheme.light().copyWith(
    primary: kPrimaryColour,
    primaryVariant: kDarkPrimaryColour,
    secondary: kAccentColour,
    secondaryVariant: kDarkAccentColour,
  ),
  fontFamily: 'Roboto',
  dividerColor: Colors.transparent,
  tabBarTheme: TabBarTheme(
    labelColor: kPrimaryTextColour,
    unselectedLabelColor: kPrimaryTextColour,
    labelStyle: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 16.0,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 14.0,
    ),
  ),
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
