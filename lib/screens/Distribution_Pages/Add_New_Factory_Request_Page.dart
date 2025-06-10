import 'package:aitu_app/screens/Distribution_Pages/watingRequestAnswer.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide GeoPoint;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Add_New_Factory_Request_Page extends StatefulWidget {
  Add_New_Factory_Request_Page({super.key});

  @override
  State<Add_New_Factory_Request_Page> createState() =>
      _Add_New_Factory_Request_PageState();
}

class _Add_New_Factory_Request_PageState
    extends State<Add_New_Factory_Request_Page> {
  double? latitude;
  double? longitude;

  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController factoryAddressController =
      TextEditingController();

  String? factoryID;
  final TextEditingController factoryNameController = TextEditingController();
  String? formattedAddress;
  List<String> governorateNames = [];
  List<Map<String, dynamic>> governorates = [];
  final TextEditingController industryController = TextEditingController();
  bool isDataCompleted = false;
  String? selectedGovernorate;
  String? selectedGovernorateID;
  String? selectedType;
  final TextEditingController studentsNumberController =
      TextEditingController();

  List<String> types = ['internal', 'external'];

  @override
  void initState() {
    super.initState();
    getGovernorates();
    fetchGovernorates();
    requestLocationPermission();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  Future<void> fetchGovernorates() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Governorates").get();
    selectedGovernorateID = querySnapshot.docs.first.id;
    setState(() {
      governorateNames =
          querySnapshot.docs.map((doc) => doc["GName"] as String).toList();
    });
  }

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
        latitude != null &&
        longitude != null) {
      isDataCompleted = true;
    } else {
      isDataCompleted = false;
    }
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
                      // Location Picker Button
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          // vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                latitude != null ? mainColor : secondaryColor,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          color:
                              latitude != null
                                  ? mainColor
                                  : const Color.fromARGB(70, 255, 255, 255),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => _LocationPickerPage(),
                              ),
                            );

                            if (result != null) {
                              setState(() {
                                latitude = result['lat'];
                                longitude = result['lng'];
                              });
                            }
                          },
                          child: Text(
                            'اختر الموقع',
                            style: TextStyle(
                              color:
                                  latitude != null ? Colors.white : mainColor,
                              fontSize: 16,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      // SizedBox(height: 20),
                      if (latitude != null && longitude != null)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: mainColor),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'الموقع المختار',
                                style: TextStyle(
                                  color: mainColor,
                                  fontSize: 18,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'خط العرض: ${latitude!.toStringAsFixed(6)}',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              Text(
                                'خط الطول: ${longitude!.toStringAsFixed(6)}',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 30.0),
                      // Factory Address
                      CreateInput(
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
                                    'latitude': latitude,
                                    'longitude': longitude,
                                    'formattedAddress': formattedAddress,
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
                              final prefs = await SharedPreferences.getInstance();
                              final String? studentEmail = prefs.getString("email");
                              if (studentEmail != null) {
                                await FirebaseFirestore.instance
                                    .collection('StudentsTable')
                                    .where('email', isEqualTo: studentEmail)
                                    .get()
                                    .then((querySnapshot) {
                                  if (querySnapshot.docs.isNotEmpty) {
                                    querySnapshot.docs.first.reference.update({
                                      'isReportUploaded': false,
                                    });
                                  }
                                });
                              }

                              QuerySnapshot querySnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('Factories')
                                      .get();
                              setState(() {
                                factoryID = querySnapshot.docs.last.id;
                              });
                              Get.offAll(
                                WaitnigReqestAnswer(
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
                                latitude = null;
                                longitude = null;
                                formattedAddress = null;
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

class _LocationPickerPage extends StatefulWidget {
  @override
  __LocationPickerPageState createState() => __LocationPickerPageState();
}

class __LocationPickerPageState extends State<_LocationPickerPage> {
  LatLng? selectedLocation;
  final TextEditingController searchController = TextEditingController();
  final MapController mapController = MapController();
  bool isLoading = false;

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query&countrycodes=eg&limit=1',
        ),
        headers: {'User-Agent': 'AITU_App'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);

          setState(() {
            selectedLocation = LatLng(lat, lon);
            mapController.move(LatLng(lat, lon), 15.0);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'لم يتم العثور على الموقع',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: mainColor,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء البحث',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: mainColor,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'اختر موقع المصنع',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: mainColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: mainColor,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: searchController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ابحث عن موقع...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Tajawal',
                  ),
                  prefixIcon:
                      isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                mainColor,
                              ),
                            ),
                          )
                          : Icon(Icons.search, color: mainColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onSubmitted: searchLocation,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: LatLng(30.0444, 31.2357), // init (cairo)
                    initialZoom: 13.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        selectedLocation = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    if (selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedLocation!,
                            width: 80,
                            height: 80,
                            child: Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 200,
        child: FloatingActionButton.extended(
          onPressed: () {
            if (selectedLocation != null) {
              Navigator.pop(context, {
                'lat': selectedLocation!.latitude,
                'lng': selectedLocation!.longitude,
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'من فضلك اختر موقعًا أولاً',
                    style: TextStyle(fontFamily: 'Tajawal'),
                  ),
                  backgroundColor: const Color.fromARGB(255, 168, 1, 1),
                ),
              );
            }
          },
          backgroundColor: mainColor,
          icon: Icon(Icons.check, color: Colors.white),
          label: Text(
            'تأكيد الموقع',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
