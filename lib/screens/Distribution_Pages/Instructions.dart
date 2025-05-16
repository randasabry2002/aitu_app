import 'package:aitu_app/screens/student%20data/enterCode.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Distribution_choice.dart';

class Instructions extends StatefulWidget {
  const Instructions({super.key});

  @override
  State<Instructions> createState() => _InstructionsState();
}

class _InstructionsState extends State<Instructions> {
  bool _isChecked = false;

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
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.offAll(EnterStudentCode()),
          ),
          backgroundColor: Color(0xFF0187c4),
          title: Center(
            child: Text(
              'instructions'.tr,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: Stack(
          children: [
            Image(
              image: backgroundImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // ✅ StreamBuilder لجلب التعليمات من Firestore
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('Instructions')
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "❌ حدث خطأ أثناء تحميل البيانات",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        // استخراج البيانات من Firestore
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
                                      text: "${index + 1}. ", // ترقيم التعليمات
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: secondaryColor,
                                      ),
                                    ),
                                    // نص التعليمات
                                    
                                    TextSpan(
                                      text: instructions[index],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: secondaryColor,
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

                  // ✅ Checkbox للموافقة على التعليمات
                  Row(
                    children: [
                      Transform.scale(
                        scale: 1.3,
                        child: Checkbox(
                          value: _isChecked,
                          checkColor: Colors.white,
                          fillColor: MaterialStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(MaterialState.selected)) {
                              return secondaryColor;
                            }
                            return Colors.transparent;
                          }),
                          side: BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _isChecked = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "I agree to the instructions".tr,
                          style: TextStyle(fontSize: 20, color: const Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // زر الانتقال
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: CreateButton(
                      onPressed: () {
                        if (_isChecked) {
                          Get.off(Distribution_choice());
                        }
                      },
                      title: Text(
        'Next'.tr,
        style: TextStyle(
          fontSize: 24,
          color: mainColor,
          fontWeight: FontWeight.bold,
          fontFamily: 'mainFont',
        ),
      ), // Key for "Sign Up",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
