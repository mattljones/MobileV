// Dart & Flutter imports
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/form_button.dart';
import 'package:mobilev/widgets/profile_card.dart';

class ProfileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ListView(
            shrinkWrap: true,
            children: [
              ProfileCard(
                  icon: Icons.share,
                  title: 'Share agreement',
                  status: 'Accepted',
                  route: '/change-password'),
              ProfileCard(
                  icon: Icons.calendar_today_outlined,
                  title: 'Weekly reminders',
                  status: 'Wednesdays\n10:00',
                  route: '/weekly-reminders'),
              ProfileCard(
                  icon: Icons.lock,
                  title: 'Change password',
                  status: '',
                  route: '/change-password'),
            ],
          ),
          FormButton(
            text: 'Sign out',
            buttonColour: kAccentColour,
            textColour: Colors.black,
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }
}
