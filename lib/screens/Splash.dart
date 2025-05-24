import 'dart:async';
import 'package:aitu_app/screens/Distribution_Pages/watingRequestAnswer.dart';
import 'package:aitu_app/screens/Sign_In&Up/SignInScreen.dart';
import 'package:aitu_app/screens/student%20data/completeStudentData.dart';
import 'package:aitu_app/screens/student%20data/enterCode.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Attendance_Part_Pages/exitFactory.dart';
import 'Attendance_Part_Pages/HomeScreen.dart';
import 'Distribution_Pages/College_distribution_page.dart';
// import 'Distribution_Pages/watingRequestAnswer.dart';

// import 'Distribution_Pages/Instructions.dart';

class Splash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashState();
  }
}

class SplashState extends State<StatefulWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  int _backButtonPressedCount = 0;
  String? email;
  String? attendanceId;
  String? page;

  Future<void> printSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys(); // جلب جميع المفاتيح المخزنة
    print('sharedpref $keys}'); // طباعة المفتاح والقيمة

    for (String key in keys) {
      print('sharedpref $key: ${prefs.get(key)}'); // طباعة المفتاح والقيمة
    }
  }
  String factID = '';
  String factName = '';
  String factAddress = '';
  String factIndustry = '';
  String factGovernorate = '';

  Future<bool> checkThereIsRequest() async {
    try {
      // Get student document first
      QuerySnapshot studentQuery = await FirebaseFirestore.instance
          .collection('StudentsTable')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (studentQuery.docs.isEmpty) {
        print('No student found with email: $email');
        return false;
      }

      DocumentSnapshot student = studentQuery.docs.first;
      String studentCode = student['code'] ?? '';

      // Query factories collection for matching request
      QuerySnapshot factoryQuery = await FirebaseFirestore.instance
          .collection('Factories')
          .where('StudentsID', isEqualTo: student.id)
          .where('isApproved', isEqualTo: false)
          .limit(1)
          .get();

      if (factoryQuery.docs.isEmpty) {
        return false;
      }

      DocumentSnapshot factory = factoryQuery.docs.first;
      
      // Update factory details
      setState(() {
        factID = factory.id;
        factName = factory['name'] ?? '';
        factAddress = factory['address'] ?? '';
        factGovernorate = factory['Governorate'] ?? '';
        factIndustry = factory['industry'] ?? '';
      });

      return true;
    } catch (e) {
      print('Error checking factory request: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    printSharedPreferences();
    // Define animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Adjust the duration as needed
    );

    // Define animation
    _animation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start the animation
    _animationController.forward();

    SharedPreferences.getInstance().then((value) {
      email = value.getString("email").toString();
      attendanceId = value.getString("attendanceId").toString();
      page = value.getString("page").toString();
      print("email: $email in splash");
      QueryDocumentSnapshot? _student;
      Future<String> getStudentCode() async {
        try {
          QuerySnapshot querySnapshot =
              await FirebaseFirestore.instance
                  .collection('StudentsTable')
                  .where('email', isEqualTo: email)
                  .limit(1)
                  .get();

          if (querySnapshot.docs.isNotEmpty) {
            _student = querySnapshot.docs.first;
            return _student!['code'] ?? '';
          }
          return '';
        } catch (e) {
          print('Error getting student code: $e');
          return '';
        }
      }

      // Simulate a delay for demonstration purposes
      Future.delayed(Duration(seconds: 2), () async {
        try {
          // if (await checkThereIsRequest()) {
          //   Get.offAll(WaitnigReqestAnswer(factoryID: factID));
          // } else
          if (email != 'null') {
            String studentCode = await getStudentCode();
            if (attendanceId != 'null') {
              // User is logged in, and the user was in the training navigate to ExitFactory
              Get.offAll(ExitFactory());
            } else {
              if (page == 'College_distribution_page') {
                Get.offAll(College_distribution_page());
              } else if (page == 'HomeScreen') {
                Get.offAll(HomeScreen());
              } else if (_student?['stage'] == null) {
                Get.offAll(CompleteStudentData(studentCode: studentCode));
              } else if (await checkThereIsRequest()) {
                Get.offAll(WaitnigReqestAnswer(
                  fatoryGovernorate: factGovernorate,
                  factoryName: factName,
                  factoryLocation: factAddress,
                  factoryIndustry: factIndustry,
                ));
              } else {
                Get.offAll(SignInScreen());
              }
            }
          } else {
            // User is not logged in, navigate to Signin screen
            Get.offAll(EnterStudentCode());
          }
        } catch (e) {
          Get.defaultDialog(
            title: "Error",
            middleText: "Error: $e",
            textConfirm: "OK",
            confirmTextColor: Colors.red,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (_backButtonPressedCount == 1) {
            return true; // Allow the back button press to exit the app
          } else {
            _backButtonPressedCount++;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Press back again to exit')));

            // Reset the back button press count after 2 seconds
            Timer(Duration(seconds: 2), () {
              _backButtonPressedCount = 0;
            });

            return false; // Prevent the back button press from exiting the app
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            // mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                child: Column(
                  children: [
                    Center(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _animation.value,
                            child: Column(
                              children: [
                                Image.asset('assets/images/logo.png'),
                                if (_animation.value >= .8) ...[
                                  LinearProgressIndicator(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                    color: mainColor,
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
