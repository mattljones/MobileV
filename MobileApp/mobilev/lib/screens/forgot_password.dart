import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/form_input_text.dart';
import 'package:mobilev/widgets/form_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightPrimaryColour,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            reverse: true,
            padding: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image(
                  image: AssetImage('assets/images/reset_password.png'),
                  width: 240.0,
                ),
                SizedBox(height: 20.0),
                Text(
                  'Enter your email address below and we\'ll send you a reset link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 40.0),
                FormInputText(
                  label: 'Email',
                  icon: Icons.email,
                  obscureInput: false,
                  keyboard: TextInputType.emailAddress,
                ),
                SizedBox(height: 20.0),
                FormButton(
                  text: 'Request new password',
                  buttonColour: kPrimaryColour,
                  textColour: Colors.white,
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                ),
                SizedBox(height: 40.0),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text(
                    'Remembered your password? Go back!',
                    style: TextStyle(
                      color: kSecondaryTextColour,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
