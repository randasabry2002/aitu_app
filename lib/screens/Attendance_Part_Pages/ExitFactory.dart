import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'HomeScreen.dart';

class ExitFactory extends StatefulWidget {
  // final String attendanceId;
  // const ExitFactory({super.key, required this.attendanceId});
  const ExitFactory({super.key});

  @override
  State<ExitFactory> createState() => _ExitFactoryState();
}

class _ExitFactoryState extends State<ExitFactory> {
  late var latitude;
  late var longitude;
  bool show_spinkit = false;
  bool show_done_location = false;
  LatLng latLng = LatLng(45.521563, -122.677433);
  var _firestor = FirebaseFirestore.instance;
  bool spinkitVisable_exit = false;
  late String attendanceId;
  late final SharedPreferences _prefs;
  ///****************************
  double benefitRating = 0;
  double supervisorRating = 0;
  double environmentRating = 0;

  Future<void> updateStudent() async {
    try {
      await _firestor.collection("Attendances").doc(attendanceId).update({
        "ExitingTime": DateTime.now(),
        "ExitingLocation": GeoPoint(latitude, longitude),
        "BenefitRating": benefitRating,
        "SupervisorRating": supervisorRating,
        "EnvironmentRating": environmentRating,
      });
      print("done updated********************************");
    } catch (e) {
      print("حدث خطأ أثناء التحديث: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error happened, try again"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  getSharedPref() async {
    _prefs = await SharedPreferences.getInstance();
    attendanceId = (await _prefs.getString("attendanceId"))!;
    print("Received attendance ID: ${attendanceId}");
  }

  @override
  initState() {
    super.initState();
    getSharedPref();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // تحقق من تفعيل خدمات الموقع
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
          const SnackBar(
            content: Text("لابد من الاتصال بالإنترنت للحصول على الموقع."),
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

  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Color(0xFF0187c4),
            title: Center(
                child: Text(
              'exit_factory'.tr,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
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
                    const Text(
                      "You are curruntly in the training",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 30),
                    //feedback
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("تقييم مدى الاستفادة",style: TextStyle(fontSize: 20,color: Colors.white70,fontWeight: FontWeight.bold),),
                        SizedBox(width: 20,),
                        RatingBar.builder(
                          initialRating: benefitRating,
                          minRating: 1,
                          itemCount: 5,
                          itemSize: 30.0,
                          itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) {
                            setState(() {
                              benefitRating = rating;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("تقييم تعامل المشرف",style: TextStyle(fontSize: 20,color: Colors.white70,fontWeight: FontWeight.bold),),
                        SizedBox(width: 20,),
                        RatingBar.builder(
                          initialRating: supervisorRating,
                          minRating: 1,
                          itemCount: 5,
                          itemSize: 30.0,
                          itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) {
                            setState(() {
                              supervisorRating = rating;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("تقييم بيئة العمل",style: TextStyle(fontSize: 20,color: Colors.white70,fontWeight: FontWeight.bold),),
                        SizedBox(width: 50,),
                        RatingBar.builder(
                          initialRating: environmentRating,
                          minRating: 1,
                          itemCount: 5,
                          itemSize: 30.0,
                          itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) {
                            setState(() {
                              environmentRating = rating;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                
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
                        "Get Location",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF0187c4),
                            fontWeight: FontWeight.bold),
                      ),

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
                          "Done Getting Location",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                    //location map
                    Visibility(
                        visible: show_done_location, child: SizedBox(height: 30)),
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
                    // Exit btn
                    Visibility(
                      visible: !spinkitVisable_exit && show_done_location,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            setState(() {
                              spinkitVisable_exit = true;
                            });
                            await updateStudent();
                
                            Future.delayed(Duration(seconds: 2), () async {
                              await _prefs.setString("attendanceId", 'null');
                              Get.offAll(() => HomeScreen());
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("An error occurred: $e"),
                              ),
                            );
                          }
                        },
                        child: Text(
                          "Exit",
                          style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF0187c4),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    //spinkitVisable_exit
                    Visibility(
                      visible: spinkitVisable_exit,
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
      ),
    );
  }
}
