import 'package:flutter/material.dart';
import 'package:mobilev/config/styles.dart';
import 'package:mobilev/widgets/form_button.dart';

class ProfileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FormButton(
            text: 'Sign out',
            buttonColour: kAccentColour,
            textColour: Colors.black,
            goToRoute: '/login',
          ),
        ],
      ),
    );
  }
}
