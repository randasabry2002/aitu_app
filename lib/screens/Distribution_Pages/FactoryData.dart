import 'package:aitu_app/shared/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FactoryData extends StatefulWidget {
  final String? selectedFactory;
  FactoryData({super.key, this.selectedFactory});

  @override
  State<FactoryData> createState() => _FactoryDataState();
}

class _FactoryDataState extends State<FactoryData> {
  Map<String, dynamic>? factoryData;
  bool isLoading = true;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    fetchFactoryData();
  }

  Future<void> fetchFactoryData() async {
    if (widget.selectedFactory == null) return;

    try {
      var querySnapshot =
          await FirebaseFirestore.instance
              .collection('Factories')
              .where('name', isEqualTo: widget.selectedFactory)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          factoryData = querySnapshot.docs.first.data();
          isLoading = false;
        });
      } else {
        setState(() {
          factoryData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching factory data: $e");
      setState(() {
        factoryData = null;
        isLoading = false;
      });
    }
  }

  // Future<void> _selectDate(BuildContext context, bool isStartDate) async {
  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime(2030),
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       if (isStartDate) {
  //         startDate = picked;
  //       } else {
  //         endDate = picked;
  //       }
  //     });
  //   }
  // }

  // void _submitData() {
  //   if (startDate == null || endDate == null) {
  //     Get.snackbar("خطأ", "يجب اختيار تواريخ التدريب!", backgroundColor: Colors.red, colorText: Colors.white);
  //     return;
  //   }

  //   print("Factory: ${widget.selectedFactory}");
  //   print("Start Date: $startDate");
  //   print("End Date: $endDate");

  //   Get.snackbar("نجاح", "تم إرسال البيانات بنجاح!", backgroundColor: Colors.green, colorText: Colors.white);
  // }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: mainColor,
          centerTitle: true,
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : factoryData == null
                ? Center(
                  child: Text(
                    "لم يتم العثور على المصنع",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                )
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 40),
                      Text(
                        "factory_data".tr,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'mainFont',
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      _infoRow(
                        icon: Icons.factory,
                        label: 'factory_name'.tr,
                        value: "${factoryData!['name']}",
                      ),
                      SizedBox(height: 18),
                      _infoRow(
                        icon: Icons.location_city,
                        label: 'factory_Governorate'.tr,
                        value: "${factoryData!['Governorate']}",
                      ),
                      SizedBox(height: 18),
                      _infoRow(
                        icon: Icons.location_on,
                        label: 'factory_address'.tr,
                        value: "${factoryData!['address']}",
                      ),
                      SizedBox(height: 18),
                      _infoRow(
                        icon: Icons.person,
                        label: 'contact_name'.tr,
                        value: "${factoryData!['contactName']}",
                      ),
                      SizedBox(height: 18),
                      _infoRow(
                        icon: Icons.phone,
                        label: 'contact_num'.tr,
                        value: "${factoryData!['phone']}",
                      ),
                      SizedBox(height: 18),
                      _infoRow(
                        icon: Icons.webhook_sharp,
                        label: 'factory_industry'.tr,
                        value: "${factoryData!['industry']}",
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  TextStyle get _titleStyle => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    fontFamily: 'mainFont',
  );
  TextStyle get _valueStyle => TextStyle(fontSize: 16, color: Colors.black87);

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.10),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        leading: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            shape: BoxShape.circle,
            border: Border.all(color: mainColor, width: 1),
          ),
          padding: EdgeInsets.all(10),
          child: Icon(icon, color: mainColor, size: 30),
        ),
        title: Text(
          label,
          style: _titleStyle.copyWith(fontSize: 16, color: mainColor),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            value,
            style: _valueStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
