import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  // @override
  // Map<String, Map<String, String>> get keys => {
  //
  //   // 'en': {
  //   //   'sign_in': 'Sign In',
  //   //   'email': 'Email',
  //   //   'password': 'Password',
  //   //   'invalid_credentials': 'Invalid email or password',
  //   //   'enter_password': 'Enter your password',
  //   //   'sign_up_prompt': "Don't have an account? Sign Up",
  //   //   'sign_in_button': 'Sign In',
  //   //   'sign_up': 'Sign Up',
  //   //   'confirm_password': 'Confirm your Password',
  //   //   'enter_email': 'Enter your Email',
  //   //   'password_mismatch': 'Passwords do not match',
  //   //   'already_have_account': 'Already have an account? Sign In',
  //   // },
  //   // 'ar': {
  //   //   'sign_in': 'تسجيل الدخول',
  //   //   'email': 'البريد الإلكتروني',
  //   //   'password': 'كلمة المرور',
  //   //   'invalid_credentials': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
  //   //   'enter_password': 'الرجاء إدخال كلمة المرور',
  //   //   'sign_up_prompt': 'ليس لديك حساب؟ أنشئ حساب',
  //   //   'sign_in_button': 'تسجيل الدخول',
  //   //   'sign_up': 'إنشاء حساب',
  //   //   'confirm_password': 'تأكيد كلمة المرور',
  //   //   'enter_email': 'أدخل البريد الإلكتروني',
  //   //   'password_mismatch': 'كلمتا المرور غير متطابقتين',
  //   //   'already_have_account': 'هل لديك حساب؟ تسجيل الدخول',
  //   // },
  // };

  static Map<String, Map<String, String>> translations = {};

  static Future<void> loadTranslations() async {
    final en = await rootBundle.loadString('assets/lang/en.json');
    final ar = await rootBundle.loadString('assets/lang/ar.json');

    translations = {
      'en': Map<String, String>.from(json.decode(en)),
      'ar': Map<String, String>.from(json.decode(ar)),
    };
  }

  @override
  Map<String, Map<String, String>> get keys => translations;



}
