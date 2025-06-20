import 'package:flutter/material.dart';

class PDFViewerPage extends StatelessWidget {
  const PDFViewerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'بطاقة الترشيح',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Tajawal',
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
