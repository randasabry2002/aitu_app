import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AttendancePage.dart';
import 'EnterFactory.dart';
import 'InfoPage.dart';
import '../Distribution_Pages/PDFViewerPage.dart';
import '../Profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _backButtonPressedCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: WillPopScope(
        onWillPop: () async {
          if (_backButtonPressedCount == 1) {
            return true; // Allow the back button press to exit the app
          } else {
            _backButtonPressedCount++;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('press_back'.tr)),
            );

            // Reset the back button press count after 2 seconds
            Timer(Duration(seconds: 2), () {
              _backButtonPressedCount = 0;
            });

            return false; // Prevent the back button press from exiting the app
          }
        },
        child: Scaffold(
          appBar: AppBar(
            // toolbarHeight: 50,
            backgroundColor: Color(0xFF0187c4),
            leading: IconButton(
              icon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              onPressed: () {
                Get.to(Profile());
              },
            ),
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
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Text(
                      "welcome_message".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
              
                  // رسالة توضيحية
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "welcome_message2".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.white70),
                    ),
                  ),
              
                  // صورة توضيحية
                  Center(
                    child: Image.asset(
                      'assets/images/german_logo.jpg', // استبدلي المسار بالصورة التي تريدينها
                      height: 350,
                    ),
                  ),
              
                  SizedBox(height: 20),
                  ///Enter factory btn
                  ElevatedButton(
                    onPressed: () async {
                      Get.to(EnterFactory());
                    },
                    child: Text(
                      'enter_factory'.tr,
                      style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF0187c4),
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  SizedBox(height: 20),

                  /// attendance sheet
                  // OutlinedButton.icon(
                  //   onPressed: () {
                  //     Get.to(()=>AttendancePage());
                  //   },
                  //   icon: Icon(Icons.assignment,color: Colors.white,),
                  //   label: Text("attendance_reveal".tr,style: TextStyle(color: Colors.white),),
                  //   style: OutlinedButton.styleFrom(
                  //     padding: EdgeInsets.all(10),
                  //     textStyle: TextStyle(fontSize: 18,color: Colors.white),
                  //     side: BorderSide(color: Colors.white),
                  //     backgroundColor: Colors.transparent,
                  //   ),
                  // ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //التعليمات
                      OutlinedButton.icon(
                        onPressed: () {
                          Get.to(()=>InfoPage());
                        },
                        icon: Icon(Icons.info_outline,color: Colors.white,),
                        label: Text("instructions".tr,style: TextStyle(color: Colors.white),),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.all(10),
                          textStyle: TextStyle(fontSize: 18,color: Colors.white),
                          side: BorderSide(color: Colors.white),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      //distribution
                      OutlinedButton.icon(
                        onPressed: () {
                          Get.to(PDFViewerPage(pdfType: "distributionPdf",));
                        },
                        icon: Icon(Icons.assignment,color: Colors.white,),
                        label: Text("Show_PDF".tr,style: TextStyle(color: Colors.white),),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.all(10),
                          textStyle: TextStyle(fontSize: 18,color: Colors.white),
                          side: BorderSide(color: Colors.white),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
