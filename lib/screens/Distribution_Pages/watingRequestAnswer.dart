import 'package:aitu_app/screens/Distribution_Pages/Distribution_choice.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaitnigReqestAnswer extends StatefulWidget {
  // const WaitnigReqestAnswer({super.key});

  @override
  State<WaitnigReqestAnswer> createState() => _WaitnigReqestAnswerState();
  final String factoryID;
  WaitnigReqestAnswer({required this.factoryID});
}

class _WaitnigReqestAnswerState extends State<WaitnigReqestAnswer> {
  bool? isApproved;

  DocumentSnapshot? factoryDoc;

  Future<void> fetchGovernorates() async {
    // Fetch the factory document by ID
    factoryDoc =
        await FirebaseFirestore.instance
            .collection("Factories")
            .doc(widget.factoryID)
            .get();
  }

  Future<void> isApprovedRequest() async {}

  @override
  void initState() {
    super.initState();
    // addFactories();
    fetchGovernorates();
    isApprovedRequest();
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
          backgroundColor: Color(0xFF0187c4),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Get.offAll(
                Distribution_choice(),
              );
            },
          ),
          actions: <Widget>[
            // Language Selector Icon
            PopupMenuButton<String>(
              icon: Icon(Icons.language, color: Colors.white),
              onSelected: (value) {
                // Update the app's locale based on the selection
                if (value == 'en') {
                  Get.updateLocale(Locale('en'));
                } else if (value == 'ar') {
                  Get.updateLocale(Locale('ar'));
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(value: 'en', child: Text('English')),
                  PopupMenuItem(value: 'ar', child: Text('العربية')),
                ];
              },
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: Stack(
          children: [
            // Background image
            imageBackground,
            // Background color
            backDark,

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "waiting request \nanswer........",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontFamily: 'mainFont',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Add any other widgets you want to display here
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
