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
  late final SharedPreferences _prefs ;

  addUser() async {
    DocumentReference docRef =await _firestor.collection("StudentsTable").add({
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

    await _prefs.setString(
        "studentId", studentId);
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
          automaticallyImplyLeading: false,
          actions: <Widget>[
            // Language Selector Icon
            PopupMenuButton<String>(
              icon: Icon(Icons.language, color: Colors.white,),
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
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16.0,0,16.0,25.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'sign_up'.tr, // Translation key for "Sign Up"
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  //name
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'name'.tr, // Translation key for "Email"
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
                  //email
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'email'.tr, // Translation key for "Email"
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
                  //major
                  DropdownButtonFormField<String>(
                  value: selectedMajor,
                  onChanged: (value) {
                    setState(() {
                      selectedMajor = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'major'.tr, // Translation key for "Major"
                    labelStyle: TextStyle(color: Colors.white,fontSize: 17),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white,fontSize: 17), // Text style for dropdown items
                  dropdownColor: Colors.blue, // Background color for dropdown menu
                  items: [
                    {'key': 'IT', 'label': 'IT'.tr},
                    {'key': 'electrical', 'label': 'electrical'.tr},
                    {'key': 'mechanics', 'label': 'mechanics'.tr},
                  ].map((item) {
                    return DropdownMenuItem<String>(
                      value: item['key'], // Use the key for value
                      child: Text(item['label']!), // Use the translated label
                    );
                  }).toList(),
                ),
                  SizedBox(height: 16),
                  //academicYear
                  DropdownButtonFormField<String>(
                    value: academicYear,
                    onChanged: (value) {
                      setState(() {
                        academicYear = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'academic_year'.tr, // Translation key for "academic_year"
                      labelStyle: TextStyle(color: Colors.white,fontSize: 17),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white,fontSize: 17), // Text style for dropdown items
                    dropdownColor: Colors.blue, // Background color for dropdown menu
                    items: [
                      {'key': '1', 'label': '1'},
                      {'key': '2', 'label': '2'},
                      {'key': '3', 'label': '3'},
                      {'key': '4', 'label': '4'},
                    ].map((item) {
                      return DropdownMenuItem<String>(
                        value: item['key'], // Use the key for value
                        child: Text(item['label']!), // Use the translated label
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  //phone
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        phone = value;
                      });
                    },
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'phone'.tr, // Translation key for "Email"
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
                  //password
                  TextField(
                    obscureText: isPasswordVisible,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                    keyboardType: TextInputType.text,
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
                      // Translation key for "Password"
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
                  //confirm password
                  TextField(
                    obscureText: isPasswordVisible,
                    onChanged: (value) {
                      setState(() {
                        confirmPassword = value;
                      });
                    },
                    keyboardType: TextInputType.text,
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
                      labelText: 'confirm_password'.tr,
                      // Key for "Confirm Password"
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
                  SizedBox(height: 24),
                  //sign up btn
                  ElevatedButton(
                    onPressed: () async {
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "enter_name".tr), // Key for "Enter Name"
                        ));
                      }
                      else if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "enter_email".tr), // Key for "Enter Email"
                        ));
                      }
                      else if (selectedMajor != 'IT' && selectedMajor != 'electrical' && selectedMajor != 'mechanics') {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "select_major".tr), // Key for "Select Major"
                        ));
                      }
                      else if (academicYear != '1' && academicYear != '2' && academicYear != '3' && academicYear != '4') {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "select_academicYear".tr), // Key for "Select AcademicYear"
                        ));
                      }
                      else if (phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "enter_phone".tr), // Key for "Enter Phone"
                        ));
                      }
                      else if (password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "enter_password".tr), // Key for "Enter Password"
                        ));
                      }
                      else if (confirmPassword != password) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("password_mismatch"
                              .tr), // Key for "Check Your Password"
                        ));
                      }
                      else {
                        try {
                          await _auth.createUserWithEmailAndPassword(
                              email: email,
                              password: password);
                          if (_auth.currentUser != null) {
                            // final SharedPreferences _prefs =
                            // await SharedPreferences.getInstance();
                            _prefs = await SharedPreferences.getInstance();
                            await _prefs.setString(
                                "email", _auth.currentUser!.email.toString());

                            addUser();

                            Get.offAll(Instructions());
                          }
                        }catch (e) {
                          print(e);
                          print("Check Your Data, This Email may be used before $e");
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Check Your Data, This Email may be used before"),
                          ));
                        }
                      }
                    },
                    child: Text('sign_up'.tr,style: TextStyle(fontSize: 20,color: Color(0xFF0187c4),fontWeight: FontWeight.bold),), // Key for "Sign Up"
                  ),
                  SizedBox(height: 16),
                  //sign in btn
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(
                      'already_have_account'.tr,
                      // Key for "Already have an account? Sign In"
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
