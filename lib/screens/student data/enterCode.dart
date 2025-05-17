import 'package:aitu_app/screens/student%20data/completeStudentData.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aitu_app/services/firestore.dart';
import 'package:aitu_app/screens/Sign_In&Up/SignUpScreen.dart';
import 'package:aitu_app/screens/Sign_In&Up/SignInScreen.dart';

class EnterStudentCode extends StatefulWidget {
  @override
  State<EnterStudentCode> createState() => _EnterStudentCodeState();
}

class _EnterStudentCodeState extends State<EnterStudentCode> {
  String studentCode = '';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: const Color.fromARGB(0, 0, 115, 168),
          // automaticallyImplyLeading: true,
          actions: <Widget>[
            // Language Selector Icon
            PopupMenuButton<String>(
              icon: Icon(
                Icons.language,
                color: const Color.fromARGB(255, 255, 255, 255),
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
                  PopupMenuItem(value: 'en', child: Text('English')),
                  PopupMenuItem(value: 'ar', child: Text('العربية')),
                ];
              },
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: Stack(
          children: [
            // Background shape
            imageBackground,
            // Background color
            backDark,
            //body:
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 25.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //logo
                      Image.asset(
                        'assets/images/logo.png',
                        width: 200,
                        height: 200,
                      ),
                      //ask for code
                      Container(
                        // height: MediaQuery.of(context).size.height * 0.6,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 60,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(0, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(0, 0, 0, 0),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              //enter your code text
                              Text(
                                'Enter your code'
                                    .tr, // Translation key for "Sign Up"

                                style: TextStyle(
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 24.0,
                                  fontFamily: 'mainFont',
                                  fontWeight: FontWeight.bold,
                                  // fontFamily: 'mainFont',
                                ),
                              ),
                              SizedBox(height: 20),
                              CreateInput(
                                borderColor: const Color.fromARGB(255, 255, 255, 255),
                                labelColor: const Color.fromARGB(255, 82, 82, 82),
                                color: const Color.fromARGB(200, 255, 255, 255),
                                onChanged: (value) {
                                  studentCode = value;
                                },
                                labelText:
                                    'code'.tr, // Translation key for "Email"
                                keyboardType: TextInputType.text,
                              ),
                              SizedBox(height: 40),
                              //next buttno
                              CreateButton(
                                onPressed: () async {
                                  if (studentCode.isEmpty) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "please enter your code!".tr,
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  final firebaseService = FirebaseService();
                                  await firebaseService
                                      .getDataWithStudentId(studentCode)
                                      .then((student) {
                                        if (student != null) {
                                          // Store the student data in a variable or state
                                          // For example, you can use Get.put() to store it globally]
                                          if (student.email == "") {
                                            Get.offAll(
                                              Get.offAll(
                                                SignUpScreen(
                                                  studentCode: studentCode,
                                                ),
                                              ),
                                            );
                                          } else if (student.factory == "" &&
                                              student.birthAddress == "") {
                                            Get.offAll(
                                              CompleteStudentData(
                                                studentCode: studentCode,
                                              ),
                                            );
                                          } else {
                                            Get.offAll(
                                              SignInScreen(
                                                studentCode: studentCode,
                                              ),
                                            );
                                          }
                                        }
                                      })
                                      .catchError((error) {
                                        print(
                                          "Error fetching student data: $error",
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "code not found!".tr,
                                            ),
                                          ),
                                        );
                                      });
                                },
                                title: Text(
                                  'Start'.tr,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'mainFont',
                                  ),
                                ), // Key for "Sign Up",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
