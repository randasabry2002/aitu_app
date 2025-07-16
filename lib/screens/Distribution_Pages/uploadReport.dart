import 'package:aitu_app/screens/Attendance_Part_Pages/HomeScreen.dart';
import 'package:aitu_app/screens/Distribution_Pages/Not_College_distribution_page.dart';
import 'package:flutter/material.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'PDFViewerPage.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Implement two page states:
// TODO: 1. Initial state:
// ! - Show informational text about the page and student instructions
//   - Section to upload an image
//   - Button to upload image to Supabase with student name and ID
//   - Upload image to Supabase and other info to Firebase
//   - Show success message
//TODO: 2.Waiting state:
//   - Show waiting page
//   - Show successful upload message and current status info
//   - Display a copy of the uploaded image
//   - Button to replace image with a warning message
///
/// ? back state
///

// You need to add image_picker to your pubspec.yaml for this to work.

class UploadReport extends StatefulWidget {
  const UploadReport({Key? key}) : super(key: key);

  @override
  State<UploadReport> createState() => _UploadReportState();
}

class _UploadReportState extends State<UploadReport> {
  File? _image;
  bool _isUploaded = false;
  bool _isWaitingForApproval = false;
  bool _isLoading = false;
  String? _studentName;
  String? _studentCode;
  String? _reportDocId;
  String? _supabaseFileName;
  String? _imageUrl;
  Stream<DocumentSnapshot>? _approvalStream;

  @override
  void initState() {
    super.initState();
    _fetchStudentInfo();
  }

  Future<void> _fetchStudentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email");
    if (email == null) return;
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('StudentsTable')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        _studentName = data['name'] ?? '';
        _studentCode = data['code'] ?? '';
      });
    }
  }

  Future<void> _uploadReport() async {
    if (_image == null || _studentName == null || _studentCode == null) return;
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final fileName = '${_studentName}_${_studentCode}.jpg';
      final fileBytes = await _image!.readAsBytes();
      await supabase.storage
          .from('reports')
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );
      final publicUrl = supabase.storage.from('reports').getPublicUrl(fileName);
      final docRef = await FirebaseFirestore.instance
          .collection('Reports')
          .add({
            'studentName': _studentName,
            'studentCode': _studentCode,
            'imageUrl': publicUrl,
            'isApproved': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
      setState(() {
        _isUploaded = true;
        _isWaitingForApproval = true;
        _reportDocId = docRef.id;
        _supabaseFileName = fileName;
        _imageUrl = publicUrl;
      });
      _listenForApproval(docRef.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم رفع التقرير بنجاح. في انتظار موافقة الكلية.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء رفع التقرير: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _listenForApproval(String docId) {
    _approvalStream =
        FirebaseFirestore.instance.collection('Reports').doc(docId).snapshots();
    _approvalStream!.listen((snapshot) async {
      if (snapshot.exists && snapshot['isApproved'] == true) {
        // Update factory field in StudentsTable
        final prefs = await SharedPreferences.getInstance();
        String? email = prefs.getString("email");
        if (email != null) {
          final studentQuery =
              await FirebaseFirestore.instance
                  .collection('StudentsTable')
                  .where('email', isEqualTo: email)
                  .limit(1)
                  .get();
          if (studentQuery.docs.isNotEmpty) {
            final studentDoc = studentQuery.docs.first;
            // Example: update factory to 'المصنع المختار'
            await studentDoc.reference.update({'factory': 'المصنع المختار'});
            // Navigate to HomeScreen
            Get.offAllNamed('/home');
          }
        }
      }
    });
  }

  Future<void> _cancelUpload() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('تأكيد الإلغاء'),
            content: Text(
              'هل أنت متأكد من إلغاء الإرسال؟ سيتم حذف كل البيانات والصورة.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('لا'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('نعم'),
              ),
            ],
          ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    try {
      if (_supabaseFileName != null) {
        final supabase = Supabase.instance.client;
        await supabase.storage.from('reports').remove([_supabaseFileName!]);
      }
      if (_reportDocId != null) {
        await FirebaseFirestore.instance
            .collection('Reports')
            .doc(_reportDocId)
            .delete();
      }
      setState(() {
        _isUploaded = false;
        _isWaitingForApproval = false;
        _reportDocId = null;
        _supabaseFileName = null;
        _imageUrl = null;
        _image = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم إلغاء الإرسال بنجاح.')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء الإلغاء: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final ImageSource? source = await _showImageSourceDialog(context);
    if (source == null) return;
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء اختيار الصورة. الرجاء المحاولة مرة أخرى.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Center(child: Icon(Icons.arrow_back_ios, color: mainColor)),
          tooltip: 'عودة',
          onPressed: () {
            Get.offAll(Not_College_distribution_page());
          },
        ),
        title: Text(
          'رفع تقرير التدريب',
          style: TextStyle(
            color: mainColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Tajawal',
          ),
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _isWaitingForApproval && _image != null
              ? _buildWaitingView()
              : _image != null
              ? _buildUploadedView()
              : _buildInitialView(),
    );
  }

  Widget _buildWaitingView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تم إرسال التقرير بنجاح. في انتظار موافقة الكلية.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 40.0),
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Container(child: Icon(Icons.image)),
                        title: Text(
                          'تقريرك',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(
                          width: double.infinity,
                          height: 400.0,
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.edit, color: mainColor),
                        label: Text(
                          'تغيير الصورة',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: mainColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: mainColor, width: 1.0),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton.icon(
                        onPressed: _cancelUpload,
                        icon: Icon(Icons.cancel, color: Colors.red),
                        label: Text(
                          'إلغاء الإرسال',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.red, width: 1.0),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadedView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'الان قم بالضغط على رفع التقرير بالاسفل لارساله الى متخصصين التدريب الصناعي بالكلية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 60.0),
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Container(child: Icon(Icons.image)),
                        title: Text(
                          'تقريرك',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(
                          width: double.infinity,
                          height: 400.0,
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.edit, color: mainColor),
                        label: Text(
                          'تغيير الصورة',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: mainColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: mainColor, width: 1.0),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Stack(
                children: [
                  SizedBox(
                    height: 50.0,
                    child: CreateButton(
                      // onPressed: _uploadReport,
                      onPressed: () {
                        Get.offAll(HomeScreen());
                      },
                      title: Center(
                        child: Text(
                          'رفع التقرير',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _image == null,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 10,
                      ),
                      child: Center(
                        child: Text(
                          'رفع التقرير',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color.fromARGB(255, 190, 190, 190),
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: mainColor, width: 1),
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'يرجى رفع بطاقة الترشيح المختومة كصورة، وانتظر مراجعة أعضاء الهيئة في الكلية.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 60.0),
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Container(child: Icon(Icons.image)),
                        title: Text(
                          'قم برفع الصوره',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(color: mainColor, width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                color: mainColor,
                                size: 50,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'اضغط هنا لاختيار الصوره',
                                style: TextStyle(
                                  color: mainColor,
                                  fontSize: 16,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 60.0),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                child: Center(
                  child: Text(
                    'رفع التقرير',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color.fromARGB(255, 190, 190, 190),
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: mainColor, width: 1),
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a modal bottom sheet for the user to choose between camera and gallery.
/// Returns the selected [ImageSource], or null if cancelled.
Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
  return await showModalBottomSheet<ImageSource>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder:
        (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: mainColor),
                title: Text(
                  'التقاط صورة بالكاميرا',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: mainColor),
                title: Text(
                  'اختيار من المعرض',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
  );
}
