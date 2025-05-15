import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PDFViewerPage extends StatefulWidget {
  String pdfType = "";

  PDFViewerPage({super.key, required this.pdfType});

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  // String pdfUrl = "https://drive.google.com/uc?export=download&id=1el5VyrjmC5RhgEuNO-7I3SRN0u_nnK6Q";
  String? localPath;
  String pdfUrl = "";
  String pdfName = "";

  Future<void> fetchNominationCardURL() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("NominationCard").get();

      final doc = querySnapshot.docs.firstWhere(
            (doc) => doc["Name"] == "MainNominationCard",
        orElse: () => throw Exception("Document not found"),
      );

      setState(() {
        pdfUrl = doc["URL"] as String;
        pdfName = doc["Name"] as String;
      });
    } catch (e) {
      print("❌ Error fetching nomination card URL: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    initializePDF();

    downloadAndSavePDF();
  }

  Future<void> initializePDF() async {
    if (widget.pdfType == "nominationCard") {
      await fetchNominationCardURL();
    } else if (widget.pdfType == "distributionPdf") {
      pdfUrl = "https://drive.google.com/uc?export=download&id=1el5VyrjmC5RhgEuNO-7I3SRN0u_nnK6Q";
      pdfName = "Distribution_Pdf";
    }

    // تأكد إن الرابط صالح قبل التحميل
    if (pdfUrl.isNotEmpty && Uri.tryParse(pdfUrl)?.hasAbsolutePath == true) {
      await downloadAndSavePDF();
    } else {
      print("❌ Invalid or empty PDF URL: $pdfUrl");
    }
  }

  Future<void> downloadAndSavePDF() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/document.pdf");

      var connectivityResult = await (Connectivity().checkConnectivity());
      bool hasInternet = connectivityResult != ConnectivityResult.none;

      if (hasInternet) {
        if (file.existsSync()) {
          await file.delete();
        }

        var response = await Dio().download(
          pdfUrl,
          file.path,
          options: Options(
            headers: {"Cache-Control": "no-cache"},
          ),
        );

        if (response.statusCode == 200) {
          setState(() {
            localPath = file.path;
          });
        }
      } else {
        if (file.existsSync()) {
          setState(() {
            localPath = file.path;
          });
          print("⚠️ لا يوجد إنترنت، يتم استخدام النسخة القديمة من PDF.");
        } else {
          print("❌ لا يوجد إنترنت ولا يوجد ملف PDF محفوظ.");
        }
      }
    } catch (e) {
      print("Error downloading PDF: $e");
    }
  }

  Future<void> downloadPDFToDownloads() async {
    try {
      // طلب إذن الوصول إلى التخزين
      if (await Permission.manageExternalStorage.request().isGranted) {
        // الحصول على مجلد التنزيلات
        Directory? downloadsDir = Directory('/storage/emulated/0/Download');
        if (!downloadsDir.existsSync()) {
          downloadsDir = await getExternalStorageDirectory();
        }

        String savePath = "${downloadsDir!.path}/$pdfName.pdf";

        //  تحميل الملف
        await Dio().download(pdfUrl, savePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ تم تحميل الملف بنجاح في التنزيلات")),
        );
        print("✅ PDF تم تحميله إلى: $savePath");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ تم رفض الإذن، الرجاء منحه من الإعدادات")),
        );
        openAppSettings(); //  فتح إعدادات الهاتف لمنح الإذن يدويًا
      }
    } catch (e) {
      print("❌ خطأ في تحميل PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ فشل تحميل الملف")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Color(0xFF0187c4),
        body: Stack(
          children: [
            Positioned.fill(
              child: localPath == null
                  ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),))
                  : PDFView(
                filePath: localPath!,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: true,
                pageFling: true,
              ),
            ),
            Positioned(
              bottom: 30,
              right: 20,
              child: Visibility(
                visible: !(localPath == null),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    downloadPDFToDownloads();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("جاري التحميل...")),
                    );
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
