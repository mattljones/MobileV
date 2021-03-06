// coverage:ignore-file

// Dart & Flutter imports
import 'package:flutter/material.dart';

// Theme colours
const kPrimaryColour = Color(0xFF3F51B5);
const kDarkPrimaryColour = Color(0xFF303F9F);
const kAccentColour = Color(0xFFCDDC39);
const kDarkAccentColour = Color(0xFFB9C91E);

// Other colours
const kLightPrimaryColour = Color(0xFF5467C6);
const kLightAccentColour = Color(0xFFCCD962);
const kBackgroundPrimaryColour = Color(0xFFEBEDF8);
const kTextIcons = Colors.white;
const kPrimaryTextColour = Color(0xFF212121);
const kSecondaryTextColour = Color(0xFF757575);
const kCardColour = Color(0xFFDEDEDE);

// Enumerated types
enum AnalysisStatus { unavailable, pending, received, failed }

// Helper maps
const analysisStatus = {
  'unavailable': AnalysisStatus.unavailable,
  'pending': AnalysisStatus.pending,
  'received': AnalysisStatus.received,
  'failed': AnalysisStatus.failed,
};

const days = {
  '1': 'Mondays',
  '2': 'Tuesdays',
  '3': 'Wednesdays',
  '4': 'Thursdays',
  '5': 'Fridays',
  '6': 'Saturdays',
  '7': 'Sundays',
};

const months = {
  '01': 'Jan',
  '02': 'Feb',
  '03': 'Mar',
  '04': 'Apr',
  '05': 'May',
  '06': 'Jun',
  '07': 'Jul',
  '08': 'Aug',
  '09': 'Sep',
  '10': 'Oct',
  '11': 'Nov',
  '12': 'Dec',
};

const fullMonths = {
  'Jan': 'January',
  'Feb': 'February',
  'Mar': 'March',
  'Apr': 'April',
  'May': 'May',
  'Jun': 'June',
  'Jul': 'July',
  'Aug': 'August',
  'Sep': 'September',
  'Oct': 'October',
  'Nov': 'November',
  'Dec': 'December',
};
