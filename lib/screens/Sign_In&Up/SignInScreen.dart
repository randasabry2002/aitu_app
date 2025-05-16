import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Attendance_Part_Pages/HomeScreen.dart';
import '../Distribution_Pages/Instructions.dart';
import 'SignUpScreen.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<SignInScreen> createState() => _SignInScreenState();
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
          backgroundColor: Color(0xFF0187c4),
          actions: <Widget>[
            // Language Selector Icon
            PopupMenuButton<String>(
              icon: Icon(Icons.language, color: Colors.white),
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
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        // body: Scaffold(backgroundColor: Colors.green,),
        body: Stack(
          children: [
            // Background Image
            Image(
              image: backgroundImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Padding(
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
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'mainFont',
                        ),
                      ),
                      SizedBox(height: 60),
                        CreateInput(
                        labelText: 'email'.tr,
                        onChanged: (value) {
                          setState(() {
                          email = value;
                          });
                        },
                        isPassword: false,
                        controller: null,
                        ),
                        SizedBox(height: 16),
                        CreateInput(
                        labelText: 'password'.tr,
                        onChanged: (value) {
                          setState(() {
                          password = value;
                          });
                          if (password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                            content: Text(
                              "enter_password".tr,
                            ),
                            ),
                          );
                          }
                        },
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
                        ),),
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
                              'forget_password'.tr, // Translated text
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 15,
                              ),
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
                          onPressed:  () async {
                            try {
                            await _auth.signInWithEmailAndPassword(
                              email: email,
                              password: password,
                            );
                            if (_auth.currentUser != null) {
                              final SharedPreferences _prefs =
                                await SharedPreferences.getInstance();
                              await _prefs.setString(
                              "email",
                              _auth.currentUser!.email.toString(),
                              );
                              print("${_prefs.getString("email")}  in signin");
                          
                              String? studentId = await getStudentIdByEmail(
                              email,
                              );
                          
                              if (studentId != null) {
                              print('Student ID: $studentId');
                              await _prefs.setString("studentId", studentId);
                              } else {
                              print('Student not found');
                              }
                          
                              Get.offAll(Instructions());
                            }
                            } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                              content: Text(
                                "invalid_credentials".tr,
                              ),
                              ),
                            );
                            }
                          },
                          title: Text(
                            'sign_in'.tr,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'mainFont',
                            ),
                          ), // Key for "Sign Up",
                         ),
                       ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              // padding: EdgeInsets.symmetric(horizontal: 16),
                              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                              foregroundColor: secondaryColor,
                                side: BorderSide(
                                color: secondaryColor,
                                width: 1.0,
                                ),
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () async {
                              await GoogleSignIn().signOut();
                              final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
                          
                              if (googleUser == null) return; // User cancelled
                          
                              final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
                          
                              final credential = GoogleAuthProvider.credential(
                                accessToken: googleAuth.accessToken,
                                idToken: googleAuth.idToken,
                              );
                              await _auth.signInWithCredential(credential);
                              final SharedPreferences _prefs = await SharedPreferences.getInstance();
                          
                              if (_auth.currentUser != null) {
                                await _prefs.setString(
                                  "email",
                                  _auth.currentUser!.email.toString(),
                                );
                                print("${_prefs.getString("email")}  in signin");
                              }
                              String? studentId = await getStudentIdByEmail(_auth.currentUser?.email ?? "");
                          
                              if (studentId != null) {
                                print('Student ID: $studentId');
                                await _prefs.setString("studentId", studentId);
                              } else {
                                print('Student not found');
                              }
                          
                              Get.offAll(HomeScreen());
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Icon(Icons.g_mobiledata, size: 50),
                                SizedBox(width: 16),
                                // Translated text
                                Text(
                                  'Sign In With Google',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'mainFont',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 40),

                      //sign up btn
                      TextButton(
                        onPressed: () {
                          Get.to(SignUpScreen());
                        },
                        child: Text(
                          'sign_up_prompt'.tr,
                          // Translated "Don't have an account? Sign Up"
                          style: TextStyle(color: secondaryColor, fontSize: 12),
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
