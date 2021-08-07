// Dart & Flutter imports
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/screens/my_analysis_body.dart';
import 'package:mobilev/screens/my_recordings_body.dart';
import 'package:mobilev/screens/my_profile_body.dart';

class MyHomeScreen extends StatefulWidget {
  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  int current = 1;
  bool _hideFloatingActionButton = false;
  Map _screenData = {
    0: ['My analysis', AnalysisBody()],
    1: ['My recordings', RecordingsBody()],
    2: ['My profile', ProfileBody()],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenData[current][0]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kBackgroundPrimaryColour,
        currentIndex: current,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over),
            label: 'Recordings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            if (index != current && index == 0) {
              current = index;
              _hideFloatingActionButton = true;
            }
            if (index != current && index == 1) {
              current = index;
              _hideFloatingActionButton = false;
            }
            if (index != current && index == 2) {
              current = index;
              _hideFloatingActionButton = true;
            }
          });
        },
      ),
      floatingActionButton: _hideFloatingActionButton
          ? null
          : FloatingActionButton(
              child: Icon(
                Icons.add,
                size: 35.0,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/add-recording');
              },
            ),
      body: _screenData[current][1],
    );
  }
}
