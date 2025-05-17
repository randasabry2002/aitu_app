import 'package:aitu_app/screens/Distribution_Pages/watingRequestAnswer.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
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

    // تحويل البيانات إلى قائمة من النصوص
    setState(() {
      governorateNames =
          querySnapshot.docs.map((doc) => doc["GName"] as String).toList();
    });
  }

  List<Map<String, dynamic>> governorates = [];
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
        industryController.text.isNotEmpty &&
        studentsNumberController.text.isNotEmpty) {
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
    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          elevation: 20.0,
          backgroundColor: mainColor,
          actions: <Widget>[
            PopupMenuButton<String>(
              icon: Icon(Icons.language, color: Colors.white),
              onSelected: (value) {
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
                      Text(
                        'Add New Factory'.tr,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                          fontFamily: 'mainFont',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Here you can submit a request to create a new factory. Please fill in the details below to help us understand your idea and process your request.'
                            .tr,
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      // Governorate Dropdown
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          border: Border.all(color: mainColor),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(15),
                            dropdownColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                            hint: Text(
                              'Choose Governorate'.tr,
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 16,
                                fontFamily: 'mainFont',
                                fontWeight: FontWeight.bold,
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
                                            fontFamily: 'mainFont',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.0),
                      // Factory Name
                      CreateInput(
                        keyboardType: TextInputType.text,
                        labelText: 'Factory Name'.tr,
                        onChanged: (value) {
                          setState(() {
                            factoryNameController.text = value;
                          });
                        },
                      ),
                      SizedBox(height: 24.0),
                      // Factory Address
                      CreateInput(
                        keyboardType: TextInputType.text,
                        labelText: 'Factory Address'.tr,
                        onChanged: (value) {
                          setState(() {
                            factoryAddressController.text = value;
                          });
                        },
                      ),
                      SizedBox(height: 24.0),
                      // Contact Name
                      CreateInput(
                        keyboardType: TextInputType.text,
                        labelText: 'Contact Name'.tr,
                        onChanged: (value) {
                          setState(() {
                            contactNameController.text = value;
                          });
                        },
                      ),
                      SizedBox(height: 24.0),
                      // Contact Number
                      CreateInput(
                        keyboardType: TextInputType.phone,
                        labelText: 'Contact Number'.tr,
                        onChanged: (value) {
                          setState(() {
                            contactNumberController.text = value;
                          });
                        },
                      ),
                      SizedBox(height: 24.0),
                      // Industry
                      CreateInput(
                        keyboardType: TextInputType.text,
                        labelText: 'Industry'.tr,
                        onChanged: (value) {
                          setState(() {
                            industryController.text = value;
                          });
                        },
                      ),
                      SizedBox(height: 24.0),
                      // Students Number
                      CreateInput(
                        keyboardType: TextInputType.number,
                        labelText: 'Students Number'.tr,
                        onChanged: (value) {
                          setState(() {
                            studentsNumberController.text = value;
                          });
                        },
                      ),
                      SizedBox(height: 60),
                      // Submit Button
                      CreateButton(
                        title: Text(
                          'create request'.tr,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'mainFont',
                          ),
                        ),
                        onPressed: () async {
                          checkDataComplete();
                          if (isDataCompleted) {
                            await FirebaseFirestore.instance
                                .collection('Factories')
                                .add({
                                  'Governorate': selectedGovernorate,
                                  'Name': factoryNameController.text,
                                  'factory address':
                                      factoryAddressController.text,
                                  'Contact Name': contactNameController.text,
                                  'Contact Num': contactNumberController.text,
                                  'Industry': industryController.text,
                                  'Students Number':
                                      studentsNumberController.text,
                                  'GevornrateID': selectedGovernorateID,
                                  'IN_or_OUT': false,
                                });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Factory request submitted!'.tr),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
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
                            QuerySnapshot querySnapshot =
                                await FirebaseFirestore.instance
                                    .collection('Factories')
                                    .get();
                            setState(() {
                              factoryID =
                                  querySnapshot.docs.last.id; // Get the last factory ID
                            });
                            Get.offAll(WaitnigReqestAnswer(factoryID: factoryID.toString()));
                          } else if (selectedGovernorate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please select a governorate.'.tr,
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
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
