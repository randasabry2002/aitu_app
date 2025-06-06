// ignore_for_file: must_be_immutable

import 'package:aitu_app/screens/Attendance_Part_Pages/AttendancePage.dart';
import 'package:aitu_app/screens/student%20data/enterCode.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Attendance_Part_Pages/homeScreen.dart';
import '../Distribution_Pages/Instructions.dart';
import 'SignUpScreen.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<SignInScreen> createState() => _SignInScreenState();
  String? studentCode;
  SignInScreen({super.key, this.studentCode});
}

class _SignInScreenState extends State<SignInScreen> {
  String password = '';
  String email = '';
  bool isPasswordVisible = true;
  final _auth = FirebaseAuth.instance;

  Future<String?> getStudentIdByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection(
                'StudentsTable',
              ) // اسم المجموعة التي تحتوي على بيانات الطلاب
              .where(
                'Email',
                isEqualTo: email,
              ) // البحث باستخدام البريد الإلكتروني
              .limit(1) // جلب أول نتيجة فقط
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id; // إرجاع الـ ID الخاص بالمستند
      } else {
        print('No student found with this email');
        return null;
      }
    } catch (e) {
      print('Error fetching student ID: $e');
      return null;
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
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text(
                        'تنبيه',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'هل أنت متأكد أنك تريد العودة؟ ستعود إلى صفحة الكود لإدخالها.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                          },
                          child: Text('إالغاء'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Get.offAll(EnterStudentCode());
                          },
                          child: Text('نعم'),
                        ),
                      ],
                    ),
              );
            },
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          // actions: <Widget>[
          //   // Language Selector Icon
          //   PopupMenuButton<String>(
          //     icon: Icon(Icons.language, color: Colors.white),
          //     onSelected: (value) {
          //       // Update the app's locale based on the selection
          //       if (value == 'en') {
          //         Get.updateLocale(Locale('en'));
          //       } else if (value == 'ar') {
          //         Get.updateLocale(Locale('ar'));
          //       }
          //     },
          //     itemBuilder: (BuildContext context) {
          //       return [
          //         PopupMenuItem(value: 'en', child: Text('English')),
          //         PopupMenuItem(value: 'ar', child: Text('العربية')),
          //       ];
          //     },
          //   ),
          // ],
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        // body: Scaffold(backgroundColor: Colors.green,),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'sign_in'.tr, // Translated "Sign In"
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  SizedBox(height: 60),
                  CreateInput(
                    textAlign: TextAlign.center,
                    focusedBorderColor: const Color.fromARGB(255, 0, 255, 234),
                    labelText: 'email'.tr,
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),

                  SizedBox(height: 30.0),
                  CreateInput(
                    textAlign: TextAlign.center,
                    focusedBorderColor: const Color.fromARGB(255, 0, 255, 234),
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                      if (password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("enter_password".tr)),
                        );
                      }
                    },
                    labelText: 'كلمة المرور',
                    isPassword: isPasswordVisible,
                    controller: null,
                    suffix: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color.fromARGB(255, 63, 63, 63),
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    keyboardType: TextInputType.visiblePassword,
                  ),

                  SizedBox(height: 4),
                  //forget password btn
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Add your navigation logic here
                          // Get.to(() => ForgetPasswordScreen());
                        },
                        child: Text(
                          'نسيت كلمة المرور'.tr, // Translated text
                          style: TextStyle(color: mainColor, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  //sign in btn
                  SizedBox(
                    height: 60.0,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: CreateButton(
                      onPressed: () async {
                        try {
                          // First check if student exists in StudentsTable
                          QuerySnapshot studentQuery =
                              await FirebaseFirestore.instance
                                  .collection('StudentsTable')
                                  .where('email', isEqualTo: email)
                                  .where('password', isEqualTo: password)
                                  .limit(1)
                                  .get();

                          if (studentQuery.docs.isEmpty) {
                            throw Exception("invalid_credentials");
                          }

                          // If student exists, proceed with Firebase Auth
                          await _auth.signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          if (_auth.currentUser != null) {
                            final SharedPreferences _prefs =
                                await SharedPreferences.getInstance();

                            // Store email
                            await _prefs.setString("email", email);
                            print("${_prefs.getString("email")} in signin");

                            // Get and store student ID
                            String studentId = studentQuery.docs.first.id;
                            print('Student ID: $studentId');
                            await _prefs.setString("studentId", studentId);

                            Get.offAll(HomeScreen(studentEmail: email));
                          }
                        } catch (e) {
                          String errorMessage =
                              e.toString().contains("invalid_credentials")
                                  ? "invalid_credentials".tr
                                  : "حدث خطأ أثناء تسجيل الدخول";

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color.fromARGB(
                                255,
                                160,
                                11,
                                0,
                              ),
                              content: Text(errorMessage),
                            ),
                          );
                        }
                      },
                      title: Text(
                        'sign_in'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ), // Key for "Sign Up",
                    ),
                  ),
                  SizedBox(height: 20),

                  // SizedBox(
                  //   width: MediaQuery.of(context).size.width * 0.9,
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       // padding: EdgeInsets.symmetric(horizontal: 16),
                  //       backgroundColor: const Color.fromARGB(
                  //         255,
                  //         255,
                  //         255,
                  //         255,
                  //       ),
                  //       foregroundColor: mainColor,
                  //       side: BorderSide(color: mainColor, width: 1.0),
                  //       minimumSize: Size(double.infinity, 50),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(30),
                  //       ),
                  //       elevation: 4,
                  //     ),
                  //     onPressed: () async {
                  //       await GoogleSignIn().signOut();
                  //       final GoogleSignInAccount? googleUser =
                  //           await GoogleSignIn().signIn();

                  //       if (googleUser == null) return; // User cancelled

                  //       final GoogleSignInAuthentication googleAuth =
                  //           await googleUser.authentication;

                  //       final credential = GoogleAuthProvider.credential(
                  //         accessToken: googleAuth.accessToken,
                  //         idToken: googleAuth.idToken,
                  //       );
                  //       await _auth.signInWithCredential(credential);
                  //       final SharedPreferences _prefs =
                  //           await SharedPreferences.getInstance();

                  //       if (_auth.currentUser != null) {
                  //         await _prefs.setString(
                  //           "email",
                  //           _auth.currentUser!.email.toString(),
                  //         );
                  //         print("${_prefs.getString("email")}  in signin");
                  //       }
                  //       String? studentId = await getStudentIdByEmail(
                  //         _auth.currentUser?.email ?? "",
                  //       );

                  //       if (studentId != null) {
                  //         print('Student ID: $studentId');
                  //         await _prefs.setString("studentId", studentId);
                  //       } else {
                  //         print('Student not found');
                  //       }

                  //       Get.offAll(HomeScreen());
                  //     },
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Icon(Icons.g_mobiledata, size: 50),
                  //         SizedBox(width: 16),
                  //         // Translated text
                  //         Text(
                  //           'signIn_with_google'.tr,
                  //           style: TextStyle(
                  //             fontSize: 18,
                  //             fontWeight: FontWeight.w500,
                  //             fontFamily: 'Tajawal',
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 40),

                  // //sign up btn
                  TextButton(
                    onPressed: () async {
                      final email = await FirebaseFirestore.instance
                          .collection('StudentsTable')
                          .where('code', isEqualTo: widget.studentCode)
                          .limit(1)
                          .get()
                          .then(
                            (snapshot) => snapshot.docs.first['email'] ?? '',
                          );
                      Get.to(AttendancePage());
                    },
                    child: Text(
                      'test'.tr,
                      // Translated "Don't have an account? Sign Up"
                      style: TextStyle(
                        color: const Color.fromARGB(255, 7, 30, 41),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                 
                 
                  TextButton(
                    onPressed: () {
                      Get.to(
                        SignUpScreen(studentCode: widget.studentCode ?? ''),
                      );
                    },
                    child: Text(
                      'sign_up_prompt'.tr,
                      // Translated "Don't have an account? Sign Up"
                      style: TextStyle(color: mainColor, fontSize: 12),
                    ),
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
