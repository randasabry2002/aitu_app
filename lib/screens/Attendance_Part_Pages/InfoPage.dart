// import 'package:aitu_app/screens/student%20data/enterCode.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: () {
              Get.back();
            },
          ),
          backgroundColor: const Color.fromARGB(0, 1, 134, 196),
          centerTitle: true,
          title: Text(
            'instructions'.tr,
            style: TextStyle(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
              fontSize: 28,
            ),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('Instructions').snapshots(),
            builder: (context, snapshot) {
              // Debug information
              print('Connection State: ${snapshot.connectionState}');
              print('Has Error: ${snapshot.hasError}');
              print('Has Data: ${snapshot.hasData}');
              if (snapshot.hasData) {
                print('Number of documents: ${snapshot.data!.docs.length}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'جاري تحميل التعليمات...',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        "❌ حدث خطأ أثناء تحميل البيانات",
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: TextStyle(fontSize: 14, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey, size: 48),
                      SizedBox(height: 16),
                      Text(
                        "لا توجد تعليمات متاحة حالياً",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              List<String> instructions =
                  snapshot.data!.docs
                      .map((doc) => doc['Content'].toString())
                      .toList();

              return ListView.builder(
                itemCount: instructions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${index + 1}. ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: mainColor,
                            ),
                          ),
                          TextSpan(
                            text: instructions[index],
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
