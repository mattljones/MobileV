// Dart & Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Module imports
import 'package:mobilev/services/network_service.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/form_input_text.dart';
import 'package:mobilev/widgets/form_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool wrongPassword = false;
  bool isLoading = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change password'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(40.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(height: 20.0),
                FormInputText(
                  controller: currentPasswordController,
                  label: 'Current password',
                  icon: Icons.lock,
                  obscureInput: true,
                  keyboard: TextInputType.text,
                  validator: (value) {
                    if (value!.length == 0) {
                      return 'Please complete this field';
                    } else if (wrongPassword) {
                      return 'Incorrect password. Please try again.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30.0),
                FormInputText(
                  controller: newPasswordController,
                  label: 'New password',
                  icon: Icons.lock,
                  obscureInput: true,
                  keyboard: TextInputType.text,
                  validator: (value) {
                    if (value!.length < 6) {
                      return 'Passwords must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30.0),
                FormInputText(
                  controller: confirmPasswordController,
                  label: 'Confirm password',
                  icon: Icons.lock,
                  obscureInput: true,
                  keyboard: TextInputType.text,
                  validator: (value) {
                    if (newPasswordController.text.length >= 6 &&
                        value != newPasswordController.text) {
                      return 'Doesn\'t match password entered above';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30.0),
                FormButton(
                  text: isLoading ? '' : 'Submit',
                  buttonColour: kPrimaryColour,
                  textColour: Colors.white,
                  icon: isLoading
                      ? SpinKitPouringHourglass(
                          color: Colors.white,
                          size: 40.0,
                        )
                      : null,
                  onPressed: () async {
                    // Validate form
                    if (formKey.currentState!.validate()) {
                      // If form is  valid, try to connect to API
                      setState(() {
                        isLoading = true;
                      });
                      String oldPassword = currentPasswordController.text;
                      String newPassword = newPasswordController.text;
                      String passwordChanged =
                          await NetworkService.changePassword(
                              oldPassword, newPassword);
                      // Successful password change
                      if (passwordChanged == 'successful') {
                        Navigator.pop(context, true);
                        // Incorrect password entered
                      } else if (passwordChanged == 'wrong_password') {
                        setState(() {
                          isLoading = false;
                          wrongPassword = true;
                          formKey.currentState!.validate();
                          wrongPassword = false;
                        });
                      }
                      // If an error occurs, give relevant information
                      else {
                        // Check if connected to a network
                        String message = (await (Connectivity()
                                    .checkConnectivity())) !=
                                ConnectivityResult.none
                            ? 'An unexpected error occurred. Please try again.'
                            : 'Network unavailable';
                        final snackBar = SnackBar(
                          backgroundColor: kSecondaryTextColour,
                          content: Text(message),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
