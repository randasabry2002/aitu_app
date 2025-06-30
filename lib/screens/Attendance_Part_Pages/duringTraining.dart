import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:aitu_app/screens/Attendance_Part_Pages/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DuringTraining extends StatefulWidget {
  const DuringTraining({super.key});

  @override
  State<DuringTraining> createState() => _DuringTrainingState();
}

class _DuringTrainingState extends State<DuringTraining> {
  String trainingNotebook = "";
  String trainerEvaluation = "";
  double benefitRating = 0;
  double supervisorRating = 0;
  double environmentRating = 0;
  late String attendanceId;
  late final SharedPreferences _prefs;
  String currentQuote = "";
  List<File> selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;
  TextEditingController notebookController = TextEditingController();

  // Location variables
  late var latitude;
  late var longitude;
  bool show_spinkit = false;
  bool show_done_location = false;
  bool isLocationVerified = false;
  LatLng latLng = LatLng(45.521563, -122.677433);
  bool spinkitVisable_exit = false;
  Completer<GoogleMapController> _controller = Completer();

  final List<String> motivationalQuotes = [
    "كل يوم جديد هو فرصة للتعلم والنمو",
    "النجاح هو رحلة وليس وجهة",
    "التدريب العملي هو أفضل طريقة للتعلم",
    "الخبرة هي أفضل معلم",
    "كل خطوة تقودك إلى النجاح",
    "التعلم المستمر هو مفتاح التطور",
    "الفرص تأتي لمن يبحث عنها",
    "النجاح يبدأ بالخطوة الأولى",
    "التحديات تصنع الخبرة",
    "كل يوم هو فرصة جديدة للتميز",
  ];

  @override
  void initState() {
    super.initState();
    getSharedPref();
    _loadExistingData();
    _setRandomQuote();
  }

  /// تهيئة البيانات المشتركة - جلب معرف الحضور
  getSharedPref() async {
    _prefs = await SharedPreferences.getInstance();
    attendanceId = (await _prefs.getString("attendanceId"))!;
  }

  /// تحميل البيانات الموجودة من Firestore
  Future<void> _loadExistingData() async {
    try {
      DocumentSnapshot attendanceDoc =
          await FirebaseFirestore.instance
              .collection("Attendances")
              .doc(attendanceId)
              .get();

      if (attendanceDoc.exists) {
        setState(() {
          trainingNotebook = attendanceDoc.get('TrainingNotebook') ?? '';
          trainerEvaluation = attendanceDoc.get('TrainerEvaluation') ?? '';
          benefitRating = (attendanceDoc.get('BenefitRating') ?? 0).toDouble();
          supervisorRating =
              (attendanceDoc.get('SupervisorRating') ?? 0).toDouble();
          environmentRating =
              (attendanceDoc.get('EnvironmentRating') ?? 0).toDouble();
        });

        notebookController.text = trainingNotebook;
      }
    } catch (e) {
      print("Error loading existing data: $e");
    }
  }

  /// حفظ جميع بيانات التدريب في Firestore
  Future<void> _saveAllData() async {
    try {
      await FirebaseFirestore.instance
          .collection("Attendances")
          .doc(attendanceId)
          .update({
            "TrainingNotebook": trainingNotebook,
            "TrainerEvaluation": trainerEvaluation,
            "BenefitRating": benefitRating,
            "SupervisorRating": supervisorRating,
            "EnvironmentRating": environmentRating,
          });
    } catch (e) {
      print("Error saving data: $e");
    }
  }

  /// تعيين جملة تحفيزية عشوائية
  void _setRandomQuote() {
    final random = Random();
    setState(() {
      currentQuote =
          motivationalQuotes[random.nextInt(motivationalQuotes.length)];
    });
  }

  /// عرض نافذة معلومات كراسة التدريب
  void _showEditNotebookModal() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'معلومات كراسة التدريب',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'يمكنك تعديل مدخلات كراسة التدريب الخاصة بك فقط خلال نفس اليوم الذي تم تقديمها فيه. بعد ذلك، يصبح المحتوى للقراءة فقط.',
              style: TextStyle(fontFamily: 'Tajawal'),
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

  /// اختيار صورة من المعرض
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء اختيار الصورة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    }
  }

  /// التقاط صورة بالكاميرا
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      print("Error taking photo: $e");
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء التقاط الصورة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    }
  }

  /// رفع الصور إلى Supabase وحفظ روابطها في Firestore
  Future<void> _uploadImages() async {
    if (selectedImages.isEmpty) return;

    print('عدد الصور المحددة للرفع: ${selectedImages.length}');
    for (int i = 0; i < selectedImages.length; i++) {
      print('مسار الصورة رقم $i: \'${selectedImages[i].path}\'');
    }

    setState(() {
      isUploading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      String studentId = await _prefs.getString("studentId") ?? "";

      for (int i = 0; i < selectedImages.length; i++) {
        File imageFile = selectedImages[i];
        String fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        print('---\nبدء رفع الصورة رقم $i');
        print('اسم الملف: $fileName');
        print('المسار: ${imageFile.path}');

        // رفع الصورة إلى Supabase بدون headers
        await supabase.storage
            .from('studenttrainingimages')
            .upload(fileName, imageFile);
        print('تم رفع الصورة رقم $i بنجاح');

        // الحصول على الرابط العام
        final imageUrl = supabase.storage
            .from('studenttrainingimages')
            .getPublicUrl(fileName);
        print('رابط الصورة رقم $i: $imageUrl');

        // إنشاء مستند في Firestore
        await FirebaseFirestore.instance
            .collection('studenttrainingimages')
            .add({
              'imageUrl': imageUrl,
              'uploadDate': FieldValue.serverTimestamp(),
              'studentId': studentId,
              'trainingId': attendanceId,
              'fileName': fileName,
            });
        print('تم إضافة بيانات الصورة رقم $i إلى Firestore');
      }

      setState(() {
        selectedImages.clear();
      });

      print('تم رفع جميع الصور بنجاح!');
      Get.snackbar(
        'نجح',
        'تم رفع الصور بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e, stack) {
      print("Error uploading images: $e");
      print("Stack trace: $stack");
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء رفع الصور: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  /// عرض نافذة اختيار مصدر الصورة
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

  /// عرض نافذة تأكيد العودة للخلف
  Future<bool> _showBackConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(
                  'تأكيد',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'هل أنت متأكد من الغاء حضورك اليوم؟ لن يتم حفظ البيانات.',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'لا',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection("Attendances")
                            .doc(attendanceId)
                            .delete();
                        await _prefs.setString("attendanceId", 'null');

                        Navigator.pop(context, true);
                        Get.offAll(() => HomeScreen());
                      } catch (e) {
                        print("Error deleting attendance: $e");
                        Get.snackbar(
                          'خطأ',
                          'حدث خطأ أثناء الغاء الحضور',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                          duration: Duration(seconds: 3),
                        );
                        Navigator.pop(context, false);
                      }
                    },
                    child: Text(
                      'نعم',
                      style: TextStyle(fontFamily: 'Tajawal', color: mainColor),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  /// تهيئة خريطة Google Maps
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  /// الحصول على الموقع الحالي للمستخدم
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // التحقق من تفعيل خدمة الموقع
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'تنبيه',
        'يرجى تفعيل خدمة الموقع',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
      return;
    }

    // التحقق من صلاحيات الموقع
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'تنبيه',
          'يرجى السماح بالوصول إلى الموقع',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'تنبيه',
        'يرجى السماح بالوصول إلى الموقع من إعدادات التطبيق',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
      return;
    }

    // فحص mounted قبل setState
    if (mounted) {
      setState(() {
        show_spinkit = true;
        show_done_location = false;
        isLocationVerified = false;
      });
    }

    try {
      // الحصول على الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // فحص mounted قبل setState
      if (mounted) {
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
          latLng = LatLng(latitude, longitude);
          show_spinkit = false;
          show_done_location = true;
          isLocationVerified = true;
        });
      }

      Get.snackbar(
        'نجاح',
        'تم تحديد الموقع بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print("Failed to get location: $e");
      Get.snackbar(
        'تنبيه',
        'حدث خطأ أثناء تحديد الموقع',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );

      // فحص mounted قبل setState
      if (mounted) {
        setState(() {
          show_spinkit = false;
          isLocationVerified = false;
        });
      }
    }
  }

  /// عرض نافذة إنهاء اليوم
  /// تعرض نافذة dialog تحتوي على:
  /// - زر تحديد الموقع
  /// - عرض الموقع على الخريطة
  /// - زر إنهاء اليوم النهائي
  /// النافذة لا يمكن إغلاقها إلا بعد تحديد الموقع أو الضغط على زر الإغلاق
  void _showExitDialog() {
    // إنشاء Completer جديد لكل نافذة dialog
    Completer<GoogleMapController> dialogController = Completer();

    // متغيرات محلية لإدارة حالة النافذة
    bool dialogShowSpinkit = false;
    bool dialogShowDoneLocation = false;
    bool dialogIsLocationVerified = false;
    bool dialogSpinkitVisibleExit = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    width: double.maxFinite,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.85,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // رأس النافذة المحسن
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [mainColor, mainColor.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.exit_to_app,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'إنهاء اليوم التدريبي',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontFamily: 'Tajawal',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'تحديد الموقع وإتمام اليوم',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14.0,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // محتوى النافذة المحسن
                        Flexible(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // رسالة ترحيبية
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.blue.shade700,
                                        size: 24,
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          'لإتمام اليوم التدريبي، يرجى تحديد موقعك الحالي',
                                          style: TextStyle(
                                            color: Colors.blue.shade800,
                                            fontSize: 16.0,
                                            fontFamily: 'Tajawal',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 24),

                                // زر تحديد الموقع المحسن
                                Container(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      try {
                                        setDialogState(() {
                                          dialogShowSpinkit = true;
                                          dialogShowDoneLocation = false;
                                          dialogIsLocationVerified = false;
                                        });

                                        // استدعاء دالة تحديد الموقع مع إدارة أفضل للحالة
                                        await _getLocationForDialog(setDialogState, (
                                          lat,
                                          lng,
                                        ) {
                                          print(
                                            "Location callback received - Lat: $lat, Lng: $lng",
                                          );

                                          // تحديث المتغيرات العامة للصفحة أولاً
                                          if (mounted) {
                                            setState(() {
                                              this.latitude = lat;
                                              this.longitude = lng;
                                              this.latLng = LatLng(lat, lng);
                                              this.show_spinkit = false;
                                              this.show_done_location = true;
                                              this.isLocationVerified = true;
                                            });

                                            // طباعة تأكيد تحديث المتغيرات
                                            print(
                                              "Location updated - Lat: $lat, Lng: $lng, Verified: ${this.isLocationVerified}",
                                            );
                                          }

                                          // ثم تحديث متغيرات Dialog
                                          setDialogState(() {
                                            dialogShowSpinkit = false;
                                            dialogShowDoneLocation = true;
                                            dialogIsLocationVerified = true;
                                          });
                                        });
                                      } catch (e) {
                                        setDialogState(() {
                                          dialogShowSpinkit = false;
                                          dialogIsLocationVerified = false;
                                        });
                                        Get.snackbar(
                                          'خطأ',
                                          'حدث خطأ أثناء تحديد الموقع',
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                          snackPosition: SnackPosition.TOP,
                                          duration: Duration(seconds: 3),
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      dialogShowDoneLocation
                                          ? Icons.refresh
                                          : Icons.location_on,
                                      size: 24,
                                    ),
                                    label: Text(
                                      dialogShowDoneLocation
                                          ? "تحديد الموقع مرة أخرى"
                                          : "تحديد موقعي الحالي",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'Tajawal',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          dialogShowDoneLocation
                                              ? Colors.orange
                                              : mainColor,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 2,
                                    ),
                                  ),
                                ),

                                // مؤشر تحميل تحديد الموقع
                                if (dialogShowSpinkit) ...[
                                  SizedBox(height: 24),
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        SpinKitWave(
                                          color: mainColor,
                                          size: 30.0,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'جاري تحديد موقعك...',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 16.0,
                                            fontFamily: 'Tajawal',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                // عرض معلومات الموقع بعد تحديده
                                if (dialogShowDoneLocation &&
                                    dialogIsLocationVerified) ...[
                                  SizedBox(height: 24),

                                  // بطاقة نجاح تحديد الموقع
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.green.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.green.shade700,
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
                                                'تم تحديد الموقع بنجاح',
                                                style: TextStyle(
                                                  color: Colors.green.shade800,
                                                  fontSize: 16.0,
                                                  fontFamily: 'Tajawal',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'يمكنك الآن إنهاء اليوم التدريبي',
                                                style: TextStyle(
                                                  color: Colors.green.shade700,
                                                  fontSize: 14.0,
                                                  fontFamily: 'Tajawal',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 24),

                                  // خريطة Google Maps المحسنة
                                  Container(
                                    height: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: mainColor.withOpacity(0.3),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: GoogleMap(
                                        onMapCreated: dialogController.complete,
                                        initialCameraPosition: CameraPosition(
                                          target: latLng,
                                          zoom: 18.0,
                                        ),
                                        markers: {
                                          Marker(
                                            markerId: MarkerId(
                                              'current_location',
                                            ),
                                            position: latLng,
                                            infoWindow: InfoWindow(
                                              title: 'موقعك الحالي',
                                              snippet: 'تم تحديد الموقع بنجاح',
                                            ),
                                          ),
                                        },
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 24),

                                  // زر إنهاء اليوم النهائي المحسن
                                  if (!dialogSpinkitVisibleExit)
                                    Container(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          try {
                                            // طباعة تأكيد القيم قبل استدعاء الدالة
                                            print(
                                              "End Day button pressed - Lat: $latitude, Lng: $longitude, Verified: $dialogIsLocationVerified",
                                            );

                                            setDialogState(() {
                                              dialogSpinkitVisibleExit = true;
                                            });

                                            // استخدام الدالة الجديدة مع بيانات الموقع المحددة
                                            await _completeDayWithLocation(
                                              this.latitude,
                                              this.longitude,
                                            );
                                            Navigator.pop(
                                              context,
                                            ); // إغلاق النافذة
                                          } catch (e) {
                                            setDialogState(() {
                                              dialogSpinkitVisibleExit = false;
                                            });
                                            Get.snackbar(
                                              'تنبيه',
                                              'حدث خطأ أثناء إنهاء اليوم',
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                              snackPosition: SnackPosition.TOP,
                                              duration: Duration(seconds: 3),
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.done_all, size: 24),
                                        label: Text(
                                          'إنهاء اليوم نهائياً',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: 'Tajawal',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          elevation: 3,
                                        ),
                                      ),
                                    ),

                                  // مؤشر تحميل إنهاء اليوم
                                  if (dialogSpinkitVisibleExit)
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          SpinKitCircle(
                                            color: mainColor,
                                            size: 40.0,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'جاري إنهاء اليوم...',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 16.0,
                                              fontFamily: 'Tajawal',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  /// دالة مساعدة لتحديد الموقع من داخل Dialog
  Future<void> _getLocationForDialog(
    Function setDialogState,
    Function(double, double) onLocationReceived,
  ) async {
    bool serviceEnabled;
    LocationPermission permission;

    // التحقق من تفعيل خدمة الموقع
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service is disabled');
    }

    // التحقق من صلاحيات الموقع
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied forever');
    }

    // الحصول على الموقع الحالي
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // إرجاع الإحداثيات
    onLocationReceived(position.latitude, position.longitude);
  }

  /// إنهاء اليوم مع بيانات موقع محددة
  Future<void> _completeDayWithLocation(double lat, double lng) async {
    try {
      // طباعة تأكيد استلام بيانات الموقع
      print("_completeDayWithLocation called with Lat: $lat, Lng: $lng");

      setState(() {
        spinkitVisable_exit = true;
      });

      // حفظ جميع بيانات التدريب
      await _saveAllData();

      // تحديث بيانات الحضور مع معلومات الخروج
      await FirebaseFirestore.instance
          .collection("Attendances")
          .doc(attendanceId)
          .update({
            "ExitingTime": DateTime.now(),
            "ExitingLocation": GeoPoint(lat, lng),
            "Status": "Completed",
          });

      await _prefs.setString("attendanceId", 'null');

      Get.snackbar(
        'نجاح',
        'تم إنهاء اليوم التدريبي بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Get.offAll(() => HomeScreen());
      });
    } catch (e) {
      print("Error completing day: $e");
      Get.snackbar(
        'تنبيه',
        'حدث خطأ أثناء إنهاء اليوم',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
      setState(() {
        spinkitVisable_exit = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: _showBackConfirmationDialog,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black87,
              ),
              onPressed: () async {
                bool? shouldLeave = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text(
                          'تحذير',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        content: Text(
                          'هل أنت متأكد أنك تريد العودة إلى الصفحة الرئيسية؟ قد تفقد تقدمك الحالي.',
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'تأكيد',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                );
                if (shouldLeave == true) {
                  Get.offAll(() => HomeScreen());
                }
              },
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'خلال التدريب',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          backgroundColor: Colors.grey.shade50,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: mainColor,
                          size: 32,
                        ),
                        SizedBox(height: 16),
                        Text(
                          currentQuote,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16.0,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.book, color: mainColor, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'كراسة التدريب',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18.0,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: _showEditNotebookModal,
                              icon: Icon(
                                Icons.info_outline,
                                color: mainColor,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // زيادة المسافة بين الأسطر
                              double lineHeight = 34.0; // ارتفاع السطر أكبر
                              int lines =
                                  (constraints.maxHeight / lineHeight).floor();

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // خطوط أفقية خفيفة كخلفية
                                    CustomPaint(
                                      painter: _NotebookLinesPainter(
                                        lineHeight: lineHeight,
                                        lineColor: Colors.grey.shade200,
                                      ),
                                    ),
                                    // حقل الكتابة مع محاذاة السطور
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 10,
                                      ),
                                      child: Scrollbar(
                                        radius: const Radius.circular(8),
                                        thickness: 4,
                                        child: TextField(
                                          controller: notebookController,
                                          maxLines: null,
                                          expands: true,
                                          textAlignVertical:
                                              TextAlignVertical.top,
                                          textDirection: TextDirection.rtl,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Tajawal',
                                            height: 2.1, // تقريباً 34/16
                                            color: Colors.black87,
                                            decoration: TextDecoration.none,
                                          ),
                                          decoration: InputDecoration(
                                            hintText:
                                                'ما الذي قمت بدراسته اليوم؟ ...',
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
                                            setState(() {
                                              trainingNotebook = value;
                                            });
                                          },
                                          cursorColor: mainColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 24),

                        // Container(
                        //   width: double.infinity,
                        //   padding: EdgeInsets.all(24),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(16),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: Colors.black.withOpacity(0.05),
                        //         blurRadius: 10,
                        //         offset: Offset(0, 4),
                        //       ),
                        //     ],
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Row(
                        //         children: [
                        //           Icon(Icons.rate_review, color: mainColor, size: 24),
                        //           SizedBox(width: 12),
                        //           Text(
                        //             'تقييم المدرب',
                        //             style: TextStyle(
                        //               color: Colors.black87,
                        //               fontSize: 18.0,
                        //               fontFamily: 'Tajawal',
                        //               fontWeight: FontWeight.bold,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       SizedBox(height: 16),
                        //       Container(
                        //         decoration: BoxDecoration(
                        //           color: Colors.grey.shade50,
                        //           borderRadius: BorderRadius.circular(12),
                        //           border: Border.all(color: Colors.grey.shade200),
                        //         ),
                        //         child: Padding(
                        //           padding: EdgeInsets.all(16),
                        //           child: TextField(
                        //             maxLines: 4,
                        //             textDirection: TextDirection.rtl,
                        //             style: TextStyle(
                        //               fontSize: 16,
                        //               fontFamily: 'Tajawal',
                        //               height: 1.5,
                        //             ),
                        //             decoration: InputDecoration(
                        //               hintText: 'اكتب تقييم المدرب وملاحظاته هنا...',
                        //               hintStyle: TextStyle(
                        //                 color: Colors.grey.shade400,
                        //                 fontFamily: 'Tajawal',
                        //                 fontSize: 16,
                        //               ),
                        //               border: InputBorder.none,
                        //               contentPadding: EdgeInsets.zero,
                        //             ),
                        //             onChanged: (value) {
                        //               setState(() {
                        //                 trainerEvaluation = value;
                        //               });
                        //             },
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        SizedBox(height: 24),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: mainColor,
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'رفع صور التدريب',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18.0,
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),

                              if (selectedImages.isNotEmpty) ...[
                                Container(
                                  height: 120,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: selectedImages.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: EdgeInsets.only(left: 8),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                                    selectedImages.removeAt(
                                                      index,
                                                    );
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
                              ],

                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          isUploading
                                              ? null
                                              : _showImageSourceDialog,
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
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                  if (selectedImages.isNotEmpty) ...[
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            isUploading ? null : _uploadImages,
                                        icon:
                                            isUploading
                                                ? SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                                : Icon(
                                                  Icons.cloud_upload,
                                                  size: 20,
                                                ),
                                        label: Text(
                                          isUploading
                                              ? 'جاري الرفع...'
                                              : 'رفع الصور',
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // قسم التقييمات الجديد
                        SizedBox(height: 24),
                        Divider(thickness: 1.2, color: Colors.grey.shade300),
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            'التقييمات',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18.0,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Divider(thickness: 1.2, color: Colors.grey.shade300),
                        SizedBox(height: 20),

                        // تقييم مدى الاستفادة
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "تقييم مدى الاستفادة",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black87,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildRatingRow("", benefitRating, (rating) {
                              setState(() {
                                benefitRating = rating;
                              });
                            }),
                          ],
                        ),
                        SizedBox(height: 12),
                        Divider(thickness: 1, color: Colors.grey.shade200),
                        SizedBox(height: 12),

                        // تقييم تعامل المشرف
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "تقييم تعامل المشرف",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black87,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildRatingRow("", supervisorRating, (rating) {
                              setState(() {
                                supervisorRating = rating;
                              });
                            }),
                          ],
                        ),
                        SizedBox(height: 12),
                        Divider(thickness: 1, color: Colors.grey.shade200),
                        SizedBox(height: 12),

                        // تقييم بيئة العمل
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "تقييم بيئة العمل",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black87,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildRatingRow("", environmentRating, (rating) {
                              setState(() {
                                environmentRating = rating;
                              });
                            }),
                          ],
                        ),

                        SizedBox(height: 32),

                        SizedBox(
                          height: 56.0,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _showExitDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'إنهاء اليوم',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// بناء صف التقييم بالنجوم
  /// [label] - عنوان التقييم
  /// [rating] - قيمة التقييم الحالية
  /// [onRatingUpdate] - دالة تحديث التقييم
  Widget _buildRatingRow(
    String label,
    double rating,
    Function(double) onRatingUpdate,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // عنوان التقييم
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
        RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          itemCount: 5,
          itemSize: 32.0,
          itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: onRatingUpdate,
        ),
      ],
    );
  }
}

class _NotebookLinesPainter extends CustomPainter {
  final double lineHeight;
  final Color lineColor;

  _NotebookLinesPainter({required this.lineHeight, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += lineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
