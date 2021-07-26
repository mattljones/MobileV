import 'package:flutter/material.dart';
import 'package:mobilev/config/styles.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RecordingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: kCardColour,
      elevation: 6.0,
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '24/07/2021',
                  style: TextStyle(
                    color: kPrimaryColour,
                    fontSize: 22.0,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: 'Roboto',
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: 'Test',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: '  |  60s',
                        style: TextStyle(fontWeight: FontWeight.w300),
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.0),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text(
                        'Shared',
                        style: TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                      SizedBox(width: 10.0),
                      Icon(
                        Icons.check_box_outlined,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.0),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text(
                        'Analysis pending',
                        style: TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                      SizedBox(width: 10.0),
                      SpinKitRing(
                        color: Colors.white,
                        size: 25.0,
                        lineWidth: 3.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 10.0),
            ExpansionTile(
              title: Text('View scores'),
              children: [
                Text('Score 1: hello'),
                Text('Score 2: hi there'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
