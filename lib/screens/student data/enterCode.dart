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
        // appBar: AppBar(
        //   elevation: 0.0,
        //   backgroundColor: const Color.fromARGB(0, 0, 115, 168),
        //   // automaticallyImplyLeading: true,
        //   actions: <Widget>[
        //     // Language Selector Icon
        //     PopupMenuButton<String>(
        //       icon: Icon(
        //         Icons.language,
        //         color: const Color.fromARGB(255, 255, 255, 255),
        //       ),
        //       onSelected: (value) {
        //         // Update the app's locale based on the selection
        //         if (value == 'en') {
        //           Get.updateLocale(Locale('en'));
        //         } else if (value == 'ar') {
        //           Get.updateLocale(Locale('ar'));
        //         }
        //       },
        //       itemBuilder: (BuildContext context) {
        //         return [
        //           PopupMenuItem(value: 'en', child: Text('English')),
        //           PopupMenuItem(value: 'ar', child: Text('العربية')),
        //         ];
        //       },
        //     ),
        //   ],
        // ),
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
                      Container(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                      //ask for code
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 40,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: mainColor, width: 1.4),
                          color: const Color.fromARGB(57, 255, 255, 255),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'enter_your_code'.tr,
                              style: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontSize: 22.0,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 20),
                            CreateInput(
                              focusedBorderColor: Colors.transparent,
                              textAlign: TextAlign.center,
                              borderColor: const Color.fromARGB(0, 82, 82, 82),
                              labelColor: mainColor,
                              color: Colors.white,
                              onChanged: (value) {
                                setState(() {
                                  studentCode = value;
                                });
                              },
                              labelText: ''.tr,
                              keyboardType: TextInputType.text,
                            ),
                            SizedBox(height: 60),
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, -32),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                mainColor,
                                Color.fromARGB(255, 0, 243, 223),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () async {
                                if (studentCode.isEmpty) {
                                  Get.snackbar(
                                    'تنبيه',
                                    'يرجى إدخال كود الطالب',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.TOP,
                                    duration: Duration(seconds: 3),
                                  );
                                  return;
                                }
                                final firebaseService = FirebaseService();
                                try {
                                  final student = await firebaseService
                                      .getDataWithStudentId(studentCode);
                                  if (student != null) {
                                    if (student.email == "") {
                                      Get.offAll(
                                        () => SignUpScreen(
                                          studentCode: studentCode,
                                        ),
                                      );
                                    } else if (student.birthAddress == "") {
                                      Get.offAll(
                                        () => CompleteStudentData(
                                          studentCode: studentCode,
                                        ),
                                      );
                                    } else {
                                      Get.offAll(
                                        () => SignInScreen(
                                          studentCode: studentCode,
                                        ),
                                      );
                                    }
                                  } else {
                                    Get.snackbar(
                                      'تنبيه',
                                      "الكود غير موجود!".tr,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.TOP,
                                      duration: Duration(seconds: 3),
                                    );
                                  }
                                } catch (error) {
                                  print("Error fetching student data: $error");
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text(
                                            'لا يوجد طالب بهذا الكود'.tr,
                                          ),
                                          content: Text(
                                            'يرجى التحقق من الكود المدخل\n اذا كنت متأكد منه قم بالطلب من احد اعضاء الشئون الطلابية والتأكد من اضافتك للبرنامج. \n'
                                                .tr,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                              child: Text('حسنا'.tr),
                                            ),
                                          ],
                                        ),
                                  );
                                }
                              },
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ),
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
