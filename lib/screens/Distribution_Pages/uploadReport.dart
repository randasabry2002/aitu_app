import 'package:aitu_app/screens/Distribution_Pages/Not_College_distribution_page.dart';
import 'package:flutter/material.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'PDFViewerPage.dart';

class UploadReport extends StatelessWidget {
  const UploadReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: mainColor),
          tooltip: 'عودة',
          onPressed: () {
            Get.offAll(Not_College_distribution_page());
          },
        ),
        title: Text(
          'رفع تقرير التدريب',
          style: TextStyle(
            color: mainColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Tajawal',
          ),
        ),
      ),
      body: Container(color: Colors.white),
    );
  }
}
