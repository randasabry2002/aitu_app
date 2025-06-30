import 'dart:async';
import 'package:aitu_app/screens/Distribution_Pages/FactoryData.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aitu_app/screens/Profile.dart';
import 'package:aitu_app/screens/Attendance_Part_Pages/EnterFactory.dart';
import 'package:aitu_app/screens/Attendance_Part_Pages/ExitFactory.dart';
import 'package:aitu_app/screens/Attendance_Part_Pages/InfoPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// LocationConfirmationPage - صفحة مخصصة لتحديد موقع المصنع في اليوم الأول
class LocationConfirmationPage extends StatefulWidget {
  final String factName;
  final VoidCallback onLocationConfirmed;

  const LocationConfirmationPage({
    Key? key,
    required this.factName,
    required this.onLocationConfirmed,
  }) : super(key: key);

  @override
  _LocationConfirmationPageState createState() =>
      _LocationConfirmationPageState();
}

class _LocationConfirmationPageState extends State<LocationConfirmationPage> {
  bool isLocationLoading = false;
  bool isLocationConfirmed = false;
  double? currentLatitude;
  double? currentLongitude;
  LatLng currentLatLng = LatLng(30.0444, 31.2357); // الموقع الافتراضي (القاهرة)
  final Completer<GoogleMapController> _mapController = Completer();

  /// جلب الموقع الحالي
  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('يرجى تفعيل خدمة الموقع');
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('يرجى السماح بالوصول إلى الموقع');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showError('يرجى السماح بالوصول إلى الموقع من إعدادات التطبيق');
      return;
    }
    setState(() => isLocationLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
        currentLatLng = LatLng(position.latitude, position.longitude);
        isLocationConfirmed = true;
        isLocationLoading = false;
      });
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLng(currentLatLng));
      _showSuccess('تم تحديد الموقع بنجاح');
    } catch (e) {
      _showError('حدث خطأ أثناء تحديد الموقع: $e');
      setState(() => isLocationLoading = false);
    }
  }

  /// عند الضغط على زر تأكيد وحفظ الموقع
  Future<void> onSaveLocation() async {
    if (currentLatitude == null || currentLongitude == null) {
      _showError('يرجى تحديد الموقع أولاً');
      return;
    }
    setState(() => isLocationLoading = true);
    try {
      await _updateStudentFactoryLocation();
      _showSuccess('تم حفظ موقع المصنع بنجاح');
      widget.onLocationConfirmed();
    } catch (e) {
      _showError('حدث خطأ أثناء حفظ موقع المصنع: $e');
    } finally {
      setState(() => isLocationLoading = false);
    }
  }

  /// تحديث الطالب فقط
  Future<void> _updateStudentFactoryLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email") ?? '';
    if (email.isEmpty) {
      throw Exception('لم يتم العثور على بريد إلكتروني للطالب');
    }
    QuerySnapshot studentQuery =
    await FirebaseFirestore.instance
        .collection('StudentsTable')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (studentQuery.docs.isEmpty) {
      throw Exception('لم يتم العثور على مستند الطالب');
    }
    String studentId = studentQuery.docs.first.id;
    await FirebaseFirestore.instance
        .collection('StudentsTable')
        .doc(studentId)
        .update({
      'factory_latitude': currentLatitude,
      'factory_longitude': currentLongitude,
    });
  }

  void _showError(String msg) {
    Get.snackbar(
      'تنبيه',
      msg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
    );
  }

  void _showSuccess(String msg) {
    Get.snackbar(
      'نجاح',
      msg,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(
          'تأكيد موقع المصنع',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                child: Icon(Icons.location_on, color: mainColor, size: 64),
              ),
              SizedBox(height: 16),
              Text(
                'يرجى تحديد موقع المصنع بدقة، سيتم اعتماده كموقع رسمي لتسجيل الحضور والغياب يوميًا. تأكد أن يكون هذا الموقع ثابتًا وهو ذاته يوميًا.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32),
              AnimatedOpacity(
                opacity: isLocationLoading ? 0.7 : 1.0,
                duration: Duration(milliseconds: 200),
                child: ElevatedButton.icon(
                  onPressed: isLocationLoading ? null : getCurrentLocation,
                  icon:
                  isLocationLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                      : Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 22,
                  ),
                  label: Text(
                    isLocationLoading
                        ? 'جاري تحديد الموقع...'
                        : 'تحديد موقعي الحالي',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              if (isLocationConfirmed) ...[
                SizedBox(height: 28),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: mainColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: currentLatLng,
                        zoom: 16.0,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('factory_location'),
                          position: currentLatLng,
                          infoWindow: InfoWindow(title: 'موقع المصنع'),
                        ),
                      },
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLocationLoading ? null : onSaveLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      isLocationLoading ? 'جاري الحفظ...' : 'تأكيد وحفظ الموقع',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
              if (!isLocationConfirmed) SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}