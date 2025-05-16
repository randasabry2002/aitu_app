// import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'exitFactory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class EnterFactory extends StatefulWidget {
  const EnterFactory({super.key});

  @override
  State<EnterFactory> createState() => _EnterFactoryState();
}

class _EnterFactoryState extends State<EnterFactory> {
  String trainingPlaceName = "";
  String supervisorName = "";
  String studentId = "";
  DateTime date = DateTime.now();
  late var latitude;
  late var longitude;
  bool show_spinkit = false;
  bool show_done_location = false;
  LatLng latLng = LatLng(45.521563, -122.677433);
  var _firestor = FirebaseFirestore.instance;
  String attendanceId = "";
  bool spinkitVisable_submit = false;

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Chick location service
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // خدمات الموقع معطلة، لا يمكن الاستمرار
      print("Location services are disabled.");
      return;
    }

    // تحقق من حالة الإذن
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // المستخدم رفض الإذن
        print("Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // المستخدم رفض الإذن بشكل دائم
      print("Location permissions are permanently denied.");
      return;
    }

    // الحصول على الموقع
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
    latitude = position.latitude;
    longitude = position.longitude;
    try {
      // تحقق من حالة الاتصال بالإنترنت
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print("لابد من الاتصال بالإنترنت للحصول على الموقع.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('internet_disconnect'.tr),
            duration: Duration(seconds: 6),
          ),
        );
      } else {
        latLng = LatLng(latitude, longitude);
        setState(() {
          show_spinkit = false;
          show_done_location = true;
        });
      }
    } catch (e) {
      print("Failed to get location: $e");
    }
  }

  // Show the map
  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  addAttendanceEnterTraining() async {
    DateTime dateOnly = DateTime(date.year, date.month, date.day); // بدون الوقت

    SharedPreferences.getInstance().then((value) async {
      studentId = value.getString("studentId").toString();
      print("studentId: $studentId in EnterFactory");

      if (studentId != "") {
        DocumentReference docRef =
            await _firestor.collection("Attendances").add({
          "Student_ID": studentId,
          "Date": Timestamp.fromDate(dateOnly),
          "TrainingPlaceName": trainingPlaceName,
          "SupervisorName": supervisorName,
          "EnteringTime": DateTime.now(),
          "EnteringLocation": GeoPoint(latitude, longitude),
          "ExitingTime": "Not yet",
          "ExitingLocation": "Not yet",
          "BenefitRating": 0,
          "SupervisorRating": 0,
          "EnvironmentRating": 0,
        });

        // استخراج الـ ID الخاص بالمستند
        attendanceId = docRef.id;
        print("تمت إضافة حضور الطالب بنجاح، ID الخاص به هو: $attendanceId");
      } else {
        print(
            "************************************** error in the student id **************************************");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("error".tr),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          backgroundColor: Color(0xFF0187c4),
          title: Center(
              child: Text(
            'enter_factory'.tr,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
          )),
        ),
        backgroundColor: Color(0xFF0187c4),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //training place name
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        trainingPlaceName = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'training_place_name'.tr, // Translated "Email"
                      labelStyle: TextStyle(color: Colors.white, fontSize: 17),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  SizedBox(height: 16),
                  //supervisor name
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        supervisorName = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'supervisor_name'.tr,
                      labelStyle: TextStyle(color: Colors.white, fontSize: 17),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  SizedBox(height: 50),
                  //get location btn
                  ElevatedButton(
                    onPressed: () {
                      getCurrentLocation();
                      setState(() {
                        show_spinkit = true;
                        show_done_location = false;
                      });
                    },
                    child: Text(
                      "get_location".tr,
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF0187c4),
                          fontWeight: FontWeight.bold),
                    ),
                    // style: ElevatedButton.styleFrom(
                    //   primary: Colors.white,
                    //   onPrimary: Colors.black,
                    // ),
                  ),
                  //spinkit
                  Visibility(
                      visible: show_spinkit || show_done_location,
                      child: SizedBox(height: 30)),
                  Visibility(
                    visible: show_spinkit,
                    child: SpinKitWave(
                      color: Colors.white,
                      size: 35.0,
                    ),
                  ),
                  //done message
                  Visibility(
                      visible: show_done_location,
                      child: Text(
                        "done_getting_location".tr,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )),
                  Visibility(
                      visible: show_done_location, child: SizedBox(height: 30)),
                  // the map
                  Visibility(
                    visible: show_done_location,
                    child: Container(
                      height: 200, // التحكم في ارتفاع الخريطة
                      width: double.infinity, // جعلها بعرض الصفحة
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: latLng,
                          zoom: 18.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  // submit btn
                  Visibility(
                    visible: !spinkitVisable_submit && show_done_location,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (trainingPlaceName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("enter_training_place_name"
                                .tr
                                .tr), // Key for "Enter trainingPlaceName"
                          ));
                        } else {
                          try {
                            setState(() {
                              spinkitVisable_submit = true;
                            });

                            await addAttendanceEnterTraining();

                            Future.delayed(Duration(seconds: 2), () async {
                              /// *****************************************************************
                              while (true) {
                                if (attendanceId.isNotEmpty) {
                                  final SharedPreferences _prefs =
                                      await SharedPreferences.getInstance();
                                  await _prefs.setString(
                                      "attendanceId", attendanceId);
                                  print(
                                      "****************** done adding attendanceId in shared pref ******************************************************");

                                  // await Get.offAll(() => ExitFactory(attendanceId: attendanceId));
                                  await Get.offAll(() => ExitFactory());
                                  break;
                                }
                              }

                              /// *****************************************************************
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("An error occurred: $e"),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        'submit'.tr,
                        style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF0187c4),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  //spinkitVisable_submit
                  Visibility(
                    visible: spinkitVisable_submit,
                    child: SpinKitCircle(
                      color: Colors.white,
                      size: 35.0,
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
