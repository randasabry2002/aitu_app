import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'College_distribution_page.dart';
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
          backgroundColor: Color(0xFF0187c4),
          actions: <Widget>[
            // Language Selector Icon
            PopupMenuButton<String>(
              icon: Icon(
                Icons.language,
                color: Colors.white,
              ),
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
                  PopupMenuItem(
                    value: 'en',
                    child: Text('English'),
                  ),
                  PopupMenuItem(
                    value: 'ar',
                    child: Text('العربية'),
                  ),
                ];
              },
            ),
          ],
        ),
        backgroundColor: Color(0xFF0187c4),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("distribution_choice_text".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final SharedPreferences _prefs = await SharedPreferences.getInstance();
                        await _prefs.setString(
                            "page", "College_distribution_page");
                        // Navigate to next screen
                        Get.to(College_distribution_page());
                      },
                      child: Text(
                        "college".tr,
                        style: TextStyle(
                            color: Color(0xFF0187c4),
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to next screen
                        Get.to(Not_College_distribution_page());
                      },
                      child: Text(
                        "Other".tr,
                        style: TextStyle(
                            color: Color(0xFF0187c4),
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class College_distribution_page {
}
