import 'package:flutter/material.dart';

const mainColor = Color(0xFF0187c4);
const secondaryColor = Color.fromARGB(255, 0, 115, 168);
// background
const AssetImage backgroundImage = AssetImage('assets/images/background2.jpg');

// Use this decoration to make the background image cover its parent
// const BoxDecoration backgroundDecoration = BoxDecoration(
//   image: DecorationImage(
//     image: backgroundImage,
//     fit: BoxFit.cover,
//   ),
// );

Image imageBackground = Image.asset(
  'assets/images/college.jpg',
  fit: BoxFit.cover,
  width: double.infinity,
  height: double.infinity,
);

Container backDark = Container(
  width: double.infinity,
  decoration: BoxDecoration(
    // color: const Color.fromARGB(206, 0, 0, 0),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color.fromARGB(230, 0, 0, 0), Color.fromARGB(200, 0, 0, 0)],
    ),
  ),
);
