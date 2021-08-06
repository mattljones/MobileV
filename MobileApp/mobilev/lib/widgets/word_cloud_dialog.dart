// Dart & Flutter imports
import 'dart:io';
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/config/constants.dart';

class WordCloudDialog extends StatelessWidget {
  final String date;
  final String filePath;

  WordCloudDialog({
    required this.date,
    required this.filePath,
  });

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
              date.substring(0, 2) + ' ' + fullMonths[date.substring(3)]!,
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
                    image: FileImage(File(filePath)),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
