import 'package:aitu_app/screens/student%20data/completeStudentData.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnterStudentCode extends StatefulWidget {
  @override
  State<EnterStudentCode> createState() => _EnterStudentCodeState();
}

class _EnterStudentCodeState extends State<EnterStudentCode> {
  String studentCode = '';
  bool isStudentCodeValid = false;

  Future<void> getDataWithStudentId() async {
    isStudentCodeValid = false;
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance
            .collection('StudentsTable')
            .where('code', isEqualTo: studentCode)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      isStudentCodeValid = true;
      setState(() {});
    } else {
      isStudentCodeValid = false;
      setState(() {});
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
          elevation: 20.0,
          backgroundColor: mainColor,
          automaticallyImplyLeading: false,
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
            Image(
              image: backgroundImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            //body:
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 25.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //title
                      Text(
                        'Enter your code'.tr, // Translation key for "Sign Up"
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          // fontFamily: 'mainFont',
                        ),
                      ),
                      SizedBox(height: 40),
                      //code
                      CreateInput(
                        onChanged: (value) {
                          studentCode = value;
                        },
                        labelText: 'code'.tr, // Translation key for "Email"
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 80),

                      //next buttno
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

                          await getDataWithStudentId();

                          if (isStudentCodeValid) {
                            // Navigate to the CompleteStudentData page
                            Get.offAll(
                              CompleteStudentData(studentCode: studentCode),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("code not found!".tr)),
                            );
                          }
                        },
                        title: Text(
                          'Start'.tr,
                          style: TextStyle(
                            fontSize: 24,
                            color: mainColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'mainFont',
                          ),
                        ), // Key for "Sign Up",
                      ),
                      SizedBox(height: 16),
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
