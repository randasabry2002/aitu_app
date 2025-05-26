// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';

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
          await FirebaseFirestore.instance.collection("NominationCard").doc('1').get();

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ File downloaded to AITU folder")),
        );
        debugPrint("✅ PDF downloaded to: $savePath");

      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Permission denied, please allow in settings")),
        );
        openAppSettings();
      }
    } catch (e) {
      debugPrint("❌ Error downloading PDF: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to download file")),
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
      child: Scaffold(
        
        backgroundColor: Color(0xFF0187c4),
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
                                Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'downloading'.tr,
                              style: TextStyle(
                                color: Colors.white,
                              ),
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
                    downloadPDFToDownloads();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Downloading...")));
                  },
                  label: Text(
                    "Download",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  icon: Icon(Icons.download),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
