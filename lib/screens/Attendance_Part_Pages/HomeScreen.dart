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

import 'LocationConfirmationPage.dart';
import 'SubmitDailyReport.dart';

/// HomeScreen - الشاشة الرئيسية للتطبيق
/// تعرض معلومات الطالب وحالة الحضور وتتيح تسجيل الدخول والخروج من المصنع
class HomeScreen extends StatefulWidget {
  final String studentEmail;
  const HomeScreen({super.key, this.studentEmail = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ==================== متغيرات التحكم في التطبيق ====================
  int _backButtonPressedCount = 0; // عداد الضغط على زر العودة
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ==================== متغيرات البيانات ====================
  QueryDocumentSnapshot? student; // بيانات الطالب
  QueryDocumentSnapshot? factory; // بيانات المصنع
  String? currentAttendanceId; // معرف الحضور الحالي
  String? factName = ''; // اسم المصنع

  // ==================== متغيرات حالة التطبيق ====================
  bool isLoading = true; // حالة التحميل
  bool hasEnteredToday = false; // هل دخل اليوم أم لا
  bool hasSubmitedReportToday = false; // هل دخل اليوم أم لا
  int attendanceDays = 0; // عدد أيام الحضور
  bool showLocationPage = false; // عرض صفحة تحديد الموقع

  // ==================== متغيرات التصحيح ====================
  List<String> debugLogs = []; // سجل التصحيح
  bool showDebugDialog = false; // عرض نافذة التصحيح

  // ==================== دوال التصحيح ====================

  /// إضافة رسالة إلى سجل التصحيح
  void addDebugLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logMessage = '[$timestamp] $message';
    debugLogs.add(logMessage);
    print(logMessage);
  }

  /// عرض نافذة التصحيح
  void showDebugInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.bug_report, color: mainColor),
                SizedBox(width: 8),
                Text(
                  'معلومات التصحيح',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  // معلومات الحالة
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حالة التطبيق:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: mainColor,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildDebugInfoRow('isLoading', isLoading.toString()),
                        _buildDebugInfoRow(
                          'attendanceDays',
                          attendanceDays.toString(),
                        ),
                        _buildDebugInfoRow(
                          'showLocationPage',
                          showLocationPage.toString(),
                        ),
                        _buildDebugInfoRow(
                          'hasEnteredToday',
                          hasEnteredToday.toString(),
                        ),
                        _buildDebugInfoRow(
                          'currentAttendanceId',
                          currentAttendanceId ?? 'null',
                        ),
                        _buildDebugInfoRow('factName', factName ?? 'null'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // معلومات الطالب
                  if (student != null) ...[
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'معلومات الطالب:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildDebugInfoRow(
                            'الاسم',
                            student!['name'] ?? 'null',
                          ),
                          _buildDebugInfoRow(
                            'الكود',
                            student!['code'] ?? 'null',
                          ),
                          _buildDebugInfoRow(
                            'البريد الإلكتروني',
                            student!['email'] ?? 'null',
                          ),
                          _buildDebugInfoRow(
                            'القسم',
                            student!['department'] ?? 'null',
                          ),
                          _buildDebugInfoRow(
                            'المرحلة',
                            student!['stage'] ?? 'null',
                          ),
                          _buildDebugInfoRow(
                            'الدفعة',
                            (student!['batch'] ?? 'null').toString(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],

                  // سجل التصحيح
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'سجل التصحيح:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    debugLogs.clear();
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'مسح السجل',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: debugLogs.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    debugLogs[debugLogs.length - 1 - index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إغلاق',
                  style: TextStyle(fontFamily: 'Tajawal', color: mainColor),
                ),
              ),
            ],
          ),
    );
  }

  /// بناء صف معلومات التصحيح
  Widget _buildDebugInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'Tajawal',
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== دوال جلب البيانات ====================

  /// جلب بيانات الطالب
  Future<QueryDocumentSnapshot?> getStudent() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString("email") ?? '';
      addDebugLog('Fetching student with email: $email');

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('StudentsTable')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        addDebugLog('Student found: ${querySnapshot.docs.first.data()}');
        return querySnapshot.docs.first;
      }
      addDebugLog('No student found for email: $email');
      return null;
    } catch (e) {
      addDebugLog('Error getting student: $e');
      return null;
    }
  }

  /// جلب بيانات المصنع
  Future<QueryDocumentSnapshot?> getFactory() async {
    try {
      QueryDocumentSnapshot? student = await getStudent();
      if (student != null) {
        String factoryId = student['factory'] ?? ''; 
        addDebugLog('Fetching factory with name: $factoryId');

        final factoryQuery =
            await FirebaseFirestore.instance
                .collection('Factories')
                .where('name', isEqualTo: factoryId)
                .limit(1)
                .get();

        if (factoryQuery.docs.isNotEmpty) {
          final factoryDoc = factoryQuery.docs.first;
          setState(() {
            factName = factoryDoc['name'];
          });
          addDebugLog('Factory found: ${factoryDoc.data()}');
          return factoryDoc;
        } else {
          setState(() {
            factName = 'مصنع غير محدد';
          });
          addDebugLog('No factory found for name: $factoryId');
        }
      } else {
        setState(() {
          factName = 'مصنع غير محدد';
        });
        addDebugLog('No student data, cannot fetch factory');
      }
      return null;
    } catch (e) {
      addDebugLog('Error getting factory: $e');
      setState(() {
        factName = 'خطأ في تحميل بيانات المصنع';
      }); 
      return null;
    }
  }

  /// جلب بيانات الحضور
  Future<void> fetchData() async {
    try {
      addDebugLog('Fetching data started');
      student = await getStudent(); 
      factory = await getFactory();
      await checkCurrentAttendance();
      await checkTodayAttendance();
      await calculateAttendanceDays();

      setState(() {
        showLocationPage = attendanceDays == 0;
        isLoading = false;
      });

      // Navigate to location confirmation page if first day
      if (showLocationPage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.to(
            () => LocationConfirmationPage(
              factName: factName ?? '',
              onLocationConfirmed: () {
                setState(() { 
                  showLocationPage = false;
                });
                Get.off(() => EnterFactory());
              },
            ),
          );
        });
      }

      addDebugLog('Data fetching completed');
    } catch (e) {
      addDebugLog('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  /// حساب أيام الحضور
  Future<int> calculateAttendanceDays() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String currentEmail = prefs.getString("email") ?? '';
      addDebugLog('Calculating attendance days for email: $currentEmail');

      if (student?['code'] == null ||
          (student?['code']?.toString() ?? '').isEmpty) {
        addDebugLog('Student code is null or empty');
        setState(() {
          attendanceDays = 0;
        });
        return 0;
      }

      QuerySnapshot attendanceSnapshot =
          await FirebaseFirestore.instance
              .collection('Attendances')
              .where('Student_ID', isEqualTo: student?['code'])
              .where('Student_Email', isEqualTo: currentEmail)
              .get();

      addDebugLog('Found ${attendanceSnapshot.docs.length} attendance records');
      int calculatedDays = attendanceSnapshot.docs.length;
      setState(() {
        attendanceDays = calculatedDays;
      });
      addDebugLog('Attendance days set to: $attendanceDays');
      return calculatedDays;
    } catch (e) {
      addDebugLog('Error calculating attendance days: $e');
      setState(() {
        attendanceDays = 0;
      });
      return 0;
    }
  }

  /// التحقق من الحضور الحالي
  Future<void> checkCurrentAttendance() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String attendanceId = prefs.getString("attendanceId") ?? 'null';
      addDebugLog('Checking current attendance ID: $attendanceId');

      if (attendanceId != 'null') {
        DocumentSnapshot attendanceDoc =
            await FirebaseFirestore.instance
                .collection('Attendances')
                .doc(attendanceId)
                .get();

        if (attendanceDoc.exists) {
          setState(() {
            currentAttendanceId = attendanceId;
          });
          addDebugLog('Current attendance found: $attendanceId');
        } else {
          await prefs.setString("attendanceId", 'null');
          addDebugLog('No current attendance found, resetting ID');
        }
      }
    } catch (e) {
      addDebugLog('Error checking attendance: $e');
    }
  }

  /// التحقق من حضور اليوم
  Future<void> checkTodayAttendance() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));
      addDebugLog(
        'Checking today attendance for student code: ${student?['code']}',
      );

      QuerySnapshot existingAttendance =
          await FirebaseFirestore.instance
              .collection('Attendances')
              .where('Student_ID', isEqualTo: student?['code'])
              .where(
                'Date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
              )
              .where('Date', isLessThan: Timestamp.fromDate(endOfDay))
              .get();

      setState(() {
        hasEnteredToday = existingAttendance.docs.isNotEmpty;
      });
      addDebugLog('Has entered today: $hasEnteredToday');
    } catch (e) {
      addDebugLog('Error checking today attendance: $e');
    }
  }

  /// التحقق من وجود حضور سابق اليوم
  Future<bool> _checkExistingAttendance() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString("email") ?? '';
      DateTime today = DateTime.now();
      DateTime dateOnly = DateTime(today.year, today.month, today.day);
      addDebugLog(
        'Checking existing attendance for email: $email on $dateOnly',
      );

      QuerySnapshot existingAttendance =
          await FirebaseFirestore.instance
              .collection('Attendances')
              .where('Student_Email', isEqualTo: email)
              .where('Date', isEqualTo: Timestamp.fromDate(dateOnly))
              .get();

      bool exists = existingAttendance.docs.isNotEmpty;
      addDebugLog('Existing attendance found: $exists');
      return exists;
    } catch (e) {
      addDebugLog('Error checking existing attendance: $e');
      return false;
    }
  }

  /// عرض تحذير الحضور
  Future<void> _showAttendanceWarning() async {
    addDebugLog('Showing attendance warning');
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'تنبيه',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'لا يصح تسجيل الدخول مرتين في اليوم',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  addDebugLog('Attendance warning dismissed');
                },
                child: Text(
                  'حسناً',
                  style: TextStyle(fontFamily: 'Tajawal', color: mainColor),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    addDebugLog(
      'Building HomeScreen: isLoading=$isLoading, attendanceDays=$attendanceDays, showLocationPage=$showLocationPage',
    );

    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: WillPopScope(
        onWillPop: () async {
          if (_backButtonPressedCount == 1) {
            addDebugLog('Back button pressed twice, exiting');
            return true;
          } else {
            _backButtonPressedCount++;
            Get.snackbar(
              'تنبيه',
              'press_back'.tr,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              duration: Duration(seconds: 3),
            );
            addDebugLog('Back button pressed once');
            Timer(Duration(seconds: 2), () {
              _backButtonPressedCount = 0;
            });
            return false;
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/images/logo.png'),
              ),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
                addDebugLog('Drawer opened');
              },
            ),
          ),
          drawer: Drawer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [mainColor, Color.fromARGB(255, 0, 243, 223)],
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(height: 40.0),
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.white),
                    title: Text(
                      'الحساب',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => Profile());
                      addDebugLog('Navigated to Profile');
                    },
                  ),
                  SizedBox(height: 8.0),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: Colors.white),
                    title: Text(
                      'التعليمات',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => InfoPage());
                      addDebugLog('Navigated to InfoPage');
                    },
                  ),
                  SizedBox(height: 8.0),
                  ListTile(
                    leading: Icon(Icons.factory, color: Colors.white),
                    title: Text(
                      'بيانات مصنعك',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => FactoryData(selectedFactory: factName));
                      addDebugLog('Navigated to FactoryData');
                    },
                  ),
                  SizedBox(height: 16.0),
                  Divider(color: Colors.white.withOpacity(0.5)),
                ],
              ),
            ),
          ),
          backgroundColor: Colors.white,
          body:
              isLoading
                  ? Center(child: CircularProgressIndicator(color: mainColor))
                  : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await fetchData();
                      addDebugLog('Refreshed data');
                    },
                    color: mainColor,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Student Info Cards
                            _buildDataCard(
                              icon: Icons.person,
                              title: 'الاسم',
                              value: student?['name'] ?? '',
                            ),
                            SizedBox(height: 12),
                            _buildDataCard(
                              icon: Icons.school,
                              title: 'السنة الدراسية',
                              value:
                                  '${student?['batch']} ، ${student?['stage']}',
                            ),
                            SizedBox(height: 12),
                            _buildDataCard(
                              icon: Icons.business,
                              title: 'القسم',
                              value: student?['department'] ?? '',
                            ),
                            SizedBox(height: 12),
                            _buildDataCard(
                              icon: Icons.factory,
                              title: 'المصنع',
                              value: factName ?? 'يتم التحميل..',
                            ),
                            SizedBox(height: 12),
                            // Attendance Card
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'الحضور',
                                          style: TextStyle(
                                            color: mainColor,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Tajawal',
                                          ),
                                        ),
                                        Text(
                                          '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16.0,
                                            fontFamily: 'Tajawal',
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Center(
                                      child: Column(
                                        children: [
                                          Text(
                                            'أيام الحضور',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16.0,
                                              fontFamily: 'Tajawal',
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            '$attendanceDays',
                                            style: TextStyle(
                                              color: mainColor,
                                              fontSize: 48.0,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Tajawal',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            // Action Buttons
                            if (currentAttendanceId == null)
                              SizedBox(
                                height: 60.0,
                                width: double.infinity,
                                child: CreateButton(
                                  onPressed: () async {
                                    // نافذة تأكيد قبل أي إجراء
                                    bool? confirmed = await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: Text(
                                              'تأكيد',
                                              style: TextStyle(
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                            content: Text(
                                              'هل أنت متأكد أنك تريد بدء اليوم؟',
                                              style: TextStyle(
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                child: Text(
                                                  'إلغاء',
                                                  style: TextStyle(
                                                    fontFamily: 'Tajawal',
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                child: Text(
                                                  'تأكيد',
                                                  style: TextStyle(
                                                    fontFamily: 'Tajawal',
                                                    color: mainColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                    );

                                    if (confirmed != true) return;

                                    if (attendanceDays == 0) {
                                      // أول يوم: انتقل إلى تحديد الموقع
                                      Get.to(
                                        () => LocationConfirmationPage(
                                          factName: factName ?? '',
                                          onLocationConfirmed: () {
                                            Get.to(() => EnterFactory());
                                          },
                                        ),
                                      );
                                    } else if (hasEnteredToday) {
                                      await _showAttendanceWarning();
                                    } else {
                                      bool hasExistingAttendance =
                                          await _checkExistingAttendance();
                                      if (hasExistingAttendance) {
                                        await _showAttendanceWarning();
                                      } else {
                                        Get.to(() => EnterFactory());
                                      }
                                    }
                                  },
                                  title: Center(
                                    child: Text(
                                      hasEnteredToday
                                          ? 'لقد قمت بتسجيل الدخول اليوم بالفعل'
                                          : 'بدء اليوم',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontFamily: 'Tajawal',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              SizedBox(
                                height: 60.0,
                                width: double.infinity,
                                child: CreateButton(
                                  onPressed: () {
                                    Get.to(
                                      () => ExitFactory(
                                        attendanceId:
                                            currentAttendanceId.toString(),
                                      ),
                                    );
                                  
                                    addDebugLog('Navigated to ExitFactory');
                                  },
                                  title: Center(
                                    child: Text(
                                      'exit_factory'.tr,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontFamily: 'Tajawal',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            SizedBox(height: 10,),
                            SizedBox(
                              height: 60.0,
                              width: double.infinity,
                              child: CreateButton(
                                onPressed: () async {
                                  // نافذة تأكيد قبل أي إجراء
                                  bool? confirmed = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                      title: Text(
                                        'تأكيد',
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                        ),
                                      ),
                                      content: Text(
                                        'هل أنت متأكد أنك تريد بدء التقرير؟',
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(
                                            context,
                                            false,
                                          ),
                                          child: Text(
                                            'إلغاء',
                                            style: TextStyle(
                                              fontFamily: 'Tajawal',
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(
                                            context,
                                            true,
                                          ),
                                          child: Text(
                                            'تأكيد',
                                            style: TextStyle(
                                              fontFamily: 'Tajawal',
                                              color: mainColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed != true) return;

                                  if (hasSubmitedReportToday) {
                                    await _showAttendanceWarning();
                                  } else {
                                    Get.to(
                                          () => SubmitDailyReport(),
                                    );

                                  }
                                },
                                title: Center(
                                  child: Text(
                                    hasSubmitedReportToday
                                        ? 'لقد قمت بتسجيل التقرير اليوم بالفعل'
                                        : 'ارسال التقرير اليومي',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildDataCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: mainColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.0,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
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
      ),
    );
  }
}


