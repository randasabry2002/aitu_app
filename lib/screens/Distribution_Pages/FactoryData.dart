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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _submitData() {
    if (startDate == null || endDate == null) {
      Get.snackbar("خطأ", "يجب اختيار تواريخ التدريب!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    print("Factory: ${widget.selectedFactory}");
    print("Start Date: $startDate");
    print("End Date: $endDate");

    Get.snackbar("نجاح", "تم إرسال البيانات بنجاح!", backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0187c4),
          title: Text("تفاصيل المصنع", style: TextStyle(color: Colors.white)),
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
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📍 اسم المصنع:", style: _titleStyle),
                      Text("${factoryData!['Name']}", style: _valueStyle),
                      SizedBox(height: 12),
                      Text("🏛 المحافظة:", style: _titleStyle),
                      Text("${factoryData!['Governorate']}", style: _valueStyle),
                      SizedBox(height: 12),
                      Text("📬 العنوان:", style: _titleStyle),
                      Text("${factoryData!['Address']}", style: _valueStyle),
                    ],
                  ),
                ),
              ),
              // SizedBox(height: 30),
              //
              // // اختيار تاريخ البداية
              // _buildDateRow("📅 تاريخ بداية التدريب:", startDate, true),
              //
              // SizedBox(height: 20),
              //
              // // اختيار تاريخ النهاية
              // _buildDateRow("📅 تاريخ نهاية التدريب:", endDate, false),
              //
              // SizedBox(height: 40),
              //
              // // زر الإرسال
              // ElevatedButton.icon(
              //   onPressed: _submitData,
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Color(0xFF0187c4),
              //     padding: EdgeInsets.symmetric(vertical: 16),
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //   ),
              //   icon: Icon(Icons.send, color: Colors.white),
              //   label: Text("إرسال البيانات", style: TextStyle(fontSize: 18, color: Colors.white)),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _titleStyle => TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87);
  TextStyle get _valueStyle => TextStyle(fontSize: 16, color: Colors.black87);

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
