import 'package:flutter/material.dart';
import 'package:mobilev/config/styles.dart';
import 'package:mobilev/screens/my_analysis_body.dart';
import 'package:mobilev/screens/my_recordings_body.dart';
import 'package:mobilev/screens/my_profile_body.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _current = 1;
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
        title: Text(_screenData[_current][0]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kLightPrimaryColour,
        currentIndex: _current,
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
            if (index != _current && index == 0) {
              _current = index;
              _hideFloatingActionButton = true;
            }
            if (index != _current && index == 1) {
              _current = index;
              _hideFloatingActionButton = false;
            }
            if (index != _current && index == 2) {
              _current = index;
              _hideFloatingActionButton = true;
            }
          });
        },
      ),
      floatingActionButton: _hideFloatingActionButton
          ? null
          : FloatingActionButton(
              child: Icon(
                Icons.mic,
                size: 35.0,
              ),
              onPressed: () {},
            ),
      body: _screenData[_current][1],
    );
  }
}
