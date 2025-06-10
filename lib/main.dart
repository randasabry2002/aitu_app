import 'package:aitu_app/screens/Splash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/appTranslations.dart';

Future<void> main() async {
  // تأكد من تهيئة البنية الأساسي=  
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase بطريقة آمنة تمامًا
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDSFmcUOY8o32j_JOgICayGICWZyK2Em4s",
          authDomain: "german-collage-training-78233.firebaseapp.com",
          projectId: "german-collage-training-78233",
          storageBucket: "german-collage-training-78233.firebasestorage.app",
          messagingSenderId: "853561466710",
          appId: "1:853561466710:web:63cbbcf17ad62e50e480f7",
          measurementId: "G-WR18ZPD21J",
        ),
      );
    }
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }

  await Supabase.initialize(
    url: 'https://cjzaqgnhcpjtlswhnbda.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNqemFxZ25oY3BqdGxzd2huYmRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYyOTc2MDMsImV4cCI6MjA2MTg3MzYwM30.8oFur4LN2JzRXBauTr7b8eZOAK56Ie2fy9kw3o__Ju8',
  );

  // تحميل الترجمات
  await AppTranslations.loadTranslations();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(), // Provide translations
      locale: Locale('ar'), // Set Arabic as default language
      fallbackLocale: Locale('en'), // Fallback to English
      supportedLocales: [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Splash(),
      // home: Scaffold(backgroundColor: Colors.green,),
      routes: {
        // Define your routes here
        // '/home': (context) => HomeScree
      },
    );
  }
}
