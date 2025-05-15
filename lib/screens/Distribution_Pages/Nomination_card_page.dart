// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:docx_template/docx_template.dart';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:open_file/open_file.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import 'PDFViewerScreen_Nomination.dart';
//
// class Nomination_card_page extends StatefulWidget {
//   const Nomination_card_page({super.key});
//
//   @override
//   State<Nomination_card_page> createState() => _Nomination_card_pageState();
// }
//
// class _Nomination_card_pageState extends State<Nomination_card_page> {
//   String? studentId;
//   late final String pdfPath;
//
//   Future<Map<String, String>> getStudentData(String studentId) async {
//     try {
//       DocumentSnapshot studentDoc = await FirebaseFirestore.instance
//           .collection('StudentsTable')
//           .doc(studentId)
//           .get();
//       if (studentDoc.exists) {
//         return {
//           'Name': studentDoc['Name'],
//           'National_id': studentDoc['National_id'],
//           'Major': studentDoc['Major'],
//           'AcademicYear': studentDoc['AcademicYear'],
//         };
//       } else {
//         throw Exception("Student not found");
//       }
//     } catch (e) {
//       print("Error fetching student data: $e");
//       return {};
//     }
//   }
//
//   Future<File> fillTemplate(Map<String, String> studentData) async {
//     final ByteData data = await rootBundle.load('assets/template.docx');
//     final List<int> bytes = data.buffer.asUint8List();
//     final docx = await DocxTemplate.fromBytes(bytes);
//
//     // إنشاء كائن Content لتخزين البيانات
//     final content = Content();
//     content
//       ..add(TextContent('Name', studentData['Name'] ?? ''))
//       ..add(TextContent('National_id', studentData['National_id'] ?? ''))
//       ..add(TextContent('Major', studentData['Major'] ?? ''))
//       ..add(TextContent('AcademicYear', studentData['AcademicYear'] ?? ''));
//       // ..add(TextContent('factory_name', studentData['factory_name'] ?? ''))
//       // ..add(TextContent('governorate', studentData['governorate'] ?? ''));
//
//     final doc = await docx.generate(content);
//
//     if (doc == null) {
//       throw Exception("فشل إنشاء الملف!");
//     }
//
//     final Directory directory = await getApplicationDocumentsDirectory();
//     final File file = File('${directory.path}/student_letter.docx');
//     await file.writeAsBytes(doc);
//
//     return file;
//   }
//
//   Future<File> convertDocxToPdf(File docxFile) async {
//     final PdfDocument document = PdfDocument();
//     final Directory directory = await getApplicationDocumentsDirectory();
//     final File pdfFile = File('${directory.path}/student_letter.pdf');
//
//     await pdfFile.writeAsBytes(await document.save());
//     document.dispose();
//
//     return pdfFile;
//   }
//
//   void downloadFile(File file) {
//     try {
//       OpenFile.open(file.path);
//     } catch (e) {
//       print("Error opening file: $e");
//     }
//   }
//
//   Future<void> requestStoragePermission() async {
//     if (await Permission.storage.request().isGranted) {
//       print("Permission granted");
//     } else {
//       print("Permission denied");
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     SharedPreferences.getInstance().then((value) {
//       studentId = value.getString("studentId").toString();
//
//       Future.delayed(Duration(seconds: 2), () {
//         if (studentId != 'null') {
//           getStudentData(studentId!);
//         } else {}
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("عرض الملف")),
//       body: Column(
//         children: [
//           // PDFView(filePath: pdfPath),
//           ElevatedButton(
//             onPressed: () async {
//               Map<String, String> studentData = await getStudentData("student123");
//               File docFile = await fillTemplate(studentData);
//               File pdfFile = await convertDocxToPdf(docFile);
//
//               // Navigator.push(
//               //   context,
//               //   MaterialPageRoute(
//               //     builder: (context) => PDFViewerScreen_Nomination(pdfPath: pdfFile.path),
//               //   ),
//               // );
//             },
//             child: Text("إنشاء وعرض المستند"),
//           ),
//         ],
//       ),
//     );
//   }
// }
