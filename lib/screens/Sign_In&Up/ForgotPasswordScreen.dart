// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String email = '';
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;

  Future<void> _resetPassword() async {
    if (email.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'الرجاء إدخال البريد الإلكتروني',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // First check if email exists in StudentsTable
      QuerySnapshot studentQuery =
          await FirebaseFirestore.instance
              .collection('StudentsTable')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (studentQuery.docs.isEmpty) {
        throw Exception("email_not_found");
      }

      // If email exists, send password reset email
      await _auth.sendPasswordResetEmail(email: email);

      Get.snackbar(
        'نجاح',
        'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );

      // Navigate back to sign in screen
      Get.back();
    } catch (e) {
      String errorMessage =
          e.toString().contains("email_not_found")
              ? "البريد الإلكتروني غير مسجل"
              : "حدث خطأ أثناء إرسال رابط إعادة تعيين كلمة المرور";

      Get.snackbar(
        'خطأ',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 25.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container with gradient background
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mainColor, Color.fromARGB(255, 0, 243, 223)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'نسيت كلمة المرور',
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      height: 1.5,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CreateInput(
                    textAlign: TextAlign.center,
                    focusedBorderColor: mainColor,
                    labelText: 'email'.tr,
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    keyboardType: TextInputType.emailAddress,
                    prefix: Icon(Icons.email_outlined, color: mainColor),
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  height: 60.0,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : () => _resetPassword(),
                      borderRadius: BorderRadius.circular(30),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              mainColor,
                              Color.fromARGB(255, 0, 243, 223),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          child: Center(
                            child:
                                _isLoading
                                    ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.send_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'إرسال رابط إعادة التعيين',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Tajawal',
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
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
    );
  }
}
