import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getAddressFromGeoPoint(GeoPoint geoPoint) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(geoPoint.latitude, geoPoint.longitude);

      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ?? 'Unknown Location';
      } else {
        return 'Unknown Location';
      }
    } catch (e) {
      return 'Location Error';
    }
  }

  Future<Map<String, String>> getStudentData(String studentId) async {
    try {
      var studentDoc =
          await _firestore.collection("StudentsTable").doc(studentId).get();
      if (studentDoc.exists) {
        var studentData = studentDoc.data() as Map<String, dynamic>;
        return {
          'Name': studentData['Name'] ?? 'Unknown',
          'Grade': studentData['AcademicYear'] ?? 'Unknown',
          'Major': studentData['Major'] ?? 'Unknown',
        };
      } else {
        return {'Name': 'Unknown', 'Grade': 'Unknown', 'Major': 'Unknown'};
      }
    } catch (e) {
      return {'Name': 'Error', 'Grade': 'Error', 'Major': 'Error'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF0187c4),
        title: Center(
            child: Text(
          'attendance_page'.tr,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
        )),
      ),
      backgroundColor: Color(0xFF0187c4),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("Attendances").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("لا توجد بيانات متاحة"));
          }
          var data = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                border: TableBorder.all(),
                columns: const [
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Grade")),
                  DataColumn(label: Text("Major")),
                  DataColumn(label: Text("Date")),
                  DataColumn(label: Text("Training Place Name")),
                  DataColumn(label: Text("Supervisor Name")),
                  DataColumn(label: Text("Entry Location")),
                  DataColumn(label: Text("Entry Time")),
                  DataColumn(label: Text("Exit Location")),
                  DataColumn(label: Text("Exit Time")),
                  DataColumn(label: Text("Benefit Rate")),
                  DataColumn(label: Text("Supervisor Rate")),
                  DataColumn(label: Text("Environment Rate")),
                ],
                rows: data.map((doc) {
                  var record = doc.data() as Map<String, dynamic>;
                  return DataRow(cells: [
                    DataCell(FutureBuilder<Map<String, String>>(
                      future: getStudentData(record['Student_ID']),
                      // استعلام باستخدام student_id
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading...');
                        } else if (snapshot.hasError) {
                          return Text('Error');
                        } else if (snapshot.hasData) {
                          var studentData = snapshot.data;
                          // إضافة تحقق إذا كانت البيانات null
                          return Text(studentData?['Name'] ?? 'Unknown');
                        } else {
                          return Text('No Data');
                        }
                      },
                    )),
                    DataCell(FutureBuilder<Map<String, String>>(
                      future: getStudentData(record['Student_ID']),
                      // استعلام باستخدام student_id
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading...');
                        } else if (snapshot.hasError) {
                          return Text('Error');
                        } else {
                          var studentData = snapshot.data;
                          return Text(studentData?['Grade'] ?? 'Unknown');
                        }
                      },
                    )),
                    DataCell(FutureBuilder<Map<String, String>>(
                      future: getStudentData(record['Student_ID']),
                      // استعلام باستخدام student_id
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading...');
                        } else if (snapshot.hasError) {
                          return Text('Error');
                        } else {
                          var studentData = snapshot.data;
                          return Text(studentData?['Major'] ?? 'Unknown');
                        }
                      },
                    )),
                    DataCell(Text(record['Date'] != null
                        ? DateFormat('EEEE, yyyy-MM-dd')
                            .format((record['Date'] as Timestamp).toDate())
                        : '')),
                    DataCell(Text(record['TrainingPlaceName']?.toString() ?? '')),
                    DataCell(Text(record['SupervisorName'] ?? '')),
                    DataCell(
                      FutureBuilder<String>(
                        future:
                            getAddressFromGeoPoint(record['EnteringLocation']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text(
                                'Loading...'); // Show loading text while fetching
                          } else if (snapshot.hasError) {
                            return Text('Error');
                          } else {
                            return Text(snapshot.data ?? 'Unknown Location');
                          }
                        },
                      ),
                    ),
                    DataCell(Text(record['EnteringTime'] != null
                        ? DateFormat('HH:mm:ss').format(
                            (record['EnteringTime'] as Timestamp).toDate())
                        : '')),
                    DataCell(
                      FutureBuilder<String>(
                        future:
                            getAddressFromGeoPoint(record['ExitingLocation']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text(
                                'Loading...'); // Show loading text while fetching
                          } else if (snapshot.hasError) {
                            return Text('Error');
                          } else {
                            return Text(snapshot.data ?? 'Unknown Location');
                          }
                        },
                      ),
                    ),
                    DataCell(Text(record['ExitingTime'] != null
                        ? DateFormat('HH:mm:ss').format(
                            (record['ExitingTime'] as Timestamp).toDate())
                        : '')),
                    DataCell(Text(record['BenefitRating']?.toInt().toString() ?? '0')),
                    DataCell(Text(record['SupervisorRating']?.toInt().toString() ?? '0')),
                    DataCell(Text(record['EnvironmentRating']?.toInt().toString() ?? '0')),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
