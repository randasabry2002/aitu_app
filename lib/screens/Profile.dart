import 'package:aitu_app/screens/Splash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aitu_app/shared/constant.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studentCodeController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _studentData;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString("email");

      if (email != null) {
        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('StudentsTable')
                .where('email', isEqualTo: email)
                .limit(1)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            _studentData = querySnapshot.docs.first.data();
          });
        }
      }
    } catch (e) {
      print('Error loading student data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString("email");

      if (email != null) {
        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('StudentsTable')
                .where('email', isEqualTo: email)
                .limit(1)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final currentPassword = doc['password'];

          // Verify current password
          if (currentPassword != _currentPasswordController.text) {
            Get.snackbar(
              'خطأ',
              'كلمة المرور الحالية غير صحيحة',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          // Validate new password
          if (_newPasswordController.text.length < 6) {
            Get.snackbar(
              'خطأ',
              'يجب أن تكون كلمة المرور الجديدة 6 أحرف على الأقل',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          // Update password
          await doc.reference.update({
            'password': _newPasswordController.text,
            'lastPasswordChange': FieldValue.serverTimestamp(),
          });

          Get.snackbar(
            'نجاح',
            'تم تغيير كلمة المرور بنجاح',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          _studentCodeController.clear();
        }
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تغيير كلمة المرور',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showLogoutDialog() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "تسجيل الخروج",
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "هل أنت متأكد من رغبتك في تسجيل الخروج؟",
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "لا",
                style: TextStyle(color: Colors.black, fontFamily: 'Tajawal'),
              ),
            ),
            TextButton(
              onPressed: () async {
                final SharedPreferences _prefs =
                    await SharedPreferences.getInstance();
                await _prefs.setString("email", "null");
                await _prefs.setString("page", "null");
                Navigator.of(context).pop(true);
              },
              child: Text(
                "نعم",
                style: TextStyle(
                  color: Color.fromARGB(255, 172, 23, 23),
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      Get.offAll(() => Splash());
    }
  }

  Future<void> _showPasswordChangeDialog() async {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _studentCodeController.clear();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'تغيير كلمة المرور',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPasswordField(
                    'الرقم الأكاديمي',
                    _studentCodeController,
                    false,
                    validator: (value) {
                      if (value != _studentData!['code']) {
                        return 'الرقم الأكاديمي غير صحيح';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  _buildPasswordField(
                    'كلمة المرور الحالية',
                    _currentPasswordController,
                    true,
                  ),
                  SizedBox(height: 10),
                  _buildPasswordField(
                    'كلمة المرور الجديدة',
                    _newPasswordController,
                    true,
                  ),
                  SizedBox(height: 10),
                  _buildPasswordField(
                    'تأكيد كلمة المرور الجديدة',
                    _confirmPasswordController,
                    true,
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'كلمات المرور غير متطابقة';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'إلغاء',
                style: TextStyle(color: Colors.black, fontFamily: 'Tajawal'),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  await _changePassword();
                }
              },
              child: Text(
                'تغيير',
                style: TextStyle(
                  color: mainColor,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'الملف الشخصي',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                  ),
                )
                : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_studentData != null) ...[
                        _buildInfoCard(
                          'الاسم',
                          _studentData!['name'] ?? 'غير متوفر',
                          Icons.person,
                        ),
                        _buildInfoCard(
                          'البريد الإلكتروني',
                          _studentData!['email'] ?? 'غير متوفر',
                          Icons.email,
                        ),
                        _buildInfoCard(
                          'الرقم القومي',
                          _studentData!['nationalID'] ?? 'غير متوفر',
                          Icons.numbers,
                        ),
                        _buildInfoCard(
                          'رقم الهاتف',
                          _studentData!['phone'] ?? 'غير متوفر',
                          Icons.phone,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _showPasswordChangeDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'تغيير كلمة المرور',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _showLogoutDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 172, 23, 23),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'تسجيل الخروج',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: mainColor),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscureText, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'هذا الحقل مطلوب';
            }
            return null;
          },
    );
  }
}
