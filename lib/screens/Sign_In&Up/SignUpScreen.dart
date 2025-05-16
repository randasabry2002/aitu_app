import 'package:aitu_app/screens/student%20data/enterCode.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Distribution_Pages/Instructions.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String password = '';
  String confirmPassword = '';
  String email = '';
  String phone = '';
  String name = '';
  String? academicYear;
  bool isPasswordVisible = true;
  String? selectedMajor; // Holds the selected value
  final _auth = FirebaseAuth.instance;
  var _firestor = FirebaseFirestore.instance;
  late final SharedPreferences _prefs;

  addUser() async {
    DocumentReference docRef = await _firestor.collection("StudentsTable").add({
      "Name": name,
      "Email": email,
      "Major": selectedMajor,
      "AcademicYear": academicYear,
      "Phone": phone,
      "Password": password,
    });
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
          backgroundColor: Color(0xFF0187c4),
          automaticallyImplyLeading: false,
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
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 25.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),

                      Text(
                        'sign_up'.tr, // Translation key for "Sign Up"
                        style: TextStyle(
                          color: mainColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'mainFont',
                        ),
                      ),
                      SizedBox(height: 60),
                      //name
                      CreateInput(
                        labelText: 'name'.tr,
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 28),
                      //email
                      CreateInput(
                        labelText: 'email'.tr,
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 28),
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
                        labelText: 'phone'.tr,
                        onChanged: (value) {
                          setState(() {
                            phone = value;
                          });
                        },
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 28),
                      //password
                      CreateInput(
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
                      SizedBox(height: 28),
                      //confirm password
                      CreateInput(
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
                      SizedBox(height: 28),
                      //sign up btn
                      CreateButton(
                        title: 'sign_up'.tr,
                        onPressed: () async {
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "enter_name".tr,
                                ), // Key for "Enter Name"
                              ),
                            );
                          } else if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "enter_email".tr,
                                ), // Key for "Enter Email"
                              ),
                            );
                          }
                          // else if (selectedMajor != 'IT' && selectedMajor != 'electrical' && selectedMajor != 'mechanics') {
                          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          //   content: Text(
                          //     "select_major".tr), // Key for "Select Major"
                          // ));
                          // }
                          // else if (academicYear != '1' && academicYear != '2' && academicYear != '3' && academicYear != '4') {
                          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          //   content: Text(
                          //     "select_academicYear".tr), // Key for "Select AcademicYear"
                          // ));
                          // }
                          else if (phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "enter_phone".tr,
                                ), // Key for "Enter Phone"
                              ),
                            );
                          } else if (password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "enter_password".tr,
                                ), // Key for "Enter Password"
                              ),
                            );
                          } else if (confirmPassword != password) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
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

                                Get.offAll(EnterStudentCode());
                              }
                            } catch (e) {
                              print(e);
                              print(
                                "Check Your Data, This Email may be used before $e",
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Check Your Data, This Email may be used before",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      SizedBox(height: 28),
                      //sign in btn
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          'already_have_account'.tr,
                          // Key for "Already have an account? Sign In"
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 16,
                            fontFamily: 'mainFont',
                            fontWeight: FontWeight.bold,
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
