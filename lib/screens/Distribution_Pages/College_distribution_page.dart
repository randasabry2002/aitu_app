import 'package:aitu_app/screens/Distribution_Pages/Instructions.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Attendance_Part_Pages/homeScreen.dart';
import 'PDFViewerPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class College_distribution_page extends StatefulWidget {
  const College_distribution_page({super.key});

  @override
  State<College_distribution_page> createState() =>
      _College_distribution_pageState();
}

class _College_distribution_pageState extends State<College_distribution_page> {
  bool loading = false;

  Future<bool> getBooleanValue() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Distripution_College_done')
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
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () {
              Get.to(() => const Instructions());
            },
          ),
          backgroundColor: Color(0xFF0187c4),
          actions: <Widget>[
            // Language Selector Icon
            PopupMenuButton<String>(
              icon: Icon(
                Icons.language,
                color: Colors.white,
              ),
              onSelected: (value) {
                // Update the app's locale based on the selection
                if (value == 'en') {
                  Get.updateLocale(Locale('en'));
                } else if (value == 'ar') {
                  Get.updateLocale(Locale('ar'));
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'en',
                    child: Text('English'),
                  ),
                  PopupMenuItem(
                    value: 'ar',
                    child: Text('العربية'),
                  ),
                ];
              },
            ),
          ],
        ),
        backgroundColor: Color(0xFF0187c4),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: StreamBuilder<bool>(
              stream: getBooleanStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  );
                }
                if (snapshot.hasError) {
                  return Text("حدث خطأ في جلب البيانات ❌");
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
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Visibility(
                      visible: value,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(PDFViewerPage(
                            pdfType: "distributionPdf",
                          ));
                        },
                        child: Text(
                          "Show_PDF".tr,
                          style: TextStyle(
                            color: Color(0xFF0187c4),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: value,
                      child: ElevatedButton(
                        onPressed: () async {
                          final SharedPreferences _prefs =
                              await SharedPreferences.getInstance();
                          await _prefs.setString("page", "HomeScreen");
                          // Get.to(HomeScreen());
                        },
                        child: Text(
                          "Start_Attendance".tr,
                          style: TextStyle(
                            color: Color(0xFF0187c4),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
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
}
