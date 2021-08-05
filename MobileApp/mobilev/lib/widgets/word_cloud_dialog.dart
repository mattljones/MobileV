// Dart & Flutter imports
import 'package:flutter/material.dart';

class WordCloudDialog extends StatelessWidget {
  final String date;

  WordCloudDialog(this.date);

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width * 0.8;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20.0),
            Text(
              date,
              style: TextStyle(
                fontFamily: 'PTSans',
                fontSize: 22,
              ),
            ),
            InteractiveViewer(
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: ExactAssetImage(
                          'assets/images/wordcloud_example.jpg'),
                      fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
