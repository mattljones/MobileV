// Dart & Flutter imports
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/form_input_text.dart';
import 'package:mobilev/widgets/form_button.dart';

class ChangePasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change password'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(40.0),
          child: Column(
            children: [
              FormInputText(
                label: 'Current password',
                icon: Icons.lock,
                obscureInput: true,
                keyboard: TextInputType.text,
              ),
              SizedBox(height: 20.0),
              FormInputText(
                label: 'New password',
                icon: Icons.lock,
                obscureInput: true,
                keyboard: TextInputType.text,
              ),
              SizedBox(height: 20.0),
              FormInputText(
                label: 'Confirm password',
                icon: Icons.lock,
                obscureInput: true,
                keyboard: TextInputType.text,
              ),
              SizedBox(height: 20.0),
              FormButton(
                text: 'Submit',
                buttonColour: kPrimaryColour,
                textColour: Colors.white,
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
