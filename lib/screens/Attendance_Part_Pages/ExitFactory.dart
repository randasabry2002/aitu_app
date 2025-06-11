import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';

class ExitFactory extends StatefulWidget {
  final String attendanceId;

  const ExitFactory({super.key, required this.attendanceId});

  @override
  State<ExitFactory> createState() => _ExitFactoryState();
}

class _ExitFactoryState extends State<ExitFactory> {
  late var latitude;
  late var longitude;
  bool show_spinkit = false;
  bool show_done_location = false;
  bool isLocationVerified = false;
  LatLng latLng = LatLng(45.521563, -122.677433);
  final _firestor = FirebaseFirestore.instance;
  bool spinkitVisable_exit = false;
  late String attendanceId;
  late SharedPreferences _prefs;
  Duration trainingDuration = Duration.zero;
  String studentId = "";
  String studentEmail = "";
  String currentQuote = "";
  bool _isLoading = true;

  final List<String> motivationalQuotes = [
    "كل يوم جديد هو فرصة للتعلم والنمو",
    "النجاح هو رحلة وليس وجهة",
    "التدريب العملي هو أفضل طريقة للتعلم",
    "الخبرة هي أفضل معلم",
    "كل خطوة تقودك إلى النجاح",
    "التعلم المستمر هو مفتاح التطور",
    "الفرص تأتي لمن يبحث عنها",
    "النجاح يبدأ بالخطوة الأولى",
    "التحديات تصنع الخبرة",
    "كل يوم هو فرصة جديدة للتميز",
  ];

  @override
  void initState() {
    super.initState();
    attendanceId = widget.attendanceId;
    _initializeData();
    _setRandomQuote();
  }

  Future<void> _initializeData() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _getStudentInfo();
      await _loadExistingAttendanceData();
    } catch (e) {
      print("Error initializing data: $e");
      Get.snackbar(
        'خطأ في تحميل البيانات',
        'حدث خطأ أثناء تحميل بيانات الحضور.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 5),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadExistingAttendanceData() async {
    try {
      DocumentSnapshot attendanceDoc =
          await _firestor.collection("Attendances").doc(attendanceId).get();
      if (attendanceDoc.exists) {
        Timestamp? enteringTime = attendanceDoc.get('EnteringTime');
        if (enteringTime != null) {
          setState(() {
            trainingDuration = DateTime.now().difference(enteringTime.toDate());
          });
        }
      } else {
        print("Attendance document not found for loading existing data.");
      }
    } catch (e) {
      print("Error loading existing attendance data: $e");
      Get.snackbar(
        'خطأ في تحميل بيانات الحضور',
        'تعذر تحميل بيانات الحضور الموجودة.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 5),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Future<void> _getStudentInfo() async {
    try {
      String email = _prefs.getString("email") ?? '';
      setState(() {
        studentEmail = email;
      });

      QuerySnapshot studentSnapshot =
          await _firestor
              .collection('StudentsTable')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (studentSnapshot.docs.isNotEmpty) {
        setState(() {
          studentId = studentSnapshot.docs.first.id;
        });
        print("Student ID retrieved: $studentId");
      } else {
        print("No student found with email: $email");
        Get.snackbar(
          'خطأ في بيانات الطالب',
          'تعذر العثور على بيانات الطالب.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 5),
        );
      }
    } catch (e) {
      print("Error getting student info: $e");
      Get.snackbar(
        'خطأ في بيانات الطالب',
        'حدث خطأ أثناء جلب بيانات الطالب.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 5),
      );
    }
  }

  Future<void> updateStudent() async {
    try {
      if (!isLocationVerified) {
        Get.snackbar(
          'تنبيه',
          'يرجى تحديد موقعك أولاً قبل إنهاء اليوم',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
        );
        return;
      }

      await _firestor.collection("Attendances").doc(attendanceId).update({
        "ExitingTime": DateTime.now(),
        "ExitingLocation": GeoPoint(latitude, longitude),
        "TrainingDuration": trainingDuration.inSeconds,
        "Status": "Completed",
      });

      await _prefs.setString("attendanceId", 'null');

      Get.snackbar(
        'نجاح',
        'تم إنهاء اليوم التدريبي بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Get.offAll(() => HomeScreen());
      });
    } catch (e) {
      print("Error updating attendance: $e");
      Get.snackbar(
        'تنبيه',
        'حدث خطأ أثناء إنهاء اليوم',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
      setState(() {
        spinkitVisable_exit = false;
      });
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'تنبيه',
        'يرجى تفعيل خدمة الموقع',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'تنبيه',
          'يرجى السماح بالوصول إلى الموقع',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'تنبيه',
        'يرجى السماح بالوصول إلى الموقع من إعدادات التطبيق',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
      return;
    }

    setState(() {
      show_spinkit = true;
      show_done_location = false;
      isLocationVerified = false;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        latLng = LatLng(latitude, longitude);
        show_spinkit = false;
        show_done_location = true;
        isLocationVerified = true;
      });

      Get.snackbar(
        'نجاح',
        'تم تحديد الموقع بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print("Failed to get location: $e");
      Get.snackbar(
        'تنبيه',
        'حدث خطأ أثناء تحديد الموقع',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
      setState(() {
        show_spinkit = false;
        isLocationVerified = false;
      });
    }
  }

  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _setRandomQuote() {
    final random = Random();
    setState(() {
      currentQuote =
          motivationalQuotes[random.nextInt(motivationalQuotes.length)];
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
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: Text(
            'تسجيل الخروج',
            style: TextStyle(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body:
            _isLoading
                ? Center(child: SpinKitCircle(color: mainColor, size: 50.0))
                : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: CreateButton(
                            onPressed: () {
                              setState(() {
                                show_spinkit = true;
                                show_done_location = false;
                                isLocationVerified = false;
                              });
                              getCurrentLocation();
                            },
                            title: Center(
                              child: Text(
                                show_done_location
                                    ? "تحديد الموقع مرة أخرى"
                                    : "تحديد الموقع",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (show_spinkit)
                          Center(
                            child: SpinKitWave(color: mainColor, size: 35.0),
                          ),

                        if (show_done_location && isLocationVerified) ...[
                          SizedBox(height: 30),

                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: mainColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.lightbulb_outline,
                                    color: mainColor,
                                    size: 32,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: mainColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    currentQuote,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18.0,
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 30),

                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: mainColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.timer,
                                          color: mainColor,
                                          size: 24,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'مدة التدريب',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14.0,
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              _formatDuration(trainingDuration),
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: mainColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.location_on,
                                          color: mainColor,
                                          size: 24,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'موقعك الحالي',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14.0,
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'تم تحديد الموقع',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: mainColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: GoogleMap(
                                        onMapCreated: _onMapCreated,
                                        initialCameraPosition: CameraPosition(
                                          target: latLng,
                                          zoom: 18.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 30),

                          if (!spinkitVisable_exit)
                            SizedBox(
                              height: 60.0,
                              width: double.infinity,
                              child: CreateButton(
                                onPressed: () async {
                                  try {
                                    setState(() {
                                      spinkitVisable_exit = true;
                                    });
                                    await updateStudent();
                                  } catch (e) {
                                    Get.snackbar(
                                      'تنبيه',
                                      'حدث خطأ أثناء إنهاء اليوم',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.TOP,
                                      duration: Duration(seconds: 3),
                                    );
                                    setState(() {
                                      spinkitVisable_exit = false;
                                    });
                                  }
                                },
                                title: Center(
                                  child: Text(
                                    'إنهاء اليوم',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22.0,
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          if (spinkitVisable_exit)
                            Center(
                              child: SpinKitCircle(
                                color: mainColor,
                                size: 35.0,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
