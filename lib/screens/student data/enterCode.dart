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
                              // Step 1: Enter your code text
                              Text(
                              'enter_your_code'.tr,
                              style: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontSize: 24.0,
                                fontFamily: 'mainFont',
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                              SizedBox(height: 20),
                              // Step 2: Input field for code
                              CreateInput(
                              borderColor: const Color.fromARGB(255, 255, 255, 255),
                              labelColor: const Color.fromARGB(255, 82, 82, 82),
                              color: const Color.fromARGB(200, 255, 255, 255),
                              onChanged: (value) {
                                setState(() {
                                studentCode = value;
                                });
                              },
                              labelText: 'code'.tr,
                              keyboardType: TextInputType.text,
                              ),
                              SizedBox(height: 40),
                              // Step 3: Next button
                              CreateButton(
                              onPressed: () async {
                                if (studentCode.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                  content: Text("please enter your code!".tr),
                                  ),
                                );
                                return;
                                }
                                final firebaseService = FirebaseService();
                                try {
                                final student = await firebaseService.getDataWithStudentId(studentCode);
                                if (student != null) {
                                  // Step 4: Walk through the flow based on student data
                                  if (student.email == "") {
                                  // Go to SignUpScreen
                                  Get.offAll(() => SignUpScreen(studentCode: studentCode));
                                  } else if (student.birthAddress == "") {
                                  // Go to CompleteStudentData
                                  Get.offAll(() => CompleteStudentData(studentCode: studentCode));
                                  } else {
                                  // Go to SignInScreen
                                  Get.offAll(() => SignInScreen(studentCode: studentCode));
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("code not found!".tr),
                                  ),
                                  );
                                }
                                } catch (error) {
                                print("Error fetching student data: $error");
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                  title: Text('Error'.tr),
                                  content: Text('An error occurred while fetching student data. \n$error'.tr),
                                  actions: [
                                    TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('OK'.tr),
                                    ),
                                  ],
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                  content: Text("code not found!".tr),
                                  ),
                                );
                                }
                              },
                              title: Text(
                                'Start'.tr,
                                style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'mainFont',
                                ),
                              ),
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
