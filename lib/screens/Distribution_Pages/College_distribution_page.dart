import 'package:aitu_app/screens/Distribution_Pages/Instructions.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Attendance_Part_Pages/homeScreen.dart';
import 'PDFViewerPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aitu_app/shared/constant.dart';

class College_distribution_page extends StatefulWidget {
  const College_distribution_page({super.key});

  @override
  State<College_distribution_page> createState() =>
      _College_distribution_pageState();
}

class _College_distribution_pageState extends State<College_distribution_page> {
  bool loading = false;
  bool hasViewedPDF = false;

  Future<bool> getBooleanValue() async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance
            .collection('Distribution_College_done')
            .doc('1')
            .get();

    return doc['Uploaded'] ?? false;
  }

  Stream<bool> getBooleanStream() async* {
    // هنا يتم جلب البيانات بشكل مستمر
    while (true) {
      await Future.delayed(Duration(seconds: 2)); // تحديث كل ثانيتين
      yield await getBooleanValue(); // جلب القيمة الحقيقية من المصدر
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () {
              Get.to(() => const Instructions());
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'توزيع الكلية',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: StreamBuilder<bool>(
              stream: getBooleanStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                  );
                }
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Text(
                    "حدث خطأ في جلب البيانات ❌",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Tajawal',
                    ),
                  );
                }

                bool value = snapshot.data ?? false;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        value
                            ? "College_distribution_choice_text_done".tr
                            : "College_distribution_choice_text_not_yet".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: value,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: TextButton.icon(
                          onPressed: () async {
                            await Get.to(
                              PDFViewerPage(pdfType: "distributionPdf"),
                            );
                            setState(() {
                              hasViewedPDF = true;
                            });
                          },
                          icon: Icon(
                            Icons.picture_as_pdf,
                            color: mainColor,
                            size: 28,
                          ),
                          label: Text(
                            "Show_PDF".tr,
                            style: TextStyle(
                              color: mainColor,
                              fontSize: 20,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: value,
                      child: CreateButton(
                        title: Text(
                          "Start_Attendance".tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed:
                            hasViewedPDF ? _handleStartAttendance : () {},
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleStartAttendance() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? studentId = _prefs.getString("studentId");

    if (studentId != null) {
      var studentDoc =
          await FirebaseFirestore.instance
              .collection("StudentsTable")
              .doc(studentId)
              .get();

      if (studentDoc.exists) {
        String studentEmail = studentDoc.data()?['email'] ?? '';
        await _prefs.setString("page", "HomeScreen");
        Get.to(HomeScreen(studentEmail: studentEmail));
      }
    }
  }
}
