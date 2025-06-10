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

class HomeScreen extends StatefulWidget {
  final String studentEmail;
  const HomeScreen({super.key, this.studentEmail = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _backButtonPressedCount = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  QueryDocumentSnapshot? student;
  QueryDocumentSnapshot? factory;
  String? currentAttendanceId;
  bool isLoading = true;
  bool hasEnteredToday = false;

  Future<void> fetchData() async {
    try {
      student = await getStudent();
      factory = (await getFactory()) as QueryDocumentSnapshot<Object?>?;
      await checkCurrentAttendance();
      await checkTodayAttendance();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkCurrentAttendance() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String attendanceId = prefs.getString("attendanceId") ?? 'null';
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
        } else {
          await prefs.setString("attendanceId", 'null');
        }
      }
    } catch (e) {
      print('Error checking attendance: $e');
    }
  }

  Future<void> checkTodayAttendance() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));

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
    } catch (e) {
      // ignore: avoid_print
      print('Error checking today attendance: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<QueryDocumentSnapshot?> getStudent() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString("email") ?? '';

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('StudentsTable')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null;
    } catch (e) {
      print('Error getting student: $e');
      return null;
    }
  }

  String? factName = '';

  Future<DocumentSnapshot?> getFactory() async {
    try {
      QueryDocumentSnapshot? student = await getStudent();
      if (student != null) {
        String factoryId = student['factory'] ?? '..';

        DocumentSnapshot factoryDoc =
            await FirebaseFirestore.instance
                .collection('Factories')
                .doc(factoryId)
                .get();

        if (factoryDoc.exists) {
          factName = factoryDoc['name'];
          return factoryDoc;
        }
      }
      return null;
    } catch (e) {
      print('Error getting factory: $e');
      return null;
    }
  }

  Future<bool> _checkExistingAttendance() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString("email") ?? '';

      DateTime today = DateTime.now();
      DateTime dateOnly = DateTime(today.year, today.month, today.day);

      QuerySnapshot existingAttendance =
          await FirebaseFirestore.instance
              .collection('Attendances')
              .where('Student_Email', isEqualTo: email)
              .where('Date', isEqualTo: Timestamp.fromDate(dateOnly))
              .get();

      return existingAttendance.docs.isNotEmpty;
    } catch (e) {
      print('Error checking existing attendance: $e');
      return false;
    }
  }

  Future<void> _showAttendanceWarning() async {
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: WillPopScope(
        onWillPop: () async {
          if (_backButtonPressedCount == 1) {
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
            backgroundColor: Color.fromARGB(0, 1, 134, 196),
            leading: IconButton(
              icon: Icon(Icons.menu, color: const Color.fromARGB(255, 0, 0, 0)),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
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
                    leading: Icon(
                      Icons.person,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
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
                    },
                  ),
                  SizedBox(height: 8.0),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
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
                    },
                  ),
                  SizedBox(height: 8.0),
                  ListTile(
                    leading: Icon(
                      Icons.factory,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    title: Text(
                      'بيانات مصنعك',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    onTap: () async {
                      Get.to(
                        () => FactoryData(selectedFactory: student?['factory']),
                      );
                    },
                  ),
                  SizedBox(height: 16.0),
                  Divider(color: Colors.white.withOpacity(0.5)),
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    title: Text(
                      'تسجيل الخروج',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // Add your logout logic here
                    },
                  ),
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
                    },
                    color: mainColor,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 40),

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
                              value: student?['factory'] ?? 'يتم التحميل..',
                            ),
                            SizedBox(height: 12),

                            _buildDataCard(
                              icon: Icons.supervised_user_circle,
                              title: 'المشرف',
                              value:
                                  student?['supervisor'].toString() ??
                                  'بدون مشرف',
                            ),
                            SizedBox(height: 24),

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
                                    FutureBuilder<QuerySnapshot>(
                                      future:
                                          FirebaseFirestore.instance
                                              .collection('Attendances')
                                              .where(
                                                'Student_ID',
                                                isEqualTo: student?['code'],
                                              )
                                              .get(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: mainColor,
                                            ),
                                          );
                                        }
                                        if (snapshot.hasError) {
                                          return Text(
                                            'Error: ${snapshot.error}',
                                          );
                                        }
                                        int attendsDays =
                                            snapshot.data?.docs.length ?? 0;
                                        return Center(
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
                                                '$attendsDays',
                                                style: TextStyle(
                                                  color: mainColor,
                                                  fontSize: 48.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Tajawal',
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
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
                                  onPressed:
                                      hasEnteredToday
                                          ? () {}
                                          : () async {
                                            bool hasExistingAttendance =
                                                await _checkExistingAttendance();
                                            if (hasExistingAttendance) {
                                              await _showAttendanceWarning();
                                            } else {
                                              Get.to(() => EnterFactory());
                                            }
                                          },
                                  title: Center(
                                    child: Text(
                                      hasEnteredToday
                                          ? 'already_entered'.tr
                                          : 'enter_factory'.tr,
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
                                    Get.to(() => ExitFactory(attendanceId: currentAttendanceId.toString(),));
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
