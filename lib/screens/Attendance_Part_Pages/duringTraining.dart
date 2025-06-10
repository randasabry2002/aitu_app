import 'dart:async';
import 'dart:math';
import 'package:aitu_app/screens/Attendance_Part_Pages/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'ExitFactory.dart';

class DuringTraining extends StatefulWidget {
  const DuringTraining({super.key});

  @override
  State<DuringTraining> createState() => _DuringTrainingState();
}

class _DuringTrainingState extends State<DuringTraining> {
  String trainingNotebook = "";
  Duration trainingDuration = Duration.zero;
  Timer? _timer;
  DateTime? startTime;
  double benefitRating = 0;
  double supervisorRating = 0;
  double environmentRating = 0;
  late String attendanceId;
  late final SharedPreferences _prefs;
  String currentQuote = "";

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
    _startTimer();
    _setRandomQuote();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (startTime == null) {
      startTime = DateTime.now();
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (startTime != null) {
        setState(() {
          trainingDuration = DateTime.now().difference(startTime!);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  getSharedPref() async {
    _prefs = await SharedPreferences.getInstance();
    attendanceId = (await _prefs.getString("attendanceId"))!;
  }

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
          benefitRating = (attendanceDoc.get('BenefitRating') ?? 0).toDouble();
          supervisorRating =
              (attendanceDoc.get('SupervisorRating') ?? 0).toDouble();
          environmentRating =
              (attendanceDoc.get('EnvironmentRating') ?? 0).toDouble();

          int existingDuration = attendanceDoc.get('TrainingDuration') ?? 0;
          if (existingDuration > 0) {
            trainingDuration = Duration(seconds: existingDuration);
            startTime = DateTime.now().subtract(trainingDuration);
          }
        });
      }
    } catch (e) {
      print("Error loading existing data: $e");
    }
  }

  Future<void> _saveAllData() async {
    try {
      await FirebaseFirestore.instance
          .collection("Attendances")
          .doc(attendanceId)
          .update({
            "TrainingNotebook": trainingNotebook,
            "BenefitRating": benefitRating,
            "SupervisorRating": supervisorRating,
            "EnvironmentRating": environmentRating,
            "TrainingDuration": trainingDuration.inSeconds,
          });
    } catch (e) {
      print("Error saving data: $e");
    }
  }

  void _setRandomQuote() {
    final random = Random();
    setState(() {
      currentQuote =
          motivationalQuotes[random.nextInt(motivationalQuotes.length)];
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: WillPopScope(
        onWillPop: _showBackConfirmationDialog,
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
              'خلال التدريب',
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),

                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue,
                          size: 32,
                        ),
                        SizedBox(height: 16),
                        Text(
                          currentQuote,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

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
                                  Icons.timer,
                                  color: mainColor,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'مدة التدريب',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14.0,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _formatDuration(trainingDuration),
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 24.0,
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

                  SizedBox(height: 20),

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
                                  Icons.book,
                                  color: mainColor,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                'كراسة التدريب',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14.0,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          TextField(
                            maxLines: 6,
                            decoration: InputDecoration(
                              hintText: 'اكتب ملاحظاتك في كراسة التدريب...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontFamily: 'Tajawal',
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: mainColor.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: mainColor),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                trainingNotebook = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

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
                                  Icons.star,
                                  color: mainColor,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                'التقييمات',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14.0,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildRatingRow(
                            "تقييم مدى الاستفادة",
                            benefitRating,
                            (rating) {
                              setState(() {
                                benefitRating = rating;
                              });
                            },
                          ),
                          SizedBox(height: 12),
                          _buildRatingRow(
                            "تقييم تعامل المشرف",
                            supervisorRating,
                            (rating) {
                              setState(() {
                                supervisorRating = rating;
                              });
                            },
                          ),
                          SizedBox(height: 12),
                          _buildRatingRow(
                            "تقييم بيئة العمل",
                            environmentRating,
                            (rating) {
                              setState(() {
                                environmentRating = rating;
                              });
                            },
                          ),
                        ],
                        
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  SizedBox(
                    height: 60.0,
                    width: double.infinity,
                    child: CreateButton(
                      onPressed: () async {
                        await _saveAllData();
                        Get.to(() => ExitFactory(attendanceId: attendanceId));
                      },
                      title: Center(
                        child: Text(
                          'إنهاء اليوم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
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
            ),
          ),
        ),
        SizedBox(width: 8),
        RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          itemCount: 5,
          itemSize: 30.0,
          itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: onRatingUpdate,
        ),
      ],
    );
  }
}
