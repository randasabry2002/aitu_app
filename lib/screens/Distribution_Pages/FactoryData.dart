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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          centerTitle: true,
          title: Text(
            'بيانات المصنع',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Tajawal',
              fontSize: 22.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
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
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                )
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 40),
                  
                      // SizedBox(height: 20),

                      _infoRow(
                        icon: Icons.factory,
                        label: 'اسم المصنع',
                        value: "${factoryData!['name']}",
                      ),
                      SizedBox(height: 18),
                      _infoRow(
                        icon: Icons.location_city,
                        label: 'المحافظة',
                        value: "${factoryData!['Governorate']}",
                      ),
                      SizedBox(height: 18),
                      _infoRow(
                        icon: Icons.location_on,
                        label: 'العنوان',
                        value: "${factoryData!['address']}",
                      ),
                      SizedBox(height: 18),
                      _infoRow(
                        icon: Icons.person,
                        label: 'اسم المسؤول',
                        value: "${factoryData!['contactName']}",
                      ),
                      SizedBox(height: 18),
                      _infoRow(
                        icon: Icons.phone,
                        label: 'رقم الهاتف',
                        value: "${factoryData!['phone']}",
                      ),
                      SizedBox(height: 18),
                      _infoRow(
                        icon: Icons.webhook_sharp,
                        label: 'الصناعة',
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
    fontFamily: 'Tajawal',
  );
  TextStyle get _valueStyle =>
      TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Tajawal');

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
            border: Border.all(
              color: Color.fromARGB(255, 0, 255, 234),
              width: 0.5,
            ),
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
