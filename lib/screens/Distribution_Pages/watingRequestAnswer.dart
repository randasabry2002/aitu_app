import 'package:aitu_app/screens/Distribution_Pages/Not_College_distribution_page.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aitu_app/screens/Distribution_Pages/PDFViewerPage.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaitnigReqestAnswer extends StatelessWidget {
  final String fatoryGovernorate;
  final String factoryName;
  final String factoryLocation;
  final String factoryIndustry;

  const WaitnigReqestAnswer({
    Key? key,
    required this.fatoryGovernorate,
    required this.factoryName,
    required this.factoryLocation,
    required this.factoryIndustry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(0, 1, 134, 196),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text(
                        'هل تريد إلغاء الطلب؟',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 18),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'رجوع',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              color: mainColor,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Get current user email from SharedPreferences
                            final prefs = await SharedPreferences.getInstance();
                            String? email = prefs.getString("email");

                            if (email != null) {
                              // Find and delete the factory request document
                              final querySnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('Factories')
                                      .where('name', isEqualTo: factoryName)
                                      .where(
                                        'address',
                                        isEqualTo: factoryLocation,
                                      )
                                      .where(
                                        'industry',
                                        isEqualTo: factoryIndustry,
                                      )
                                      .where(
                                        'Governorate',
                                        isEqualTo: fatoryGovernorate,
                                      )
                                      .where('type', isEqualTo: 'external')
                                      .limit(1)
                                      .get();

                              if (querySnapshot.docs.isNotEmpty) {
                                await querySnapshot.docs.first.reference
                                    .delete();
                              }
                            }
                            Navigator.of(context).pop();
                            Get.offAll(() => Not_College_distribution_page());
                          },
                          child: const Text(
                            'إلغاء الطلب',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
        ),
        body: Stack(
          children: [
            imageBackground,
            backDark,
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('Factories')
                          .where('name', isEqualTo: factoryName)
                          .where('address', isEqualTo: factoryLocation)
                          .where('industry', isEqualTo: factoryIndustry)
                          .where('Governorate', isEqualTo: fatoryGovernorate)
                          .where('type', isEqualTo: 'external')
                          .limit(1)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: mainColor),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'حدث خطأ أثناء تحميل البيانات.',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildRejectedWidget();
                    }

                    final data =
                        snapshot.data!.docs.first.data()
                            as Map<String, dynamic>;
                    final bool isApproved = data['isApproved'] ?? false;

                    return Container(
                      padding: const EdgeInsets.all(20),
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(52, 0, 0, 0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:
                          isApproved
                              ? _buildAcceptedWidget()
                              : _buildPendingWidget(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      // height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: const Color.fromARGB(52, 0, 0, 0),
        // color: const Color.fromARGB(12, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.cancel, color: Colors.red, size: 60),
          SizedBox(height: 20),
          Text(
            "تم رفض الطلب",
            style: TextStyle(
              fontSize: 24,
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          SizedBox(height: 20),
          Text(
            "تم حذف مستند الطلب",
            style: TextStyle(
              fontSize: 16,
              color: Colors.redAccent,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          color: Color.fromARGB(255, 22, 150, 27),
          size: 60,
        ),
        const SizedBox(height: 20),
        const Text(
          "تم قبول الطلب",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            color: Color.fromARGB(255, 22, 150, 27),
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        const SizedBox(height: 30),
        CreateButton(
          title: const Text(
            'عرض بطاقة الترشيح',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Tajawal',
              fontSize: 16.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          onPressed: () {
            Get.to(() => PDFViewerPage(pdfType: 'nominationCard'));
          },
        ),
      ],
    );
  }

  Widget _buildPendingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(mainColor),
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(height: 20),
        const Text(
          "في انتظار رد الكلية...",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            color: mainColor,
            fontFamily: 'Tajawal',
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.yellow[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.hourglass_empty, color: Colors.orange),
              SizedBox(width: 10),
              Text(
                "جاري مراجعة طلبك",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
