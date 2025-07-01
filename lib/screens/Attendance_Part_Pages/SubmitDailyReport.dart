import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aitu_app/shared/constant.dart';

class SubmitDailyReport extends StatefulWidget {
  @override
  State<SubmitDailyReport> createState() => _SubmitDailyReportState();
}

class _SubmitDailyReportState extends State<SubmitDailyReport> {
  String? docId;
  String trainingNotebook = "";
  String trainerEvaluation = "";
  double benefitRating = 0;
  double supervisorRating = 0;
  double environmentRating = 0;
  String? studentId;
  List<String> imageUrls = [];
  List<File> selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = true;
  bool isSaving = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadOrCreateDiary();
  }

  Future<void> _loadOrCreateDiary() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      studentId = _prefs.getString("studentId") ?? "";
      DateTime today = DateTime.now();
      DateTime dateOnly = DateTime(today.year, today.month, today.day);

      print('Loading diary for student: $studentId on date: $dateOnly');

      QuerySnapshot diaryQuery =
          await FirebaseFirestore.instance
              .collection('StudentDiary')
              .where('studentId', isEqualTo: studentId)
              .where('date', isGreaterThanOrEqualTo: dateOnly)
              .where('date', isLessThan: dateOnly.add(Duration(days: 1)))
              .limit(1)
              .get();

      print('Found ${diaryQuery.docs.length} diary entries');

      if (diaryQuery.docs.isNotEmpty) {
        // يوجد تقرير اليوم
        final doc = diaryQuery.docs.first;
        docId = doc.id;
        final data = doc.data() as Map<String, dynamic>;

        print('Diary data: $data');

        setState(() {
          trainingNotebook = data['trainingNotebook'] ?? "";
          trainerEvaluation = data['trainerEvaluation'] ?? "";
          benefitRating = (data['benefitRating'] ?? 0).toDouble();
          supervisorRating = (data['supervisorRating'] ?? 0).toDouble();
          environmentRating = (data['environmentRating'] ?? 0).toDouble();
          imageUrls = List<String>.from(data['images'] ?? []);
          isLoading = false;
        });

        print('Loaded ${imageUrls.length} images');
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading diary: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImages.add(File(image.path));
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        selectedImages.add(File(image.path));
      });
    }
  }

  /// الحصول على URL صحيح للصورة من Supabase
  Future<String> _getSignedUrl(String imageUrl) async {
    try {
      final supabase = Supabase.instance.client;

      // التحقق من أن URL صحيح
      if (imageUrl.isEmpty) {
        throw Exception('Empty image URL');
      }

      // استخراج اسم الملف من URL
      String fileName = imageUrl.split('/').last.split('?').first;

      if (fileName.isEmpty) {
        throw Exception('Invalid file name from URL: $imageUrl');
      }

      // إنشاء signed URL صالح لمدة ساعة
      final signedUrl = await supabase.storage
          .from('studenttrainingimages')
          .createSignedUrl(fileName, 3600); // صالح لمدة ساعة

      print('Generated signed URL for: $fileName');
      return signedUrl;
    } catch (e) {
      print('Error generating signed URL for $imageUrl: $e');
      // في حالة الخطأ، نعيد URL الأصلي
      return imageUrl;
    }
  }

  /// حذف صورة من Supabase
  Future<void> _deleteImageFromSupabase(String imageUrl) async {
    try {
      final supabase = Supabase.instance.client;

      // استخراج اسم الملف من URL
      String fileName = imageUrl.split('/').last.split('?').first;

      await supabase.storage.from('studenttrainingimages').remove([fileName]);

      print('Image deleted from Supabase: $fileName');
    } catch (e) {
      print('Error deleting image from Supabase: $e');
    }
  }

  /// حذف صورة من القائمة
  Future<void> _removeImage(int index) async {
    // تصفية URLs الفارغة للحصول على القائمة الصحيحة
    List<String> validUrls = imageUrls.where((url) => url.isNotEmpty).toList();
    String imageUrl = validUrls[index];

    // العثور على الفهرس الحقيقي في القائمة الأصلية
    int realIndex = imageUrls.indexOf(imageUrl);

    setState(() {
      if (realIndex != -1) {
        imageUrls.removeAt(realIndex);
      }
    });

    // حذف الصورة من Supabase إذا كان هناك docId (تعديل)
    if (docId != null) {
      await _deleteImageFromSupabase(imageUrl);
    }
  }

  Future<void> _saveDiary() async {
    setState(() {
      isSaving = true;
    });

    try {
      final supabase = Supabase.instance.client;
      List<String> newImageUrls = [];
      List<String> deletedImageUrls = [];

      // 1. حذف الصور المحذوفة من Supabase
      if (docId != null) {
        // احصل على الصور الأصلية من Firestore
        DocumentSnapshot doc =
            await FirebaseFirestore.instance
                .collection('StudentDiary')
                .doc(docId)
                .get();

        if (doc.exists) {
          List<String> originalImages = List<String>.from(
            doc.get('images') ?? [],
          );

          // ابحث عن الصور المحذوفة
          for (String originalUrl in originalImages) {
            if (!imageUrls.contains(originalUrl)) {
              deletedImageUrls.add(originalUrl);
            }
          }

          // حذف الصور من Supabase
          for (String deletedUrl in deletedImageUrls) {
            try {
              // استخراج اسم الملف من URL
              String fileName = deletedUrl.split('/').last.split('?').first;
              await supabase.storage.from('studenttrainingimages').remove([
                fileName,
              ]);
              print('Deleted image from Supabase: $fileName');
            } catch (e) {
              print('Error deleting image from Supabase: $e');
            }
          }
        }
      }

      // 2. ارفع الصور الجديدة فقط
      for (int i = 0; i < selectedImages.length; i++) {
        File imageFile = selectedImages[i];
        String fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

        print('Uploading image: $fileName');

        await supabase.storage
            .from('studenttrainingimages')
            .upload(fileName, imageFile);

        // استخدام getPublicUrl للحصول على URL صحيح
        final imageUrl = supabase.storage
            .from('studenttrainingimages')
            .getPublicUrl(fileName);

        newImageUrls.add(imageUrl);
        print('Image uploaded successfully: $imageUrl');
      }

      // 3. دمج الصور المتبقية مع الجديدة (تصفية URLs الفارغة)
      List<String> validImageUrls =
          imageUrls.where((url) => url.isNotEmpty).toList();
      List<String> allImages = [...validImageUrls, ...newImageUrls];

      // 4. حفظ أو تحديث المستند في StudentDiary
      Map<String, dynamic> diaryData = {
        'studentId': studentId,
        'trainingNotebook': trainingNotebook,
        'trainerEvaluation': trainerEvaluation,
        'benefitRating': benefitRating,
        'supervisorRating': supervisorRating,
        'environmentRating': environmentRating,
        'images': allImages,
        'date': DateTime.now(),
        'lastUpdated': DateTime.now(),
      };

      if (docId != null) {
        await FirebaseFirestore.instance
            .collection('StudentDiary')
            .doc(docId)
            .update(diaryData);
        print('Diary updated successfully');
      } else {
        await FirebaseFirestore.instance
            .collection('StudentDiary')
            .add(diaryData);
        print('New diary created successfully');
      }

      // 5. البحث عن مستند الحضور لليوم الحالي وتحديث البيانات
      try {
        DateTime today = DateTime.now();
        DateTime startOfDay = DateTime(today.year, today.month, today.day);
        DateTime endOfDay = startOfDay.add(Duration(days: 1));

        // البحث عن مستند الحضور لليوم الحالي
        QuerySnapshot attendanceQuery =
            await FirebaseFirestore.instance
                .collection('Attendances')
                .where('Student_ID', isEqualTo: studentId)
                .where(
                  'Date',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
                )
                .where('Date', isLessThan: Timestamp.fromDate(endOfDay))
                .limit(1)
                .get();

        if (attendanceQuery.docs.isNotEmpty) {
          String attendanceDocId = attendanceQuery.docs.first.id;
          Map<String, dynamic> attendanceData = {
            'TrainingNotebook': trainingNotebook,
            'TrainerEvaluation': trainerEvaluation,
            'BenefitRating': benefitRating,
            'SupervisorRating': supervisorRating,
            'EnvironmentRating': environmentRating,
          };

          await FirebaseFirestore.instance
              .collection('Attendances')
              .doc(attendanceDocId)
              .update(attendanceData);
          print('Attendance updated successfully for doc: $attendanceDocId');
        } else {
          print('No attendance document found for today');
        }
      } catch (e) {
        print('Error updating attendance: $e');
      }

      setState(() {
        isSaving = false;
        selectedImages.clear();
        imageUrls = allImages;
      });

      print('Updated imageUrls: ${imageUrls.length} images');

      Get.snackbar(
        'نجاح',
        'تم حفظ التقرير اليومي بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error saving diary: $e');
      setState(() {
        isSaving = false;
      });

      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حفظ التقرير',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.info_outline, color: mainColor),
                SizedBox(width: 8),
                Text(
                  'معلومات التقرير',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• يمكنك تعديل هذا التقرير خلال هذا اليوم فقط',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '• سيتم رفع التقرير النهائي إلى الكلية تلقائياً',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '• تأكد من إضافة جميع المعلومات المطلوبة قبل الحفظ',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'فهمت',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'اختر مصدر الصورة',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt, color: mainColor),
                  title: Text(
                    'التقاط صورة',
                    style: TextStyle(fontFamily: 'Tajawal'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: mainColor),
                  title: Text(
                    'اختيار من المعرض',
                    style: TextStyle(fontFamily: 'Tajawal'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'التقرير اليومي',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text('التقرير اليومي', style: TextStyle(fontFamily: 'Tajawal')),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: mainColor),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // كراسة التدريب
            Container(
              margin: EdgeInsets.only(bottom: 28),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.book, color: mainColor, size: 26),
                      SizedBox(width: 10),
                      Text(
                        'كراسة التدريب',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 1, color: Colors.grey[200], height: 24),
                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: TextEditingController(text: trainingNotebook),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 17,
                        fontFamily: 'Tajawal',
                        height: 2.1,
                        color: Colors.black87,
                        decoration: TextDecoration.none,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ما الذي قمت بدراسته اليوم؟ ...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        trainingNotebook = value;
                      },
                      cursorColor: mainColor,
                    ),
                  ),
                ],
              ),
            ),
            // قسم الصور
            Container(
              margin: EdgeInsets.only(bottom: 28),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.camera_alt, color: mainColor, size: 26),
                      SizedBox(width: 10),
                      Text(
                        'صور التدريب',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 1, color: Colors.grey[200], height: 24),
                  if ((imageUrls.isEmpty ||
                          imageUrls.where((url) => url.isNotEmpty).isEmpty) &&
                      selectedImages.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: 24),
                          Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.grey[300],
                            size: 60,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'لم تقم بإضافة أي صور بعد',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  if (imageUrls.isNotEmpty &&
                      imageUrls.where((url) => url.isNotEmpty).isNotEmpty)
                    Container(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            imageUrls.where((url) => url.isNotEmpty).length,
                        itemBuilder: (context, index) {
                          // تصفية URLs الفارغة
                          List<String> validUrls =
                              imageUrls.where((url) => url.isNotEmpty).toList();
                          String imageUrl = validUrls[index];
                          return Container(
                            margin: EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: FutureBuilder<String>(
                                    future: _getSignedUrl(imageUrl),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                          width: 100,
                                          height: 120,
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    mainColor,
                                                  ),
                                            ),
                                          ),
                                        );
                                      }

                                      if (snapshot.hasError ||
                                          !snapshot.hasData) {
                                        print(
                                          'Error loading image: ${snapshot.error}',
                                        );
                                        return Container(
                                          width: 100,
                                          height: 120,
                                          color: Colors.grey[200],
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.grey[400],
                                                size: 24,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'خطأ في التحميل',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 10,
                                                  fontFamily: 'Tajawal',
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return Image.network(
                                        snapshot.data!,
                                        width: 100,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        headers: {
                                          'Cache-Control': 'no-cache',
                                          'User-Agent': 'AituApp/1.0',
                                        },
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            width: 100,
                                            height: 120,
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(mainColor),
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          print(
                                            'Error displaying image: $error',
                                          );
                                          return Container(
                                            width: 100,
                                            height: 120,
                                            color: Colors.grey[200],
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey[400],
                                                  size: 24,
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'خطأ في العرض',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 10,
                                                    fontFamily: 'Tajawal',
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  if (selectedImages.isNotEmpty)
                    Container(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    selectedImages[index],
                                    width: 100,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedImages.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showImageSourceDialog,
                          icon: Icon(Icons.add_a_photo, size: 20),
                          label: Text(
                            'إضافة صور',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // قسم التقييمات
            Container(
              margin: EdgeInsets.only(bottom: 28),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: mainColor, size: 26),
                      SizedBox(width: 10),
                      Text(
                        'التقييمات',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 1, color: Colors.grey[200], height: 24),
                  // تقييم مدى الاستفادة
                  _buildRatingRow('تقييم مدى الاستفادة', benefitRating, (
                    rating,
                  ) {
                    setState(() {
                      benefitRating = rating;
                    });
                  }),
                  SizedBox(height: 16),
                  _buildRatingRow('تقييم تعامل المشرف', supervisorRating, (
                    rating,
                  ) {
                    setState(() {
                      supervisorRating = rating;
                    });
                  }),
                  SizedBox(height: 16),
                  _buildRatingRow('تقييم بيئة العمل', environmentRating, (
                    rating,
                  ) {
                    setState(() {
                      environmentRating = rating;
                    });
                  }),
                ],
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              height: 56.0,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveDiary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: mainColor.withOpacity(0.2),
                ),
                child: Text(
                  isSaving ? 'جاري الحفظ...' : 'حفظ التقرير',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(
    String label,
    double rating,
    Function(double) onRatingUpdate,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black87,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 12),
        // شريط التقييم بالنجوم
        Slider(
          value: rating,
          min: 0,
          max: 5,
          divisions: 5,
          label: rating.toString(),
          onChanged: (value) => onRatingUpdate(value),
          activeColor: Colors.amber,
        ),
      ],
    );
  }
}
