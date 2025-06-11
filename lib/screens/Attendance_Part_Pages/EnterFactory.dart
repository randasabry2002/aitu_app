import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'duringTraining.dart';

class EnterFactory extends StatefulWidget {
  const EnterFactory({super.key});

  @override
  State<EnterFactory> createState() => _EnterFactoryState();
}

class _EnterFactoryState extends State<EnterFactory> {
  // المتغيرات العامة
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Completer<GoogleMapController> _controller = Completer();

  String studentId = "";
  String attendanceId = "";
  int attendsDays = 0;
  DateTime date = DateTime.now();

  late double latitude;
  late double longitude;

  late double factoryLatitude;
  late double factoryLongitude;

  bool showSpinkit = false;
  bool showDoneLocation = false;
  bool spinkitVisibleSubmit = false;
  bool _hasExistingAttendance = false;

  LatLng latLng = LatLng(45.521563, -122.677433);
  Map<String, dynamic>? factoryData;

  @override
  void initState() {
    super.initState();
    _checkExistingAttendance();
  }

  // التحقق من وجود حضور مفتوح للطالب
  Future<void> _checkExistingAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String studentId = prefs.getString("studentId") ?? '';
      String factoryId = prefs.getString("factoryId") ?? '';

      final query =
          await _firestore
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

  // رسالة تأكيد تغيير الموقع
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

  // الحصول على الموقع الحالي
  Future<void> getCurrentLocation() async {
    if (_hasExistingAttendance) {
      final shouldUpdate = await _showLocationChangeWarning();
      if (!shouldUpdate) return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar('يرجى تفعيل خدمة الموقع');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar('يرجى السماح بالوصول إلى الموقع');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackbar('يرجى السماح بالوصول إلى الموقع من إعدادات التطبيق');
      return;
    }

    setState(() {
      showSpinkit = true;
      showDoneLocation = false;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        latLng = LatLng(latitude, longitude);
        showSpinkit = false;
        showDoneLocation = true;
      });
    } catch (e) {
      print("Failed to get location: $e");
      _showSnackbar('حدث خطأ أثناء تحديد الموقع');
      setState(() {
        showSpinkit = false;
        showDoneLocation = false;
      });
    }
  }

  // بدء تسجيل الحضور
  Future<void> addAttendanceEnterTraining() async {
    try {
      if (!showDoneLocation) {
        _showSnackbar('يرجى تحديد موقعك أولاً');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      String email = prefs.getString("email") ?? '';

      final studentSnapshot =
          await _firestore
              .collection('StudentsTable')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (studentSnapshot.docs.isEmpty) {
        _showSnackbar('لم يتم العثور على بيانات الطالب');
        return;
      }

      String factoryId = studentSnapshot.docs.first['factory'] ?? '';
      final factoryDoc =
          await _firestore
              .collection('Factories')
              .where('name', isEqualTo: factoryId)
              .limit(1)
              .get();

      if (factoryDoc.docs.isEmpty) {
        _showSnackbar('لم يتم العثور على بيانات المصنع');
        return;
      }
      factoryLongitude = factoryDoc.docs.first['longitude'];
      factoryLatitude = factoryDoc.docs.first['latitude'];
      // حساب المسافة بين موقع الطالب والمصنع
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        factoryLatitude,
        factoryLongitude,
      );

      // التحقق من المسافة
      if (distance > 150) {
        _showSnackbar(
          'يجب أن تكون داخل المصنع أو على مسافة لا تزيد عن 150 متر لتسجيل الحضور',
        );
        return;
      }

      // إذا كانت المسافة أقل من 150 متر، قم بتسجيل الحضور
      DateTime dateOnly = DateTime(date.year, date.month, date.day);
      String studentId = studentSnapshot.docs.first.id;

      final docRef = await _firestore.collection("Attendances").add({
        "Student_ID": studentId,
        "Student_Email": email,
        "Date": Timestamp.fromDate(dateOnly),
        "EnteringTime": DateTime.now(),
        "EnteringLocation": GeoPoint(latitude, longitude),
        "FactoryLocation": GeoPoint(factoryLatitude, factoryLongitude),
        "ExitingTime": null,
        "ExitingLocation": null,
        "BenefitRating": 0,
        "SupervisorRating": 0,
        "EnvironmentRating": 0,
        "Notes": "",
        "TrainingDuration": 0,
        "Status": "In Progress",
        "Factory_ID": factoryId,
      });

      await prefs.setString("attendanceId", docRef.id);

      Get.snackbar(
        'نجاح',
        'تم بدء اليوم التدريبي',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );

      Get.offAll(() => DuringTraining());
    } catch (e) {
      print("Error adding attendance: $e");
      _showSnackbar('حدث خطأ أثناء تسجيل الحضور');
    }
  }

  // عرض رسالة تنبيه للمستخدم
  void _showSnackbar(String message) {
    Get.snackbar(
      'تنبيه',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
    );
  }

  // عند إنشاء الخريطة
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
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
                                    showDoneLocation
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
                        if (showDoneLocation) ...[
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
                      showSpinkit = true;
                      showDoneLocation = false;
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
                if (showSpinkit)
                  Center(child: SpinKitWave(color: mainColor, size: 35.0)),

                SizedBox(height: 24),

                // Submit Button
                if (!spinkitVisibleSubmit && showDoneLocation)
                  SizedBox(
                    height: 60.0,
                    width: double.infinity,
                    child: CreateButton(
                      onPressed: () async {
                        try {
                          setState(() {
                            spinkitVisibleSubmit = true;
                          });

                          await addAttendanceEnterTraining();
                        } catch (e) {
                          setState(() {
                            spinkitVisibleSubmit = false;
                          });
                          _showSnackbar('حدثت مشكلة غير متوقعة');
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
                if (spinkitVisibleSubmit)
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
