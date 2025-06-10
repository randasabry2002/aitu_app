import 'package:aitu_app/screens/Distribution_Pages/Instructions.dart';
import 'package:aitu_app/screens/Sign_In&Up/SignUpScreen.dart';
// import 'package:aitu_app/screens/Sign_In&Up/SignInScreen.dart';
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
  List<String> stage = ['كلية متوسطة', 'كلية عليا', 'مدرسة'];

  String? selectedStage;
  List<String> departments = [
    'تكنولوجيا ميكانيكية',
    'تكنولوجيا كهربائية',
    'تكنولوجيا المعلومات',
  ];
  String? stuedentDepartment;
  List<String> gender = ['male', 'female'];
  String? selectedGender;
  String currentAddress = '';
  String birthDate = '';
  String birthAddress = '';
  String factory = '';
  int? selectedbatch;
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
        selectedbatch != null) {
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

  List<int> batch = [];
  List<int> getbatch(selectedStage) {
    if (selectedStage == 'كلية متوسطة') {
      batch = [1, 2];
    } else if (selectedStage == 'كلية عليا') {
      batch = [3, 4];
    } else if (selectedStage == 'مدرسة') {
      batch = [1, 2, 3];
    }
    return batch;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: () {
              Get.offAll(SignUpScreen(studentCode: widget.studentCode));
            },
          ),
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: Stack(
          children: [
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
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color.fromARGB(0, 94, 94, 94),
                            width: 0.5,
                          ),
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'مرحبا\n ',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 22,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: name,
                                style: TextStyle(
                                  color: mainColor,
                                  fontSize: 22,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(child: Divider(thickness: 0.5)),
                          SizedBox(width: 4),
                          Text(
                            'أكمل بياناتك',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 63, 63, 63),
                              fontSize: 14,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Expanded(child: Divider(thickness: 0.5)),
                        ],
                      ),
                      SizedBox(height: 40),

                      // Current Address
                      CreateInput(
                        controller: currentAddressController,
                        keyboardType: TextInputType.text,
                        onChanged:
                            (value) => setState(() => currentAddress = value),
                        labelText: 'مكانك الحالي',
                        textAlign: TextAlign.center,
                        focusedBorderColor: const Color.fromARGB(
                          255,
                          0,
                          255,
                          234,
                        ),
                        color: const Color.fromARGB(70, 255, 255, 255),
                        borderColor: secondaryColor,
                        labelColor: mainColor,
                      ),
                      SizedBox(height: 30.0),

                      // Birth Address
                      CreateInput(
                        controller: birthAddressController,
                        keyboardType: TextInputType.text,
                        onChanged:
                            (value) => setState(() => birthAddress = value),
                        labelText: 'مكان الميلاد',
                        textAlign: TextAlign.center,
                        focusedBorderColor: const Color.fromARGB(
                          255,
                          0,
                          255,
                          234,
                        ),
                        color: const Color.fromARGB(70, 255, 255, 255),
                        borderColor: secondaryColor,
                        labelColor: mainColor,
                      ),
                      SizedBox(height: 30.0),

                      // Birth Date
                      CreateInput(
                        controller: birthDateController,
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            birthDate = value;
                          });
                        },
                        labelText: 'تاريخ الميلاد',
                        textAlign: TextAlign.center,
                        focusedBorderColor: const Color.fromARGB(
                          255,
                          0,
                          255,
                          234,
                        ),
                        color: const Color.fromARGB(70, 255, 255, 255),
                        borderColor: secondaryColor,
                        labelColor: mainColor,
                        isReadOnly: true,
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
                              birthDate = pickedDate.toString();
                            });
                          }
                        },
                      ),
                      SizedBox(height: 30.0),

                      //stage
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: mainColor),
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
                              'المرحلة الدراسية',
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 16,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: selectedStage,
                            onChanged: (newValue) {
                              setState(() {
                                selectedStage = newValue;
                                selectedbatch = null;
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
                                        fontFamily: 'Tajawal',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0),

                      //batch
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: mainColor),
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
                              'السنة الدراسية',
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 16,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: selectedbatch,
                            onChanged: (newValue) {
                              setState(() {
                                selectedbatch = newValue;
                              });
                            },
                            items:
                                getbatch(selectedStage).map((g) {
                                  return DropdownMenuItem<int>(
                                    value: g,
                                    child: Text(
                                      'سنة ' + g.toString(),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Tajawal',
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0),

                      //department
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: mainColor),
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
                              'القسم',
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 16,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w500,
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
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Tajawal',
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0),

                      //gender
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: mainColor),
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
                              'الجنس',
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 16,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: selectedGender,
                            onChanged: (newValue) {
                              setState(() {
                                selectedGender = newValue;
                              });
                            },
                            items:
                                gender.map((g) {
                                  return DropdownMenuItem<String>(
                                    value: g,
                                    child: Text(
                                      g == 'male' ? 'ذكر' : 'أنثى',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Tajawal',
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),

                      SizedBox(height: 60),

                      //next button
                      CreateButton(
                        title: Text(
                          'التالي',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        onPressed: () async {
                          checkDataComplete();
                          if (isDataCompleted == true) {
                            await FirebaseFirestore.instance
                                .collection('StudentsTable')
                                .doc(widget.studentCode)
                                .update({
                                  'batch': selectedbatch,
                                  'department': stuedentDepartment,
                                  'gender': selectedGender,
                                  'birthDate': birthDate,
                                  'address': currentAddress,
                                  'birthAddress': birthAddress,
                                  'stage': selectedStage,
                                  'createOn': DateTime.now().toString(),
                                });
                            Get.offAll(Instructions());
                          } else {
                            Get.snackbar(
                              'تنبيه',
                              'يرجى إدخال جميع البيانات المطلوبة',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                              duration: Duration(seconds: 3),
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
