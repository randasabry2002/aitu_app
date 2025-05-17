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
      var querySnapshot = await FirebaseFirestore.instance
          .collection('Factories')
          .where('Name', isEqualTo: widget.selectedFactory)
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
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0187c4),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        backgroundColor: Colors.grey[100],
        body: isLoading
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
                    Text(
                      "معلومات المصنع",
                      style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0187c4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    _infoRow(
                      icon: Icons.factory,
                      label: "اسم المصنع",
                      value: "${factoryData!['Name']}",
                    ),
                    SizedBox(height: 18),
                    _infoRow(
                      icon: Icons.location_city,
                      label: "المحافظة",
                      value: "${factoryData!['Governorate']}",
                    ),
                    SizedBox(height: 18),
                    _infoRow(
                      icon: Icons.location_on,
                      label: "العنوان",
                      value: "${factoryData!['Address']}",
                    ),
                    ],
                  ),
                  ),
      ),
    );
  }

  TextStyle get _titleStyle => TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87);
  TextStyle get _valueStyle => TextStyle(fontSize: 16, color: Colors.black87);

  Widget _infoRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Color(0xFF0187c4)),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: _titleStyle),
              SizedBox(height: 4),
              Text(value, style: _valueStyle),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildDateRow(String label, DateTime? date, bool isStart) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Expanded(
  //         child: Text(label, style: _titleStyle),
  //       ),
  //       ElevatedButton(
  //         onPressed: () => _selectDate(context, isStart),
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.white,
  //           side: BorderSide(color: Color(0xFF0187c4)),
  //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //         ),
  //         child: Text(
  //           date == null ? "اختر التاريخ" : "${date.toLocal()}".split(' ')[0],
  //           style: TextStyle(color: Color(0xFF0187c4), fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
