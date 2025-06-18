import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:docx_template/docx_template.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;

class ShowNominationCardDistribution extends StatefulWidget {
  const ShowNominationCardDistribution({super.key});

  @override
  State<ShowNominationCardDistribution> createState() =>
      _ShowNominationCardDistributionState();
}

class _ShowNominationCardDistributionState
    extends State<ShowNominationCardDistribution> {
  final String _pdfUrl =
      'https://cjzaqgnhcpjtlswhnbda.supabase.co/storage/v1/object/public/pdfs/nominationCard_PDF_Version.pdf';
  bool _downloading = false;

  // Example data
  final String companyName = "شركة البرمجيات الحديثة";
  final String governorate = "أسيوط";
  final String studentName = "سليمان علي";
  final String nationalID = "30001010123456";
  final String specialization = "تكنولوجيا المعلومات";
  final String academicLevel = "الثالثة";

  Future<void> _downloadPdf() async {
    setState(() {
      _downloading = true;
    });
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('مطلوب إذن للوصول إلى التخزين');
        }
      }
      final response = await http.get(Uri.parse(_pdfUrl));
      if (response.statusCode != 200) throw Exception('فشل في تحميل الملف');
      final Directory dir = await getTemporaryDirectory();
      final String filePath = '${dir.path}/nominationCard_PDF_Version.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحميل الملف بنجاح: $filePath'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل الملف: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _downloading = false;
      });
    }
  }

  void _uploadReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('زر رفع التقرير (لم يتم تنفيذ المنطق بعد)'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'بطاقة الترشيح (PDF)',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: SfPdfViewer.network(_pdfUrl),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _downloading ? null : _downloadPdf,
                  icon:
                      _downloading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Icon(Icons.download),
                  label: Text(_downloading ? 'جاري التحميل...' : 'تحميل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _uploadReport,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('رفع التقرير'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                    ),
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

// Provider مخصص لعرض ui.Image
class UiImageProvider extends ImageProvider<UiImageProvider> {
  final ui.Image image;

  UiImageProvider(this.image);

  @override
  Future<UiImageProvider> obtainKey(ImageConfiguration configuration) {
    return Future.value(this);
  }

  @override
  ImageStreamCompleter loadImage(
    UiImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(
      Future.value(ImageInfo(image: key.image.clone(), scale: 1.0)),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UiImageProvider && image == other.image;

  @override
  int get hashCode => image.hashCode;
}
