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
      padding: EdgeInsets.all(35.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ListView(
            shrinkWrap: true,
            children: [
              Text(
                'Welcome, Matt!',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'PTSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 15.0),
              Text(
                'Your SRO is Joseph Connor',
                style: TextStyle(
                  color: kSecondaryTextColour,
                  fontFamily: 'PTSans',
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 30.0),
              ProfileCard(
                  icon: Icons.share,
                  title: 'Share agreement',
                  status: 'Recordings,\nWord clouds',
                  route: '/share-agreement'),
              ProfileCard(
                  icon: Icons.calendar_today_outlined,
                  title: 'Reminders',
                  status: 'Wednesdays\n@ 10:00',
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
