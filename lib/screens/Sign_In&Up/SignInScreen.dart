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
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('StudentsTable') // اسم المجموعة التي تحتوي على بيانات الطلاب
          .where('Email', isEqualTo: email) // البحث باستخدام البريد الإلكتروني
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
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
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
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'email'.tr, // Translated "Email"
                      labelStyle: TextStyle(color: Colors.white,fontSize: 17),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white,fontSize: 17),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    obscureText: isPasswordVisible,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                      if (password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("enter_password"
                                .tr), // Translated "Enter your password"
                          ),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                      labelText: 'password'.tr,
                      // Translated "Password"
                      labelStyle: TextStyle(color: Colors.white,fontSize: 17),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white,fontSize: 17),
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
                          'forget_password'.tr, // Translated text
                          style: TextStyle(color: Colors.white,fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  //sign in btn
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _auth.signInWithEmailAndPassword(
                            email: email, password: password);
                        if (_auth.currentUser != null) {
                          final SharedPreferences _prefs = await SharedPreferences.getInstance();
                          await _prefs.setString(
                              "email", _auth.currentUser!.email.toString());
                          print("${_prefs.getString("email")}  in signin");

                          String? studentId = await getStudentIdByEmail(email);

                          if (studentId != null) {
                            print('Student ID: $studentId');

                            await _prefs.setString(
                                "studentId", studentId);
                          } else {
                            print('Student not found');
                          }

                          Get.offAll(Instructions());
                        }
                        // Get.offAll(HomeScreen());
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("invalid_credentials"
                                .tr), // Translated "Invalid email or password"
                          ),
                        );
                      }
                    },
                    child: Text('sign_in_button'.tr,
                      style: TextStyle(fontSize: 20,color: Color(0xFF0187c4),fontWeight: FontWeight.bold),), // Translated "Sign In"
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await GoogleSignIn().signOut();
                      final GoogleSignInAccount? googleUser =
                      await GoogleSignIn().signIn();

                      final GoogleSignInAuthentication googleAuth =
                      await googleUser!.authentication;

                      final credential = GoogleAuthProvider.credential(
                        accessToken: googleAuth.accessToken,
                        idToken: googleAuth.idToken,
                      );
                      await _auth.signInWithCredential(credential);
                      final SharedPreferences _prefs =
                      await SharedPreferences.getInstance();

                      if (_auth.currentUser != null) {

                        await _prefs.setString(
                            "email", _auth.currentUser!.email.toString());
                        print("${_prefs.getString("email")}  in signin");
                      }
                      String? studentId = await getStudentIdByEmail(email);

                      if (studentId != null) {
                        print('Student ID: $studentId');

                        await _prefs.setString(
                            "studentId", studentId);
                      } else {
                        print('Student not found');
                      }

                      Get.offAll(HomeScreen());
                    },
                    child: const Text(
                      'Sign In With Google',
                      style: TextStyle(fontSize: 20,color: Color(0xFF0187c4),fontWeight: FontWeight.bold),), // Translated "Sign In"

                  ),
                  SizedBox(height: 16),

                  //sign up btn
                  TextButton(
                    onPressed: () {
                      Get.to(SignUpScreen());
                    },
                    child: Text(
                      'sign_up_prompt'.tr,
                      // Translated "Don't have an account? Sign Up"
                      style: TextStyle(color: Colors.white,fontSize: 17),
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
