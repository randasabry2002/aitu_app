// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:io';
import 'package:aitu_app/screens/Distribution_Pages/Not_College_distribution_page.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:aitu_app/screens/Distribution_Pages/uploadReport.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A page to view and download PDFs, supporting both remote and local files.
class PDFViewerPage extends StatefulWidget {
  String pdfType = "";

  // Accepts a pdfType to determine which PDF to load.
  PDFViewerPage({super.key, required this.pdfType});

  @override
  PDFViewerPageState createState() => PDFViewerPageState();
}

class PDFViewerPageState extends State<PDFViewerPage> {
  String? localPath; // Local path of the downloaded PDF
  String pdfUrl = ""; // URL of the PDF to download
  String pdfName = ""; // Name of the PDF

  /// Fetches the URL and name of the nomination card PDF from Firestore.
  Future<void> fetchNominationCardURL() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection("NominationCard")
              .doc('1')
              .get();

      // Find the document with Name == "MainNominationCard"
      // final doc = querySnapshot.docs.firstWhere(
      //   (doc) => doc["id"] == "1",
      //   orElse: () => throw Exception("Document not found"),
      // );

      setState(() {
        pdfUrl = doc["URL"] as String;
        pdfName = doc["Name"] as String;
      });
    } catch (e) {
      // Use logging instead of print in production
      debugPrint("❌ Error fetching nomination card URL: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    initializePDF();
  }

  /// Initializes the PDF URL and name based on the pdfType.
  Future<void> initializePDF() async {
    if (widget.pdfType == "nominationCard") {
      await fetchNominationCardURL();
    } else if (widget.pdfType == "distributionPdf") {
      pdfUrl =
          "https://drive.google.com/uc?export=download&id=1el5VyrjmC5RhgEuNO-7I3SRN0u_nnK6Q";
      pdfName = "Distribution_Pdf";
    }

    // Check if the URL is valid before downloading
    if (pdfUrl.isNotEmpty && Uri.tryParse(pdfUrl)?.hasAbsolutePath == true) {
      await downloadAndSavePDF();
    } else {
      debugPrint("❌ Invalid or empty PDF URL: $pdfUrl");
    }
  }

  /// Downloads the PDF from [pdfUrl] and saves it locally.
  Future<void> downloadAndSavePDF() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/document.pdf");

      // Check for internet connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      bool hasInternet = connectivityResult != ConnectivityResult.none;

      if (hasInternet) {
        // Delete old file if exists
        if (file.existsSync()) {
          await file.delete();
        }

        // Download the PDF
        var response = await Dio().download(
          pdfUrl,
          file.path,
          options: Options(headers: {"Cache-Control": "no-cache"}),
        );

        if (response.statusCode == 200) {
          setState(() {
            localPath = file.path;
          });
        }
      } else {
        // If offline, use the old file if available
        if (file.existsSync()) {
          setState(() {
            localPath = file.path;
          });
          debugPrint("⚠️ No internet, using old PDF file.");
        } else {
          debugPrint("❌ No internet and no saved PDF file.");
        }
      }
    } catch (e) {
      debugPrint("Error downloading PDF: $e");
    }
  }

  /// Downloads the PDF to the device's Downloads folder.
  Future<void> downloadPDFToDownloads() async {
    try {
      // طلب صلاحية التخزين
      if (await Permission.manageExternalStorage.request().isGranted ||
          await Permission.storage.request().isGranted) {
        // تحديد مجلد التنزيلات
        Directory downloadsDir = Directory('/storage/emulated/0/Download');

        // إنشاء مجلد AITU داخل التنزيلات
        Directory aituDir = Directory('${downloadsDir.path}/AITU');
        if (!aituDir.existsSync()) {
          aituDir.createSync(recursive: true);
        }

        // تحديد المسار النهائي لحفظ الملف
        String savePath = '${aituDir.path}/$pdfName.pdf';

        // تنزيل الملف
        await Dio().download(pdfUrl, savePath);

        if (!mounted) return;
        Get.snackbar(
          'نجاح',
          "✅ تم تحميل الملف إلى مجلد AITU",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
        );
        debugPrint("✅ PDF downloaded to: $savePath");
      } else {
        if (!mounted) return;
        Get.snackbar(
          'خطأ',
          'حدث خطأ أثناء تحميل الملف',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
        );
        openAppSettings();
      }
    } catch (e) {
      debugPrint("❌ Error downloading PDF: $e");
      if (!mounted) return;
      Get.snackbar(
        'خطأ',
        "❌ فشل تحميل الملف",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    }
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
          if (widget.pdfType == "nominationCard") {
            bool? result = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    "تنبيه",
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    "إذا قمت بالرجوع الآن، لن يتم تسجيلك في هذا المصنع. هل أنت متأكد من رغبتك في الرجوع؟",
                    style: TextStyle(fontFamily: 'Tajawal'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        "لا",
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Get current user email from SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        String? email = prefs.getString("email");

                        if (email != null) {
                          // Find and update the student document
                          final querySnapshot =
                              await FirebaseFirestore.instance
                                  .collection('StudentsTable')
                                  .where('email', isEqualTo: email)
                                  .limit(1)
                                  .get();

                          if (querySnapshot.docs.isNotEmpty) {
                            await querySnapshot.docs.first.reference.update({
                              'isReportUploaded': null,
                            });
                          }
                        }
                        Navigator.of(context).pop(true);
                      },
                      child: Text(
                        "نعم",
                        style: TextStyle(
                          color: Colors.green,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
            return result ?? false;
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
              onPressed: () async {
                if (widget.pdfType == "nominationCard") {
                  bool? result = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          "تنبيه",
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          "إذا قمت بالرجوع الآن، لن يتم تسجيلك في هذا المصنع. هل أنت متأكد من رغبتك في الرجوع؟",
                          style: TextStyle(fontFamily: 'Tajawal'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              "لا",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Get current user email from SharedPreferences
                              final prefs =
                                  await SharedPreferences.getInstance();
                              String? email = prefs.getString("email");

                              if (email != null) {
                                // Find and update the student document
                                final querySnapshot =
                                    await FirebaseFirestore.instance
                                        .collection('StudentsTable')
                                        .where('email', isEqualTo: email)
                                        .limit(1)
                                        .get();

                                if (querySnapshot.docs.isNotEmpty) {
                                  await querySnapshot.docs.first.reference
                                      .update({'isReportUploaded': null});
                                }
                              }
                              // Navigator.of(context).pop(true);
                              Get.offAll(() => Not_College_distribution_page());
                            },
                            child: Text(
                              "نعم",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 172, 23, 23),
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  if (result == true) {
                    Navigator.pop(context);
                  }
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          body: Stack(
            children: [
              // PDF Viewer or loading indicator
              Positioned.fill(
                child:
                    localPath == null
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  mainColor,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'downloading'.tr,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        )
                        : PDFView(
                          filePath: localPath!,
                          enableSwipe: true,
                          swipeHorizontal: false,
                          autoSpacing: true,
                          pageFling: true,
                        ),
              ),
              // Download button
              Positioned(
                bottom: 30,
                right: 20,
                child: Visibility(
                  visible: localPath != null,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.pdfType == "nominationCard")
                                  ListTile(
                                    leading: Icon(
                                      Icons.upload_file,
                                      color: Colors.blue,
                                    ),
                                    title: Text(
                                      "رفع التقرير",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Get.to(() => const UplooadRerport());
                                    },
                                  ),
                                ListTile(
                                  leading: Icon(
                                    Icons.download,
                                    color: Colors.blue,
                                  ),
                                  title: Text(
                                    "تحميل",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    downloadPDFToDownloads();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("جاري التحميل..."),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    label: Text(
                      "خيارات",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: Icon(Icons.more_horiz),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
