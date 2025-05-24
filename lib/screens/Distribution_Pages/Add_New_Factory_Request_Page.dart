import 'package:aitu_app/screens/Distribution_Pages/watingRequestAnswer.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Add_New_Factory_Request_Page extends StatefulWidget {
  @override
  State<Add_New_Factory_Request_Page> createState() =>
      _Add_New_Factory_Request_PageState();

  Add_New_Factory_Request_Page({super.key});
}

class _Add_New_Factory_Request_PageState
    extends State<Add_New_Factory_Request_Page> {
  // دالة لجلب بيانات المحافظات من Firestore
  List<String> governorateNames = [];

  Future<void> fetchGovernorates() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Governorates").get();
    selectedGovernorateID = querySnapshot.docs.first.id;
    // تحويل البيانات إلى قائمة من النصوص
    setState(() {
      governorateNames =
          querySnapshot.docs.map((doc) => doc["GName"] as String).toList();
    });
  }

  List<Map<String, dynamic>> governorates = [];
  List<String> types = ['internal', 'external'];
  String? selectedType;
  String? selectedGovernorate;
  String? selectedGovernorateID;
  String? factoryID;
  final TextEditingController factoryNameController = TextEditingController();
  final TextEditingController factoryAddressController =
      TextEditingController();
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController industryController = TextEditingController();
  final TextEditingController studentsNumberController =
      TextEditingController();

  bool isDataCompleted = false;

  Future<void> getGovernorates() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Governorates').get();
    setState(() {
      governorates =
          querySnapshot.docs
              .map((doc) => {'name': doc['name'], 'id': doc.id})
              .toList();
    });
  }

  void checkDataComplete() {
    if (selectedGovernorate != null &&
        factoryNameController.text.isNotEmpty &&
        factoryAddressController.text.isNotEmpty &&
        contactNameController.text.isNotEmpty &&
        contactNumberController.text.isNotEmpty &&
        industryController.text.isNotEmpty) {
      isDataCompleted = true;
    } else {
      isDataCompleted = false;
    }
  }

  @override
  void initState() {
    super.initState();
    getGovernorates();
    fetchGovernorates();
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String? userEmail = currentUser?.email;

    Future<String?> getStudentId() async {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('StudentsTable')
              .where('email', isEqualTo: userEmail)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      return null;
    }

    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: () {
              Get.back();
            },
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          // actions: <Widget>[
          //   PopupMenuButton<String>(
          //     icon: Icon(Icons.language, color: Colors.white),
          //     onSelected: (value) {
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
                    children: [
                      SizedBox(height: 40),
                      Text(
                        'طلب على مصنع خارجي'.tr,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                          fontFamily: 'Tajawal',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'هنا يمكنك تقديم طلب لإنشاء مصنع جديد. يُرجى ملء التفاصيل أدناه لمساعدتنا في فهم فكرتك ومعالجة طلبك.'
                            .tr,
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      // Factory Name
                      CreateInput(
                        // controller: factoryNameController,
                        keyboardType: TextInputType.text,
                        labelText: 'اسم المصنع',
                        onChanged: (value) {
                          setState(() {
                            factoryNameController.text = value;
                          });
                        },
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
                      // Factory Address
                      CreateInput(
                        // controller: factoryAddressController,
                        keyboardType: TextInputType.text,
                        labelText: 'عنوان المصنع',
                        onChanged: (value) {
                          setState(() {
                            factoryAddressController.text = value;
                          });
                        },
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
                      // Contact Name
                      CreateInput(
                        // controller: contactNameController,
                        keyboardType: TextInputType.text,
                        labelText: 'اسم المسؤول',
                        onChanged: (value) {
                          setState(() {
                            contactNameController.text = value;
                          });
                        },
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
                      // Contact Number
                      CreateInput(
                        // controller: contactNumberController,
                        keyboardType: TextInputType.phone,
                        labelText: 'رقم الهاتف',
                        onChanged: (value) {
                          setState(() {
                            contactNumberController.text = value;
                          });
                        },
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
                      // Industry
                      CreateInput(
                        // controller: industryController,
                        keyboardType: TextInputType.text,
                        labelText: 'الصناعة',
                        onChanged: (value) {
                          setState(() {
                            industryController.text = value;
                          });
                        },
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
                      // Governorate Dropdown
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: mainColor),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(20),
                            dropdownColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                            hint: Text(
                              'اختر المحافظة',
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 16,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: selectedGovernorate,
                            onChanged: (newValue) {
                              setState(() {
                                selectedGovernorate = newValue;
                              });
                            },
                            items:
                                governorateNames
                                    .map(
                                      (gov) => DropdownMenuItem<String>(
                                        value: gov,
                                        child: Text(
                                          gov,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Tajawal',
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0),
                      SizedBox(height: 60),
                      // request Button
                      CreateButton(
                        title: Text(
                          'إنشاء طلب',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        onPressed: () async {
                          try {
                            checkDataComplete();
                            if (isDataCompleted) {
                              await FirebaseFirestore.instance
                                  .collection('Factories')
                                  .add({
                                    'Governorate': selectedGovernorate,
                                    'name': factoryNameController.text,
                                    'address': factoryAddressController.text,
                                    'contactName': contactNameController.text,
                                    'phone': contactNumberController.text,
                                    'industry': industryController.text,
                                    'StudentsID': await getStudentId(),
                                    'type': "external",
                                    'isApproved': false,
                                    'assignedStudents': 0,
                                    'capacity': 0,
                                    'id': factoryID,
                                    'studentName': (await FirebaseFirestore
                                            .instance
                                            .collection('StudentsTable')
                                            .doc(await getStudentId())
                                            .get())
                                        .get('name'),
                                    'students': <String>[],
                                    'createdAt': DateTime.now().toString(),
                                  });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم إرسال طلب المصنع بنجاح!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              QuerySnapshot querySnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('Factories')
                                      .get();
                              setState(() {
                                factoryID =
                                    querySnapshot
                                        .docs
                                        .last
                                        .id; // Get the last factory ID
                              });
                              Get.offAll(
                                WaitnigReqestAnswer(
                                  // factoryID: factoryID.toString(),
                                  factoryIndustry: industryController.text,
                                  fatoryGovernorate:
                                      selectedGovernorate.toString(),
                                  factoryName: factoryNameController.text,
                                  factoryLocation:
                                      factoryAddressController.text,
                                ),
                              );

                              factoryNameController.clear();
                              factoryAddressController.clear();
                              contactNameController.clear();
                              contactNumberController.clear();
                              industryController.clear();
                              studentsNumberController.clear();
                              setState(() {
                                selectedGovernorate = null;
                                selectedGovernorateID = null;
                              });
                            } else if (selectedGovernorate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'الرجاء اختيار المحافظة',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    160,
                                    11,
                                    0,
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'يرجى إكمال جميع الحقول المطلوبة',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    160,
                                    11,
                                    0,
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text('Error'.tr),
                                    content: Text(e.toString()),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                        child: Text('OK'.tr),
                                      ),
                                    ],
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
