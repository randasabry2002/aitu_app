import 'package:aitu_app/screens/Sign_In&Up/SignInScreen.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// import '../Distribution_Pages/Instructions.dart';

// ignore: must_be_immutable
class CompleteStudentData extends StatefulWidget {
  @override
  State<CompleteStudentData> createState() => _CompleteStudentDataState();

  String studentCode = '';
  CompleteStudentData({super.key, required this.studentCode});
}

class _CompleteStudentDataState extends State<CompleteStudentData> {
  DocumentSnapshot? studentDoc;
  // String studentCode = '';
  String name = '';
  List<String> stage = ['معهد', 'كلية', 'مدرسة'];
  List<int> grade = [1, 2, 3, 4];

  String? selectedStage;
  List<String> departments = [
    'Mechanical Technology',
    'Electrical Technology',
    'Information Technology',
  ];
  String? stuedentDepartment;
  List<String> gender = ['male', 'female'];
  String? selectedGender;
  String currentAddress = '';
  String birthAddress = '';
  String factory = '';
  int? selectedGrade;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController factoryController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController currentAddressController =
      TextEditingController();
  final TextEditingController birthAddressController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  Future<void> getDataWithStudentId() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance
            .collection('StudentsTable')
            .where('code', isEqualTo: widget.studentCode)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      studentDoc = querySnapshot.docs.first;
      name = studentDoc!['name'] ?? '';
    }
  }

  bool isDataCompleted = false;

  void checkDataComplete() {
    if (selectedStage != null &&
        stuedentDepartment != null &&
        selectedGender != null &&
        birthAddressController.text.isNotEmpty &&
        currentAddress.isNotEmpty &&
        birthAddress.isNotEmpty &&
        factory.isNotEmpty &&
        selectedGrade != null) {
      isDataCompleted = true;
    } else {
      isDataCompleted = false;
    }
  }

  @override
  void initState() {
    super.initState();
    getDataWithStudentId().then((_) {
      setState(() {});
    });
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
          backgroundColor: secondaryColor,
          // automaticallyImplyLeading: false,
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

                      //name
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        // margin: EdgeInsets.symmetric(horizontal: 20.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(199, 255, 255, 255),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: mainColor, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //name and avatar
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color.fromARGB(
                                255,
                                255,
                                255,
                                255,
                              ),
                              child: Icon(
                                Icons.account_circle,
                                size: 30,
                                color: mainColor,
                              ),
                            ),
                            SizedBox(width: 20),
                            Text(
                              name.tr,
                              style: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontSize: 22,
                                fontFamily: 'mainFont',
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          SizedBox(width: 4),
                          Text(
                            'Complete your data'.tr,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 63, 63, 63),
                              fontSize: 14,
                              fontFamily: 'mainFont',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Expanded(child: Divider()),
                        ],
                      ),
                      SizedBox(height: 40),

                      // SizedBox(height: 60),
                      // Factory
                      CreateInput(
                        controller: factoryController,
                        keyboardType: TextInputType.text,
                        onChanged: (value) => setState(() => factory = value),
                        labelText: 'factory'.tr,
                      ),
                      SizedBox(height: 24.0),

                      // Current Address
                      CreateInput(
                        controller: currentAddressController,
                        keyboardType: TextInputType.text,
                        onChanged:
                            (value) => setState(() => currentAddress = value),
                        labelText: 'Your current address'.tr,
                      ),
                      SizedBox(height: 24.0),

                      // Birth Address
                      CreateInput(
                        controller: birthAddressController,
                        keyboardType: TextInputType.text,
                        onChanged:
                            (value) => setState(() => birthAddress = value),
                        labelText: 'Birth address'.tr,
                      ),
                      SizedBox(height: 24.0),

                      // Birth Date
                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Color(0xFF0187c4),
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (pickedDate != null) {
                            setState(() {
                              birthDateController.text =
                                  '${pickedDate.toLocal()}'.split(' ')[0];
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            readOnly: true,
                            controller: birthDateController,
                            onChanged:
                                (value) => setState(
                                  () => birthAddressController.text = value,
                                ),
                            decoration: InputDecoration(
                              labelText: 'Birth date'.tr,
                              labelStyle: TextStyle(
                                color: mainColor,
                                fontSize: 16,
                                fontFamily: 'mainFont',
                                fontWeight: FontWeight.bold,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: secondaryColor),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: mainColor),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.0),

                      //stage
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          border: Border.all(color: secondaryColor),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            borderRadius: BorderRadius.circular(15),
                            dropdownColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                            hint: Text(
                              'stage'.tr,
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 16,
                                fontFamily: 'mainFont',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: selectedStage,
                            onChanged: (newValue) {
                              setState(() {
                                selectedStage = newValue;
                              });
                            },
                            items:
                                stage.map((stage) {
                                  return DropdownMenuItem<String>(
                                    value: stage,
                                    child: Text(
                                      stage,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'mainFont',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.0),
                      //grade
                        Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          border: Border.all(color: secondaryColor),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                          borderRadius: BorderRadius.circular(15),
                          dropdownColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                          hint: Text(
                            'select your academic year'.tr,
                            style: TextStyle(
                            color: mainColor,
                            fontSize: 16,
                            fontFamily: 'mainFont',
                            fontWeight: FontWeight.bold,
                            ),
                          ),
                          value: selectedGrade,
                          onChanged: (newValue) {
                            setState(() {
                            selectedGrade = newValue;
                            });
                          },
                          items: grade.map((g) {
                            return DropdownMenuItem<int>(
                            value: g,
                            child: Text(
                              g.toString(),
                              style: TextStyle(
                              color: mainColor,
                              fontSize: 16.0,
                              fontFamily: 'mainFont',
                              fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            );
                          }).toList(),
                          ),
                        ),
                        ),
                      SizedBox(height: 24.0),
                      //department
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          border: Border.all(color: secondaryColor),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            borderRadius: BorderRadius.circular(15),
                            dropdownColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                            hint: Text(
                              'department'.tr,
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 16,
                                fontFamily: 'mainFont',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: stuedentDepartment,
                            onChanged: (newValue) {
                              setState(() {
                                stuedentDepartment = newValue;
                              });
                            },
                            items:
                                departments.map((department) {
                                  return DropdownMenuItem<String>(
                                    value: department,
                                    child: Text(
                                      department,
                                      style: TextStyle(
                                        color: mainColor,
                                        fontSize: 16,
                                        fontFamily: 'mainFont',
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.0),
                      //gender
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          border: Border.all(color: secondaryColor),
                          borderRadius: BorderRadius.circular((15)),
                        ),
                        child: DropdownButton<String>(
                          borderRadius: BorderRadius.circular(15),
                          dropdownColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                          hint: Text(
                            'your gender'.tr,
                            style: TextStyle(
                              color: mainColor,
                              fontSize: 16,
                              fontFamily: 'mainFont',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          value: selectedGender,
                          onChanged: (newValue) {
                            setState(() {
                              selectedGender = newValue;
                            });
                          },
                          items:
                              gender.map((gender) {
                                return DropdownMenuItem<String>(
                                  value: gender,
                                  child: Text(
                                    gender,
                                    style: TextStyle(
                                      color: mainColor,
                                      fontSize: 16,
                                      fontFamily: 'mainFont',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }).toList(),
                        ),
                      ),

                      SizedBox(height: 60),

                      //next button
                      CreateButton(
                        title: Text(
                          'Next'.tr,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'mainFont',
                          ),
                        ), // Key for "Sign Up",
                        onPressed: () async {
                          checkDataComplete();
                          // Check if all required fields are filled
                          if (isDataCompleted == true) {
                            await FirebaseFirestore.instance
                                .collection('StudentsTable')
                                .doc(widget.studentCode)
                                .update({
                                  'grade': selectedGrade,
                                  'department': stuedentDepartment,
                                  'gender': selectedGender,
                                  'birthDate': birthDateController.text,
                                  'address': currentAddress,
                                  'birthAddress': birthAddress,
                                  'factory': factory,
                                  'stage': selectedStage,
                                });
                            // Navigate to the next page
                            Get.offAll(
                              SignInScreen(studentCode: widget.studentCode),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please complete all required fields.'.tr,
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
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
