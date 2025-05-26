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
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';

class EnterFactory extends StatefulWidget {
  const EnterFactory({super.key});

  @override
  State<EnterFactory> createState() => _EnterFactoryState();
}

class _EnterFactoryState extends State<EnterFactory> {
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
  int attendsDays = 0;
  Map<String, dynamic>? factoryData;

  @override
  void initState() {
    super.initState();
    _loadFactoryData();
    _checkExistingAttendance();
  }

  Future<void> _loadFactoryData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString("email") ?? '';

      QuerySnapshot studentSnapshot =
          await _firestor
              .collection('StudentsTable')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (studentSnapshot.docs.isNotEmpty) {
        String factoryId = studentSnapshot.docs.first['factory'] ?? '';

        DocumentSnapshot factorySnapshot =
            await _firestor.collection('Factories').doc(factoryId).get();

        if (factorySnapshot.exists) {
          setState(() {
            factoryData = factorySnapshot.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      print('Error loading factory data: $e');
    }
  }

  bool _hasExistingAttendance = false;

  Future<bool> _showLocationChangeWarning() async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('تحذير'),
                content: Text('هل أنت متأكد من تغيير الموقع؟'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('متابعة'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _checkExistingAttendance() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String studentId = prefs.getString("studentId") ?? '';
      String factoryId = prefs.getString("factoryId") ?? '';

      QuerySnapshot query =
          await _firestor
              .collection("Attendances")
              .where("Student_ID", isEqualTo: studentId)
              .where("factory", isEqualTo: factoryId)
              .where("EnteringLocation", isNull: true)
              .limit(1)
              .get();

      setState(() {
        _hasExistingAttendance = query.docs.isNotEmpty;
      });
    } catch (e) {
      print('Error checking existing attendance: $e');
    }
  }

  Future<void> getCurrentLocation() async {
    if (_hasExistingAttendance) {
      final shouldUpdate = await _showLocationChangeWarning();
      if (!shouldUpdate) return;
    }

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
      desiredAccuracy: LocationAccuracy.high,
    );
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
    try {
      DateTime dateOnly = DateTime(date.year, date.month, date.day);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString("email") ?? '';

      // Get student ID from StudentsTable using email
      QuerySnapshot studentSnapshot =
          await _firestor
              .collection('StudentsTable')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (studentSnapshot.docs.isEmpty) {
        throw Exception("Student not found");
      }

      String studentId = studentSnapshot.docs.first.id;
      print("Found student ID: $studentId");

      // Add attendance record
      DocumentReference docRef = await _firestor.collection("Attendances").add({
        "Student_ID": studentId,
        "Student_Email": email,
        "Date": Timestamp.fromDate(dateOnly),
        "EnteringTime": DateTime.now(),
        "EnteringLocation": GeoPoint(latitude, longitude),
        "ExitingTime": "Not yet",
        "ExitingLocation": "Not yet",
        "BenefitRating": 0,
        "SupervisorRating": 0,
        "EnvironmentRating": 0,
        "attendsDays": ++attendsDays,
        "factory": factoryData?['id'] ?? '',
      });

      // Get the attendance ID
      attendanceId = docRef.id;
      print("تمت إضافة حضور الطالب بنجاح، ID الخاص به هو: $attendanceId");

      // Store attendance ID in SharedPreferences
      await prefs.setString("attendanceId", attendanceId);
    } catch (e) {
      print("Error adding attendance: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("حدث خطأ أثناء تسجيل الحضور: $e"),
          duration: Duration(seconds: 3),
        ),
      );
      throw e;
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
          automaticallyImplyLeading: false,
          centerTitle: true,
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
          title: Text(
            'enter_factory'.tr,
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
                SizedBox(height: 40),

                // Factory Data Card
                if (factoryData != null)
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
                                  Icons.factory,
                                  color: mainColor,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'بيانات المصنع',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14.0,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      factoryData?['name'] ?? '',
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
                          _buildInfoRow(
                            'العنوان',
                            factoryData?['address'] ?? '',
                          ),
                          SizedBox(height: 8),
                          _buildInfoRow(
                            'رقم الهاتف',
                            factoryData?['phone'] ?? '',
                          ),
                          SizedBox(height: 8),
                          _buildInfoRow(
                            'اسم جهة الاتصال',
                            factoryData?['contactName'] ?? '',
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 24),
                Text(
                  'قم بتحديد الموقع للمصنع (عند بوابة الدخول على سبيل المثال) لتسجيل الحضور منه يوميا',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 14.0,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'موقعك الحالي للمصنع',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14.0,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    show_done_location
                                        ? 'تم تحديد الموقع'
                                        : 'لم يتم تحديد الموقع بعد',
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
                        if (show_done_location) ...[
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
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Get Location Button
                CreateButton(
                  onPressed: () {
                    getCurrentLocation();
                    setState(() {
                      show_spinkit = true;
                      show_done_location = false;
                    });
                  },
                  title: Text(
                    "تحديد الموقع",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: const Color.fromARGB(
                          255,
                          0,
                          0,
                          0,
                        ).withOpacity(0.3),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'بداية اليوم الصناعي',
                        style: TextStyle(
                          color: mainColor,
                          fontSize: 16.0,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: const Color.fromARGB(
                          255,
                          0,
                          0,
                          0,
                        ).withOpacity(0.3),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Loading Indicator
                if (show_spinkit)
                  Center(child: SpinKitWave(color: mainColor, size: 35.0)),

                SizedBox(height: 24),

                // Submit Button
                if (!spinkitVisable_submit && show_done_location)
                  SizedBox(
                    height: 60.0,
                    width: double.infinity,
                    child: CreateButton(
                      onPressed: () async {
                        try {
                          setState(() {
                            spinkitVisable_submit = true;
                          });

                          await addAttendanceEnterTraining();

                          // Navigate to ExitFactory after successful attendance registration
                          Get.offAll(() => ExitFactory());
                        } catch (e) {
                          setState(() {
                            spinkitVisable_submit = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("حدث خطأ أثناء تسجيل الحضور: $e"),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      title: Center(
                        child: Text(
                          'بدء اليوم'.tr,
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

                // Submit Loading Indicator
                if (spinkitVisable_submit)
                  Center(child: SpinKitCircle(color: mainColor, size: 35.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14.0,
            fontFamily: 'Tajawal',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }
}
