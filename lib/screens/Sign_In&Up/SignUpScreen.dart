// ignore_for_file: must_be_immutable

import 'package:aitu_app/screens/student%20data/enterCode.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:flutter/material.dart';
import 'package:aitu_app/screens/Sign_In&Up/SignInScreen.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aitu_app/screens/student data/completeStudentData.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
  String studentCode = '';
  SignUpScreen({super.key, required this.studentCode});
}

class _SignUpScreenState extends State<SignUpScreen> {
  String password = '';
  String confirmPassword = '';
  String email = '';
  String phone = '';
  bool isPasswordVisible = true;
  final _auth = FirebaseAuth.instance;
  var _firestor = FirebaseFirestore.instance;
  late final SharedPreferences _prefs;

  addUser() async {
    DocumentReference docRef = _firestor
        .collection("StudentsTable")
        .doc(widget.studentCode);
    await docRef.update({"email": email, "phone": phone, "password": password});
    // استخراج الـ ID الخاص بالمستند
    String studentId = docRef.id;
    print("تمت إضافة الطالب بنجاح، ID الخاص به هو: $studentId");

    await _prefs.setString("studentId", studentId);
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
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: () {
              Get.offAll(EnterStudentCode());
            },
          ),

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
        body: Stack(
          children: [
            // // Background Image
            // Image(
            //   image: backgroundImage,
            //   fit: BoxFit.cover,
            //   width: double.infinity,
            //   height: double.infinity,
            // ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 25.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // SizedBox(height: 40),
                    Image.asset('assets/images/account.png',width: 100,height: 100,),
                      Text(
                        'انشاء حساب'.tr, // Translation key for "Sign Up"
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      SizedBox(height: 60),
                      //email
                      CreateInput(
                        textAlign: TextAlign.center,
                        focusedBorderColor: const Color.fromARGB(
                          255,
                          0,
                          255,
                          234,
                        ),
                        labelText: 'email'.tr,
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                   
                      SizedBox(height: 36),
                      //   //major
                      //   DropdownButtonFormField<String>(
                      //   value: selectedMajor,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       selectedMajor = value;
                      //     });
                      //   },
                      //   decoration: InputDecoration(
                      //     labelText: 'major'.tr, // Translation key for "Major"
                      //     labelStyle: TextStyle(color: Colors.white,fontSize: 17),
                      //     enabledBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(color: Colors.white),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(color: Colors.white),
                      //     ),
                      //   ),
                      //   style: TextStyle(color: Colors.white,fontSize: 17), // Text style for dropdown items
                      //   dropdownColor: Colors.blue, // Background color for dropdown menu
                      //   items: [
                      //     {'key': 'IT', 'label': 'IT'.tr},
                      //     {'key': 'electrical', 'label': 'electrical'.tr},
                      //     {'key': 'mechanics', 'label': 'mechanics'.tr},
                      //   ].map((item) {
                      //     return DropdownMenuItem<String>(
                      //       value: item['key'], // Use the key for value
                      //       child: Text(item['label']!), // Use the translated label
                      //     );
                      //   }).toList(),
                      // ),
                      //   SizedBox(height: 24),
                      //   //academicYear
                      //   DropdownButtonFormField<String>(
                      //     value: academicYear,
                      //     onChanged: (value) {
                      //       setState(() {
                      //         academicYear = value;
                      //       });
                      //     },
                      //     decoration: InputDecoration(
                      //       labelText: 'academic_year'.tr, // Translation key for "academic_year"
                      //       labelStyle: TextStyle(color: Colors.white,fontSize: 17),
                      //       enabledBorder: OutlineInputBorder(
                      //         borderSide: BorderSide(color: Colors.white),
                      //       ),
                      //       focusedBorder: OutlineInputBorder(
                      //         borderSide: BorderSide(color: Colors.white),
                      //       ),
                      //     ),
                      //     style: TextStyle(color: Colors.white,fontSize: 17), // Text style for dropdown items
                      //     dropdownColor: Colors.blue, // Background color for dropdown menu
                      //     items: [
                      //       {'key': '1', 'label': '1'},
                      //       {'key': '2', 'label': '2'},
                      //       {'key': '3', 'label': '3'},
                      //       {'key': '4', 'label': '4'},
                      //     ].map((item) {
                      //       return DropdownMenuItem<String>(
                      //         value: item['key'], // Use the key for value
                      //         child: Text(item['label']!), // Use the translated label
                      //       );
                      //     }).toList(),
                      //   ),
                      //   SizedBox(height: 24),
                      //phone
                      CreateInput(
                        textAlign: TextAlign.center,

                        focusedBorderColor: const Color.fromARGB(
                          255,
                          0,
                          255,
                          234,
                        ),

                        labelText: 'phone'.tr,
                        onChanged: (value) {
                          setState(() {
                            phone = value;
                          });
                        },
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 36),
                      //password
                      CreateInput(
                        textAlign: TextAlign.center,
                        focusedBorderColor: const Color.fromARGB(
                          255,
                          0,
                          255,
                          234,
                        ),

                        labelText: 'password'.tr,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                        keyboardType: TextInputType.text,
                        isPassword: isPasswordVisible,
                        suffix: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 36),
                      //confirm password
                      CreateInput(
                        textAlign: TextAlign.center,
                        focusedBorderColor: const Color.fromARGB(
                          255,
                          0,
                          255,
                          234,
                        ),

                        labelText: 'confirm_password'.tr,
                        onChanged: (value) {
                          setState(() {
                            confirmPassword = value;
                          });
                        },
                        keyboardType: TextInputType.text,
                        isPassword: isPasswordVisible,
                        suffix: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 36),
                      //sign up btn
                      CreateButton(
                        title: Text(
                          'تسجيل'.tr,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ), // Key for "Sign Up",
                        onPressed: () async {
                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color.fromARGB(255, 160, 11, 0),
                                content: Text(
                                  "enter_email".tr,
                                ), // Key for "Enter Email"
                              ),
                            );
                          } else if (phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color.fromARGB(255, 160, 11, 0),
                                content: Text(
                                  "enter_phone".tr,
                                ), // Key for "Enter Phone"
                              ),
                            );
                          } else if (password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color.fromARGB(255, 160, 11, 0),
                                content: Text(
                                  "enter_password".tr,
                                ), // Key for "Enter Password"
                              ),
                            );
                          } else if (confirmPassword != password) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color.fromARGB(255, 160, 11, 0),
                                content: Text(
                                  "password_mismatch".tr,
                                ), // Key for "Check Your Password"
                              ),
                            );
                          } else {
                            try {
                              await _auth.createUserWithEmailAndPassword(
                                email: email,
                                password: password,
                              );
                              if (_auth.currentUser != null) {
                                _prefs = await SharedPreferences.getInstance();
                                await _prefs.setString(
                                  "email",
                                  _auth.currentUser!.email.toString(),
                                );

                                addUser();

                                Get.offAll(
                                  CompleteStudentData(
                                    studentCode: widget.studentCode,
                                  ),
                                );
                              }
                            } catch (e) {
                              print(e);
                              print(
                                "تحقق من بياناتك، قد يكون هذا البريد الإلكتروني مستخدمًا من قبل",
                              );

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('تنبيه'.tr),
                                  content: Text(
                                    'هذا الحساب موجود بالفعل، يرجى تسجيل الدخول أو إنشاء حساب جديد'.tr,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text('حسنا'.tr),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        },
                      ),
                      // SizedBox(height: 36),
                      //sign in btn
                      // TextButton(
                      //   onPressed: () {
                      //     Get.offAll(
                      //       SignInScreen(studentCode: widget.studentCode),
                      //     );
                      //   },
                      //   child: Text(
                      //     'already_have_account'.tr,
                      //     // Key for "Already have an account? Sign In"
                      //     style: TextStyle(
                      //       color: mainColor,
                      //       fontSize: 16,
                      //       fontFamily: 'Tajawal',
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
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
