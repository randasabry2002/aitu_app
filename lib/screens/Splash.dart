import 'dart:async';
import 'package:aitu_app/screens/Distribution_Pages/watingRequestAnswer.dart';
import 'package:aitu_app/screens/Sign_In&Up/SignInScreen.dart';
import 'package:aitu_app/screens/student%20data/completeStudentData.dart';
import 'package:aitu_app/screens/student%20data/enterCode.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aitu_app/screens/Attendance_Part_Pages/duringTraining.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Attendance_Part_Pages/HomeScreen.dart';
import 'Distribution_Pages/College_distribution_page.dart';
import 'Distribution_Pages/PDFViewerPage.dart';
// import 'Distribution_Pages/watingRequestAnswer.dart';

// import 'Distribution_Pages/Instructions.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => SplashState();
}

class SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _backButtonPressedCount = 0;

  // User state variables
  String? email;
  String? attendanceId;
  String? page;
  QueryDocumentSnapshot? _student;

  // Factory request variables
  String factID = '';
  String factName = '';
  String factAddress = '';
  String factIndustry = '';
  String factGovernorate = '';

  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadUserData();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        this.prefs = prefs;
      });
    });
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      prefs = await SharedPreferences.getInstance();
      email = prefs.getString("email");
      attendanceId = prefs.getString("attendanceId");
      page = prefs.getString("page");

      await _printSharedPreferences(prefs);
      await _handleNavigation();
    } catch (e) {
      _showErrorDialog("Error loading user data: $e");
    }
  }

  Future<void> _printSharedPreferences(SharedPreferences prefs) async {
    try {
      Set<String> keys = prefs.getKeys();
      debugPrint('Shared Preferences Keys: $keys');

      for (String key in keys) {
        debugPrint('$key: ${prefs.get(key)}');
      }
    } catch (e) {
      debugPrint('Error printing shared preferences: $e');
    }
  }

  Future<void> _handleNavigation() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      if (email == null || email == 'null') {
        Get.offAll(() => EnterStudentCode());
        return;
      }

      final studentCode = await _getStudentCode();
      if (studentCode.isEmpty) {
        Get.offAll(EnterStudentCode());
        return;
      }

      // Check for any active attendance records
      final activeAttendanceQuery =
          await FirebaseFirestore.instance
              .collection("Attendances")
              .where('Student_ID', isEqualTo: studentCode)
              .where('ExitingLocation', isEqualTo: null)
              .limit(1)
              .get();

      if (activeAttendanceQuery.docs.isNotEmpty) {
        // Get the attendance ID and navigate to duringTraining
        final attendanceId = activeAttendanceQuery.docs.first.id;
        await prefs.setString("attendanceId", attendanceId);
        Get.offAll(() => DuringTraining());
        return;
      }

      // If no active attendance, proceed with normal navigation
      await _handlePageNavigation(studentCode);
    } catch (e) {
      _showErrorDialog("Navigation error: $e");
    }
  }

  Future<void> _handlePageNavigation(String studentCode) async {
    if (page == 'College_distribution_page') {
      Get.offAll(() => College_distribution_page());
      return;
    }

    if (_student?['stage'] == null) {
      Get.offAll(() => CompleteStudentData(studentCode: studentCode));
      return;
    }

    // Check if report needs to be uploaded
    if (await _checkReportUploadStatus()) {
      Get.offAll(() => PDFViewerPage(pdfType: "nominationCard"));
      return;
    }

    if (await _checkThereIsRequest()) {
      Get.offAll(
        () => WaitnigReqestAnswer(
          fatoryGovernorate: factGovernorate,
          factoryName: factName,
          factoryLocation: factAddress,
          factoryIndustry: factIndustry,
        ),
      );
      return;
    }

    if (_student?['factory'] != null && _student?['factory'] != '') {
      Get.offAll(() => HomeScreen(studentEmail: _student?['email'] ?? ''));
      return;
    }

    Get.offAll(() => SignInScreen());
  }

  Future<String> _getStudentCode() async {
    try {
      final querySnapshot =
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
      debugPrint('Error getting student code: $e');
      return '';
    }
  }

  Future<bool> _checkThereIsRequest() async {
    try {
      if (_student == null) return false;

      final factoryQuery =
          await FirebaseFirestore.instance
              .collection('Factories')
              .where('StudentsID', isEqualTo: _student!.id)
              .where('isApproved', isEqualTo: false)
              .limit(1)
              .get();

      if (factoryQuery.docs.isEmpty) return false;

      final factory = factoryQuery.docs.first;
      _updateFactoryDetails(factory);
      return true;
    } catch (e) {
      debugPrint('Error checking factory request: $e');
      return false;
    }
  }

  void _updateFactoryDetails(DocumentSnapshot factory) {
    setState(() {
      factID = factory.id;
      factName = factory['name'] ?? '';
      factAddress = factory['address'] ?? '';
      factGovernorate = factory['Governorate'] ?? '';
      factIndustry = factory['industry'] ?? '';
    });
  }

  Future<bool> _checkReportUploadStatus() async {
    try {
      if (_student == null) return false;

      // Check if isReportUploaded field exists and is false
      final data = _student!.data() as Map<String, dynamic>;
      if (data.containsKey('isReportUploaded')) {
        return data['isReportUploaded'] == false;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking report upload status: $e');
      return false;
    }
  }

  void _showErrorDialog(String message) {
    Get.defaultDialog(
      title: "Error",
      middleText: message,
      textConfirm: "OK",
      confirmTextColor: Colors.red,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;

          if (_backButtonPressedCount == 1) {
            return;
          }

          _backButtonPressedCount++;
          Get.snackbar(
            'تنبيه',
            'اضغط مرة أخرى للخروج',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 3),
          );

          Timer(const Duration(seconds: 2), () {
            _backButtonPressedCount = 0;
          });
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo.png'),
                      if (_animation.value >= 0.8) ...[
                        const SizedBox(height: 20),
                        LinearProgressIndicator(
                          backgroundColor: Colors.white,
                          color: mainColor,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
