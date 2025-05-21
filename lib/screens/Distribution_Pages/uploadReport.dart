import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:flutter/material.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UplooadRerport extends StatefulWidget {
  const UplooadRerport({super.key});

  @override
  State<UplooadRerport> createState() => _UplooadRerportState();
}

class _UplooadRerportState extends State<UplooadRerport> {
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _selectedImage = pickedImage;
        });
      }
    } catch (e) {
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Error picking image: $e'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0187c4),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Get.back();
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'upload_report'.tr,
              style: TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'mainFont',
              ),
            ),
            SizedBox(height: 60),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.4,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 250, 253, 255),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _selectedImage != null ? mainColor : Colors.grey, width: 2),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file, size: 60, color: mainColor),
                          SizedBox(height: 16),
                          Text(
                            'tap_to_upload_report'.tr,
                            style: TextStyle(color: Colors.grey[700], fontSize: 16),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 20),
            Visibility(
              visible: _selectedImage != null,
              child: CreateButton(
                onPressed: (){},
                title: Text(
                  'send'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'mainFont',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
      
          ],
        ),
      ),
    );
  }
}
