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

final String testTranscript =
    '''Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur nec mi metus. Donec tristique odio vitae purus eleifend venenatis. Morbi ut eros in sapien dapibus tempor rhoncus at risus. Etiam scelerisque turpis eros, vitae tincidunt enim posuere vel. Nullam at enim sed erat cursus rutrum eu et mauris. Maecenas blandit ullamcorper egestas. Morbi a felis pulvinar, sagittis lacus lobortis, consequat dui. Aenean eget lectus ultricies, gravida quam at, lacinia sapien. Proin accumsan posuere diam id cursus. Donec tincidunt vel augue ut convallis. Cras justo diam, accumsan vel aliquam gravida, laoreet maximus purus.

Vivamus mollis velit ante, at egestas nisl consectetur et. Interdum et malesuada fames ac ante ipsum primis in faucibus. Fusce vestibulum pharetra magna, sed scelerisque arcu placerat quis. Curabitur molestie, nisl id auctor lacinia, magna nulla sodales tellus, ut posuere sapien dolor ac mi. Maecenas facilisis, purus id maximus mattis, purus erat bibendum diam, nec dapibus neque ante quis ex. Nullam sed sagittis turpis. Integer placerat eros nec ligula sodales lobortis. Fusce in felis euismod felis pulvinar tristique non at nunc. Praesent risus augue, laoreet ut varius ut, accumsan at dui. Sed tempor condimentum scelerisque. Pellentesque vehicula sed augue id lobortis. In porta semper quam, non scelerisque nisl. Nunc porttitor pretium lorem, a semper massa tincidunt eu.

Vivamus at metus vitae lacus ullamcorper lacinia. Nam vulputate nisl nec ante lacinia ultricies. Etiam maximus felis vel sem commodo, quis maximus diam tincidunt. Cras tempor volutpat mauris, vitae consequat dolor placerat eu. Donec dignissim tempus vehicula. Pellentesque et orci eget enim ullamcorper accumsan eu vitae odio. Suspendisse quis purus a arcu condimentum cursus. Curabitur imperdiet urna eu nisi pretium ullamcorper. Cras accumsan interdum justo non tristique. In hac habitasse platea dictumst. Phasellus gravida lorem eu est malesuada, vel maximus sem imperdiet. Duis tristique, mi et dictum pharetra, arcu elit tincidunt.''';
