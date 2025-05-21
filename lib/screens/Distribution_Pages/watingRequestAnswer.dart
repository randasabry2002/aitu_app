import 'dart:async';
import 'package:aitu_app/screens/Distribution_Pages/Distribution_choice.dart';
import 'package:aitu_app/screens/Distribution_Pages/PDFViewerPage.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaitnigReqestAnswer extends StatefulWidget {
  final String factoryID;

  WaitnigReqestAnswer({required this.factoryID});

  @override
  State<WaitnigReqestAnswer> createState() => _WaitnigReqestAnswerState();
}

class _WaitnigReqestAnswerState extends State<WaitnigReqestAnswer> {
  bool? isApproved;
  bool documentExists = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchApprovalStatus();
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchApprovalStatus();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchApprovalStatus() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('Factories')
              .doc(widget.factoryID)
              .get();

      if (!doc.exists) {
        setState(() {
          documentExists = false;
          isApproved = null;
        });
        return;
      }

      setState(() {
        documentExists = true;
        isApproved = doc.get('isApproved');
      });
    } catch (e) {
      print("Error fetching approval status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isApproved == null && documentExists) {
      return _buildScaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _buildScaffold(
      body: Stack(
        children: [
          imageBackground,
          backDark,
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _buildStatusWidget(isApproved, documentExists),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Directionality _buildScaffold({required Widget body}) {
    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0187c4),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text(' Do you want to discard the request?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Return'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('Factories')
                                .doc(widget.factoryID)
                                .delete();
                            Navigator.of(context).pop();
                            Get.offAll(Distribution_choice());
                          },
                          child: Text('Discard Request'),
                        ),
                      ],
                    ),
              );
            },
          ),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.language, color: Colors.white),
              onSelected: (value) {
                if (value == 'en') {
                  Get.updateLocale(Locale('en'));
                } else if (value == 'ar') {
                  Get.updateLocale(Locale('ar'));
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(value: 'en', child: Text('English')),
                    PopupMenuItem(value: 'ar', child: Text('العربية')),
                  ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: body,
      ),
    );
  }

  Widget _buildStatusWidget(bool? isApproved, bool documentExists) {
    if (!documentExists) return _buildRejectedWidget();
    if (isApproved == true) return _buildAcceptedWidget();
    return _buildPendingWidget();
  }

  Widget _buildRejectedWidget() {
    return Column(
      children: [
        Icon(Icons.cancel, color: Colors.red, size: 60),
        SizedBox(height: 20),
        Text(
          "Request Rejected",
          style: TextStyle(
            fontSize: 24,
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontFamily: 'mainFont',
          ),
        ),
        SizedBox(height: 20),
        Text(
          "The request document has been deleted",
          style: TextStyle(
            fontSize: 16,
            color: Colors.red[300],
            fontFamily: 'mainFont',
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptedWidget() {
    return Column(
      children: [
        Icon(
          Icons.check_circle,
          color: const Color.fromARGB(255, 22, 150, 27),
          size: 60,
        ),
        SizedBox(height: 20),
        Text(
          "Request Accepted",
          textAlign: TextAlign.center,

          style: TextStyle(
            fontSize: 24,
            color: const Color.fromARGB(255, 22, 150, 27),
            fontWeight: FontWeight.bold,
            fontFamily: 'mainFont',
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: () {
            Get.to(PDFViewerPage(pdfType: 'nominationCard'));
          },
          icon: Icon(Icons.picture_as_pdf),
          label: Text(
            "View Nomination Card",
            style: TextStyle(fontFamily: 'mainFont'),
            textAlign: TextAlign.center,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingWidget() {
    return Column(
      children: [
        LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(mainColor),
          backgroundColor: Colors.grey[300],
        ),
        SizedBox(height: 20),
        Text(
          "Waiting for Factory Response...",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            color: mainColor,
            fontFamily: 'mainFont',
          ),
        ),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.yellow[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.hourglass_empty, color: Colors.orange),
              SizedBox(width: 10),
              Text(
                "Your request is being reviewed",
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'mainFont',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
