import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:aitu_app/screens/Attendance_Part_Pages/homeScreen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:aitu_app/screens/Distribution_Pages/Not_College_distribution_page.dart';

class PDFViewerPage extends StatefulWidget {
  // const PDFViewerPage({Key? key}) : super(key: key);
  String? factoryID;
  bool isNominationCard;
  PDFViewerPage({this.factoryID, required this.isNominationCard});
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  bool isLoading = false;
  String? currentStudentEmail; // إضافة متغير لتخزين إيميل الطالب

  @override
  void initState() {
    super.initState();
    // جلب إيميل الطالب الحالي من FirebaseAuth
    currentStudentEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentStudentEmail != null) {
      getStudentData(currentStudentEmail!).then((_) {
        getFactoryData();
      });
    } else {
      print('Current email is null. Please provide the current user\'s email.');
    }
  }

  File? generatedWordFile; // Declare at class level if not already

  Future<void> generateWordFile(Map<String, dynamic> data) async {
    setState(() => isLoading = true);
    try {
      await Permission.storage.request();

      final response = await http.post(
        Uri.parse(
          'https://notvzcfdvyebmjwafocg.supabase.co/functions/v1/word-generator',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        final directory = await getApplicationDocumentsDirectory();
        // Save with name (report_student id _ date)
        final studentId = data['nationalID'] ?? 'unknown';
        final now = DateTime.now();
        // Get the student document ID from StudentsTable and use it as studentId
        String? studentDocId;
        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('StudentsTable')
                .where('nationalID', isEqualTo: data['nationalID'])
                .limit(1)
                .get();
        if (querySnapshot.docs.isNotEmpty) {
          studentDocId = querySnapshot.docs.first.id;
        } else {
          studentDocId = 'unknown';
        }
        final formattedDate =
            '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
        final filePath =
            '${directory.path}/report_${studentDocId}_$formattedDate.docx';
        final file = File(filePath);

        await file.writeAsBytes(bytes);

        // Save file in generatedWordFile
        setState(() {
          generatedWordFile = file;
        });

        // await OpenFile.open(file.path);
      } else {
        print('خطأ في الاستجابة: [31m[1m[4m${response.statusCode}[0m');
      }
    } catch (e) {
      print('حدث خطأ: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 1. Method to get student data from StudentsTable by current email
  Map<String, dynamic> studentData = {};
  Map<String, dynamic> factoryData = {};

  Future<void> getStudentData(String currentEmail) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('StudentsTable')
              .where('email', isEqualTo: currentEmail)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        studentData = Map<String, dynamic>.from(
          querySnapshot.docs.first.data() as Map,
        );
        setState(() {}); // To update UI if needed
      } else {
        print('No student found with email: $currentEmail');
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
  }

  Future<void> getFactoryData() async {
    if (!studentData.containsKey('factory')) {
      print('Student data not loaded or missing factory field');
      return;
    }
    final factoryName = studentData['factory'];
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('Factories')
              .where('name', isEqualTo: widget.factoryID)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        factoryData = Map<String, dynamic>.from(
          querySnapshot.docs.first.data() as Map,
        );
        setState(() {}); // To update UI if needed
      } else {
        print('No factory found with name: ${widget.factoryID}');
      }
    } catch (e) {
      print('Error fetching factory data: $e');
    }
  }

  // External variable to hold the generated file

  Future<void> handleGenerateWordFile() async {
    setState(() => isLoading = true);
    await generateWordFile({
      "companyName": factoryData['name'],
      "governorate": factoryData['Governorate'],
      "studentName": studentData['name'],
      "nationalID": studentData['nationalID'],
      "specialization": studentData['department'],
      "academicLevel":
          '${studentData['batch'] == 1
              ? "سنه اولى"
              : studentData['batch'] == 2
              ? "سنه تانيه"
              : studentData['batch'] == 3
              ? "سنه تالته"
              : studentData['batch'] == 4
              ? "سنه رابعه"
              : studentData['batch']}',
    });
    setState(() => isLoading = false);
  }

  Future<bool> doesReportFileExistInSupabase() async {
    try {
      // استخدام المتغير المخزن بدلاً من جلب الإيميل مرة أخرى
      if (currentStudentEmail == null) {
        print('Current user email is null.');
        return false;
      }

      // Query Firestore Reports collection for any document with studentEmail == currentEmail
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('Reports')
              .where('studentEmail', isEqualTo: currentStudentEmail)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking report existence in Firestore: $e');
      return false;
    }
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.10),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon(
          //   Icons.info_outline,
          //   color: Colors.blueAccent,
          //   size: 22,
          // ),
          // SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: Colors.blueGrey[900],
              letterSpacing: 0.2,
            ),
          ),
          // SizedBox(width: 12),
          Expanded(
            child: Text(
              value != null ? value.toString() : '',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                color: Colors.blueGrey[700],
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isNominatinCardAppear = widget.isNominationCard;
    final String pdfUrl =
        'https://cjzaqgnhcpjtlswhnbda.supabase.co/storage/v1/object/public/pdfs//test.pdf';
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            title: Text(
              widget.isNominationCard?'بطاقة الترشيح':'توزيعة الكلية',
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontFamily: 'Tajawal',
                fontSize: 20.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
            IconButton(
              icon: Icon(
                Icons.info_outline,
                color: Colors.blueGrey[700],
              ),
              tooltip: 'معلومات',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'معلومات هامة',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    content: Text(
                      'قم بالبحث عن اسمك لمعرفة مصنعك (من الاحسن أخذ لقطة شاشه بالبيانات الخاصه بك) ثم قم بالعوده الى الصفحه السابقة لبدأ الحضور',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text(
                          'حسناً',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            ],
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
          ),

          body: Center(
            child:
                widget.isNominationCard
                    ? SingleChildScrollView(
                      child: Column(
                        children: [
                          //main card
                          Container(
                            padding: EdgeInsets.all(24.0),
                            margin: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 24.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.8),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "بيانات الطالب",
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.blueGrey[800],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 12),
                                Divider(),
                                SizedBox(height: 8),
                                _buildInfoRow("الاسم:", studentData['name']),
                                _buildInfoRow(
                                  "الرقم القومي:",
                                  studentData['nationalID'],
                                ),
                                _buildInfoRow(
                                  "التخصص:",
                                  studentData['department'],
                                ),
                                _buildInfoRow(
                                  "الفرقة:",
                                  studentData['batch'] == 1
                                      ? "سنه اولى"
                                      : studentData['batch'] == 2
                                      ? "سنه تانيه"
                                      : studentData['batch'] == 3
                                      ? "سنه تالته"
                                      : studentData['batch'] == 4
                                      ? "سنه رابعه"
                                      : "${studentData['batch']}",
                                ),
                                SizedBox(height: 24),
                                Text(
                                  "بيانات المصنع",
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.blueGrey[800],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 12),
                                Divider(),
                                SizedBox(height: 8),
                                _buildInfoRow(
                                  "اسم المصنع:",
                                  factoryData['name'],
                                ),
                                _buildInfoRow(
                                  "المحافظة:",
                                  factoryData['Governorate'] ??
                                      factoryData['address'],
                                ),
                              ],
                            ),
                          ),
                          //buttons
                          //upload to supabase
                          StatefulBuilder(
                            builder: (context, setState) {
                              bool isProcessing = false;

                              Future<void> handleUpload() async {
                                setState(() => isProcessing = true);

                                if (generatedWordFile != null &&
                                    await doesReportFileExistInSupabase()) {
                                  Get.snackbar(
                                    'تنبيه',
                                    'تم ارسال التقرير مسبقاً.',
                                    backgroundColor: Colors.orange[100],
                                    colorText: Colors.black,
                                  );
                                  setState(() => isProcessing = false);
                                  return;
                                }
                                await handleGenerateWordFile();

                                if (generatedWordFile != null) {
                                  try {
                                    final supabase = Supabase.instance.client;
                                    final fileName =
                                        '${DateTime.now().millisecondsSinceEpoch}_${generatedWordFile!.path.split('/').last}';
                                    final storagePath = 'reports/$fileName';

                                    final fileBytes =
                                        await generatedWordFile!.readAsBytes();

                                    final storageResponse = await supabase
                                        .storage
                                        .from('reports')
                                        .uploadBinary(
                                          fileName,
                                          fileBytes,
                                          fileOptions: const FileOptions(
                                            upsert: true,
                                          ),
                                        );

                                    if (storageResponse != null &&
                                        storageResponse is String &&
                                        storageResponse.isNotEmpty) {
                                      final publicUrl = supabase.storage
                                          .from('reports')
                                          .getPublicUrl(fileName);

                                      await FirebaseFirestore.instance
                                          .collection('Reports')
                                          .add({
                                            'studentName': studentData['name'],
                                            'studentEmail': currentStudentEmail,
                                            'factoryName': factoryData['name'],
                                            'factoryGovernorate':
                                                factoryData['Governorate'],
                                            'fileUrl': publicUrl,
                                            'fileName': fileName,
                                            'createdAt':
                                                FieldValue.serverTimestamp(),
                                          });

                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder:
                                            (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              backgroundColor: Colors.white,
                                              title: Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color:
                                                        Colors.green.shade700,
                                                    size: 28,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'تم الرفع',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.green.shade900,
                                                      fontFamily: 'Tajawal',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'تم رفع التقرير إلى الكلية وحفظه بنجاح',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.green.shade900,
                                                      fontFamily: 'Tajawal',
                                                      fontSize: 16,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(height: 16),
                                                  Icon(
                                                    Icons.cloud_upload_rounded,
                                                    color:
                                                        Colors.green.shade400,
                                                    size: 48,
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    onPressed:
                                                        () =>
                                                            Navigator.of(
                                                              context,
                                                            ).pop(),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.green.shade700,
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 14,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'حسناً',
                                                      style: TextStyle(
                                                        fontFamily: 'Tajawal',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                    } else {
                                      print(
                                        'Failed to upload file to Supabase Storage. Error: $storageResponse',
                                      );
                                      Get.snackbar(
                                        'خطأ',
                                        'حدث خطأ أثناء رفع التقرير',
                                        backgroundColor: Colors.red.shade100,
                                        colorText: Colors.red.shade900,
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    }
                                  } catch (e) {
                                    print('Upload error: $e');
                                    Get.snackbar(
                                      'خطأ',
                                      'حدث خطأ أثناء رفع التقرير',
                                      backgroundColor: Colors.red.shade100,
                                      colorText: Colors.red.shade900,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }
                                } else {
                                  print('No generated Word file to upload.');
                                  Get.snackbar(
                                    'خطأ',
                                    'لم يتم العثور على ملف Word للرفع',
                                    backgroundColor: Colors.red.shade100,
                                    colorText: Colors.red.shade900,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                                setState(() => isProcessing = false);
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    icon:
                                        isProcessing
                                            ? SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                            : Icon(Icons.download_done_rounded),
                                    label:
                                        isProcessing
                                            ? Text('جاري الارسال...')
                                            : Text('ارسال التقرير الى الكليه'),
                                    onPressed:
                                        isProcessing
                                            ? null
                                            : () async {
                                              setState(() => isLoading = true);
                                              await handleUpload();
                                              setState(() => isLoading = false);
                                              Get.offAll(
                                                HomeScreen(
                                                  studentEmail:
                                                      currentStudentEmail!,
                                                ),
                                              );
                                            },
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16),
                          //download
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: SizedBox(
                              width: double.infinity,

                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blueAccent,

                                  side: BorderSide(
                                    color: Colors.blueAccent,
                                    width: 2,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                icon: Icon(Icons.file_download),
                                label: Text('تحميل ملف Word'),
                                onPressed:
                                    isLoading
                                        ? null
                                        : () async {
                                          if (generatedWordFile == null) return;

                                          // Show permission request dialog before requesting
                                          bool?
                                          userConfirmed = await showDialog<
                                            bool
                                          >(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: Text(
                                                    'طلب صلاحية التخزين',
                                                  ),
                                                  content: Text(
                                                    'يحتاج التطبيق إلى صلاحية الوصول للتخزين من أجل حفظ الملف. هل ترغب في منح الصلاحية؟',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.of(
                                                            context,
                                                          ).pop(false),
                                                      child: Text('لا'),
                                                    ),
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.of(
                                                            context,
                                                          ).pop(true),
                                                      child: Text('نعم'),
                                                    ),
                                                  ],
                                                ),
                                          );

                                          if (userConfirmed != true) {
                                            Get.snackbar(
                                              'تم الإلغاء',
                                              'لم يتم منح صلاحية التخزين',
                                            );
                                            return;
                                          }

                                          setState(() => isLoading = true);

                                          try {
                                            // Request storage permission
                                            final status =
                                                await Permission.storage
                                                    .request();
                                            if (!status.isGranted) {
                                              Get.snackbar(
                                                'خطأ',
                                                'لم يتم منح صلاحية الوصول للتخزين',
                                              );
                                              setState(() => isLoading = false);
                                              return;
                                            }

                                            // Get the Downloads directory
                                            Directory? downloadsDir;
                                            if (Platform.isAndroid) {
                                              downloadsDir = Directory(
                                                '/storage/emulated/0/Download',
                                              );
                                              if (!await downloadsDir
                                                  .exists()) {
                                                // fallback to external storage directory
                                                downloadsDir =
                                                    await getExternalStorageDirectory();
                                              }
                                            } else if (Platform.isIOS) {
                                              downloadsDir =
                                                  await getApplicationDocumentsDirectory();
                                            } else {
                                              downloadsDir =
                                                  await getApplicationDocumentsDirectory();
                                            }

                                            if (downloadsDir == null) {
                                              Get.snackbar(
                                                'خطأ',
                                                'تعذر تحديد مجلد التنزيلات',
                                              );
                                              setState(() => isLoading = false);
                                              return;
                                            }

                                            final fileName =
                                                generatedWordFile!.path
                                                    .split('/')
                                                    .last;
                                            final savePath =
                                                '${downloadsDir.path}/$fileName';

                                            final savedFile = await File(
                                              savePath,
                                            ).writeAsBytes(
                                              await generatedWordFile!
                                                  .readAsBytes(),
                                            );

                                            Get.snackbar(
                                              'تم التحميل',
                                              'تم حفظ الملف في مجلد التنزيلات:\n$fileName',
                                            );
                                          } catch (e) {
                                            Get.snackbar(
                                              'خطأ',
                                              'فشل في تحميل الملف',
                                            );
                                            print("Error during file save: $e");
                                          } finally {
                                            setState(() => isLoading = false);
                                          }
                                        },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : Stack(
                      children: [
                        SfPdfViewer.network(
                          'https://cjzaqgnhcpjtlswhnbda.supabase.co/storage/v1/object/public/pdfs//test.pdf',
                          canShowScrollHead: true,
                          canShowScrollStatus: true,
                          enableDoubleTapZooming: true,
                          onDocumentLoadFailed: (details) {
                            Get.snackbar(
                              'خطأ في التحميل',
                              'حدثت مشكلة أثناء تحميل الملف. الرجاء المحاولة مرة أخرى.',
                              backgroundColor: Colors.red.shade100,
                              colorText: Colors.red.shade900,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          onDocumentLoaded: (details) {
                            Get.snackbar(
                              'تم عرض التوزيعه',
                              'قم بالبحث عن اسمك ثم قم بالعوده لبدأ الحضور.',
                              backgroundColor: Colors.green.shade100,
                              colorText: Colors.green.shade900,
                              snackPosition: SnackPosition.TOP,
                              duration: Duration(seconds: 5),
                            );
                          },
                        ),
                       
                      ],
                    ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.white.withOpacity(0.7),
            child: Center(
              child: SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  strokeWidth: 7,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
