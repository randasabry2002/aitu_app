import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:flutter/material.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UplooadRerport extends StatefulWidget {
  const UplooadRerport({super.key});

  @override
  State<UplooadRerport> createState() => _UplooadRerportState();
}

class _UplooadRerportState extends State<UplooadRerport> {
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final supabase = Supabase.instance.client;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedImage != null) {
        setState(() {
          _selectedImage = pickedImage;
        });
      }
    } catch (e) {
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'خطأ',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'حدث خطأ أثناء اختيار الصورة',
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
          );
        },
      );
    }
  }

  Future<void> _uploadReport() async {
    if (_selectedImage == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('studentId');

      if (studentId == null) {
        throw Exception('Student ID not found');
      }

      final file = File(_selectedImage!.path);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.name}';
      final filePath = 'reports/$fileName';

      await supabase.storage.from('reports').upload(filePath, File(_selectedImage!.path));
      final imageUrl = supabase.storage.from('reports').getPublicUrl(filePath);

      await _firestore.collection('Reports').add({
        'studentId': studentId,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      Get.snackbar(
        'نجاح',
        'تم رفع التقرير بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );

      setState(() {
        _selectedImage = null;
      });
    } catch (e) {
      print('Error uploading report: $e');
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'خطأ',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'حدث خطأ أثناء رفع التقرير:\n$e',
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
          );
        },
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: Text(
            'رفع التقرير',
            style: TextStyle(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),

                    // Header Section
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
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: mainColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.description_outlined,
                                    color: mainColor,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'رفع التقرير',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14.0,
                                          fontFamily: 'Tajawal',
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'قم برفع صورة التقرير الخاص بك',
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
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Upload Section
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
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: mainColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.upload_file,
                                    color: mainColor,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'اختر الصورة',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14.0,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    250,
                                    253,
                                    255,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color:
                                        _selectedImage != null
                                            ? mainColor
                                            : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child:
                                    _selectedImage != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          child: Image.file(
                                            File(_selectedImage!.path),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                        : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons
                                                  .add_photo_alternate_outlined,
                                              size: 60,
                                              color: mainColor,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'اضغط لاختيار صورة التقرير',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 16,
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                          ],
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Upload Button
                    if (_selectedImage != null)
                      SizedBox(
                        height: 60.0,
                        width: double.infinity,
                        child: CreateButton(
                          onPressed:
                              isLoading
                                  ? () {}
                                  : () {
                                    _uploadReport();
                                  },
                          title: Center(
                            child: Text(
                              'رفع التقرير',
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
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: SpinKitCircle(color: mainColor, size: 50.0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
