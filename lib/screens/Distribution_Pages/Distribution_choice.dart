import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Not_College_distribution_page.dart';

class Distribution_choice extends StatefulWidget {
  const Distribution_choice({super.key});

  @override
  State<Distribution_choice> createState() => _Distribution_choiceState();
}

class _Distribution_choiceState extends State<Distribution_choice> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
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
            Image(
              image: backgroundImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "distribution_choice_text".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: mainColor,
                          fontFamily: 'mainFont',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: CreateButton(
                            title: Text(
                              'College'.tr,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'mainFont',
                              ),
                            ),
                            onPressed: () async {
                              final SharedPreferences _prefs =
                                  await SharedPreferences.getInstance();
                              await _prefs.setString(
                                "page",
                                "College_distribution_page",
                              );
                              Get.to(College_distribution_page());
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: CreateButton(
                            title: Text(
                              'Other'.tr,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'mainFont',
                              ),
                            ), // Key for "Sign Up",
                            onPressed: () {
                              // Navigate to next screen
                              Get.to(Not_College_distribution_page());
                            },
                          ),
                        ),
                      ],
                    ),
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

class College_distribution_page {}
