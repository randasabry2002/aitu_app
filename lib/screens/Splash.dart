import 'dart:async';
import 'package:aitu_app/screens/student%20data/enterCode.dart';
import 'package:flutter/material.dart';


// import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Attendance_Part_Pages/ExitFactory.dart';
import 'Attendance_Part_Pages/HomeScreen.dart';
import 'Distribution_Pages/College_distribution_page.dart';
import 'Distribution_Pages/Instructions.dart';
import 'Sign_In&Up/SignInScreen.dart';


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
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    _animationController.forward();

    SharedPreferences.getInstance().then((value) {
      email = value.getString("email").toString();
      attendanceId = value.getString("attendanceId").toString();
      page = value.getString("page").toString();
      print("email: $email in splash");

      // Simulate a delay for demonstration purposes
      Future.delayed(Duration(seconds: 2), () {
        if (email != 'null') {

          if(attendanceId != 'null'){
            // User is logged in, and the user was in the training navigate to ExitFactory
            Get.offAll(ExitFactory());
          }
          else{
            if(page == 'College_distribution_page'){
              Get.offAll(College_distribution_page());
            }
            else if(page == 'HomeScreen'){
              Get.offAll(HomeScreen());
            }
            else{
              Get.offAll(Instructions());
            }
          }

        } else {
          // User is not logged in, navigate to Signin screen
          Get.offAll(EnterStudentCode());
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Press back again to exit')),
            );

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
                          child: Image.asset('assets/images/german_logo.jpg'),
                        );
                      },
                    )
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
