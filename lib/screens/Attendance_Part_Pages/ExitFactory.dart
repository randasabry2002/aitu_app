import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';

class ExitFactory extends StatefulWidget {
  const ExitFactory({super.key});

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
  var _firestor = FirebaseFirestore.instance;
  bool spinkitVisable_exit = false;
  late String attendanceId;
  late final SharedPreferences _prefs;
  String notes = "";
  String tempNotes = ""; // Temporary notes storage
  Duration trainingDuration = Duration.zero;
  Timer? _timer;
  DateTime? startTime;
  String studentId = "";
  String studentEmail = "";
  GeoPoint? enteringLocation;
  String currentQuote = "";

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

  double benefitRating = 0;
  double supervisorRating = 0;
  double environmentRating = 0;

  @override
  void initState() {
    super.initState();
    getSharedPref();
    _getStudentInfo();
    _setRandomQuote();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    startTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (startTime != null) {
        setState(() {
          trainingDuration = DateTime.now().difference(startTime!);
        });
      }
    });
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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString("email") ?? '';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Student information not found"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print("Error getting student info: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error retrieving student information"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> updateStudent() async {
    try {
      if (studentId.isEmpty) {
        throw Exception("Student ID not found");
      }

      await _firestor.collection("Attendances").doc(attendanceId).update({
        "Student_ID": studentId,
        "Student_Email": studentEmail,
        "ExitingTime": DateTime.now(),
        "ExitingLocation": GeoPoint(latitude, longitude),
        "BenefitRating": benefitRating,
        "SupervisorRating": supervisorRating,
        "EnvironmentRating": environmentRating,
        "Notes": notes,
        "TrainingDuration": trainingDuration.inSeconds,
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

  Future<void> _getEnteringLocation() async {
    try {
      DocumentSnapshot attendanceDoc =
          await _firestor.collection("Attendances").doc(attendanceId).get();

      if (attendanceDoc.exists) {
        setState(() {
          enteringLocation = attendanceDoc.get('EnteringLocation') as GeoPoint;
        });
      }
    } catch (e) {
      print("Error getting entering location: $e");
    }
  }

  bool _isNearFactory(GeoPoint currentLocation) {
    if (enteringLocation == null) return false;

    // Calculate distance between current location and entering location
    double distance = Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      enteringLocation!.latitude,
      enteringLocation!.longitude,
    );

    // Consider locations within 100 meters as "near"
    return distance <= 100;
  }

  Future<void> _showLocationErrorDialog() {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'تحذير',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'يجب أن تكون في موقع المصنع لتسجيل الخروج. يرجى العودة إلى موقع المصنع والمحاولة مرة أخرى.',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'حسناً',
                  style: TextStyle(fontFamily: 'Tajawal', color: mainColor),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    latitude = position.latitude;
    longitude = position.longitude;
    try {
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

        // Get entering location if not already retrieved
        if (enteringLocation == null) {
          await _getEnteringLocation();
        }

        // Check if current location is near factory
        bool isNear = _isNearFactory(GeoPoint(latitude, longitude));

        setState(() {
          show_spinkit = false;
          show_done_location = true;
          isLocationVerified = isNear;
        });

        if (isNear) {
          _startTimer(); // Start timer only when location is verified
        } else {
          await _showLocationErrorDialog();
        }
      }
    } catch (e) {
      print("Failed to get location: $e");
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

  Future<void> _showResetLocationDialog() {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'تحديد الموقع مرة أخرى',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'هل أنت متأكد من إعادة تحديد الموقع؟ سيتم إعادة تشغيل المؤقت.',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: TextStyle(fontFamily: 'Tajawal', color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetLocation();
                },
                child: Text(
                  'تأكيد',
                  style: TextStyle(fontFamily: 'Tajawal', color: mainColor),
                ),
              ),
            ],
          ),
    );
  }

  void _resetLocation() {
    setState(() {
      show_spinkit = true;
      show_done_location = false;
      isLocationVerified = false;
      _timer?.cancel();
      trainingDuration = Duration.zero;
      startTime = null;
    });
    getCurrentLocation();
  }

  void _saveTempNotes() {
    setState(() {
      tempNotes = notes;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم حفظ الملاحظات مؤقتاً',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showBackConfirmationDialog() async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'تأكيد',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'هل أنت متأكد من الغاء حضورك اليوم؟',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'لا',
                  style: TextStyle(fontFamily: 'Tajawal', color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _firestor
                        .collection("Attendances")
                        .doc(attendanceId)
                        .delete();
                    await _prefs.setString("attendanceId", 'null');
                    Navigator.pop(context);
                    Get.offAll(() => HomeScreen());
                  } catch (e) {
                    print("Error deleting attendance: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("حدث خطأ أثناء حذف الحضور"),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: Text(
                  'نعم',
                  style: TextStyle(fontFamily: 'Tajawal', color: mainColor),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: WillPopScope(
        onWillPop: () async {
          await _showBackConfirmationDialog();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
              onPressed: () => _showBackConfirmationDialog(),
            ),
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            title: Text(
              'exit_factory'.tr,
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),

                  // Get Location Button (Always visible)
                  SizedBox(
                    width: double.infinity,
                    child: CreateButton(
                      onPressed: () {
                        if (show_done_location) {
                          _showResetLocationDialog();
                        } else {
                          getCurrentLocation();
                          setState(() {
                            show_spinkit = true;
                            show_done_location = false;
                            isLocationVerified = false;
                          });
                        }
                      },
                      title: Center(
                        child: Text(
                          "تحديد الموقع",
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
                    Center(child: SpinKitWave(color: mainColor, size: 35.0)),

                  if (show_done_location && isLocationVerified) ...[
                    SizedBox(height: 30),

                    // Motivational Quote
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

                    // Duration Card
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
                                    borderRadius: BorderRadius.circular(12),
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

                    // Location Card
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
                                    borderRadius: BorderRadius.circular(12),
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

                    SizedBox(height: 20),

                    // Ratings Card
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
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.star,
                                    color: mainColor,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'التقييمات',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14.0,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            _buildRatingRow(
                              "تقييم مدى الاستفادة",
                              benefitRating,
                              (rating) {
                                setState(() {
                                  benefitRating = rating;
                                });
                              },
                            ),
                            SizedBox(height: 12),
                            _buildRatingRow(
                              "تقييم تعامل المشرف",
                              supervisorRating,
                              (rating) {
                                setState(() {
                                  supervisorRating = rating;
                                });
                              },
                            ),
                            SizedBox(height: 12),
                            _buildRatingRow(
                              "تقييم بيئة العمل",
                              environmentRating,
                              (rating) {
                                setState(() {
                                  environmentRating = rating;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Notes Card with Save Button
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: mainColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.note_alt_outlined,
                                        color: mainColor,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      'ملاحظات اليوم',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14.0,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: _saveTempNotes,
                                  icon: Icon(
                                    Icons.save_outlined,
                                    color: mainColor,
                                  ),
                                  tooltip: 'حفظ الملاحظات مؤقتاً',
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            TextField(
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText:
                                    'اكتب ملاحظاتك عن اليوم التدريبي هنا...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontFamily: 'Tajawal',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: mainColor.withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: mainColor),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  notes = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Exit Button
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
                          title: Center(
                            child: Text(
                              'إنهاء اليوم'.tr,
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
                        child: SpinKitCircle(color: mainColor, size: 35.0),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingRow(
    String label,
    double rating,
    Function(double) onRatingUpdate,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black87,
            fontFamily: 'Tajawal',
          ),
        ),
        RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          itemCount: 5,
          itemSize: 30.0,
          itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: onRatingUpdate,
        ),
      ],
    );
  }
}
