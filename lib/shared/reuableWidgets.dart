import 'package:aitu_app/shared/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//inputs
class CreateInput extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String labelText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final bool? isPassword;
  final Widget? prefix;
  final Widget? suffix;
  const CreateInput({
    Key? key,
    required this.onChanged,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.isPassword = false,
    this.prefix,
    this.suffix,
  }) : super(key: key);
  @override
  State<CreateInput> createState() => _CreateInputState();
}

class _CreateInputState extends State<CreateInput> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword == true ? true : false,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      
      decoration: InputDecoration(
        prefixIcon: widget.prefix,
        suffixIcon: widget.suffix,
        fillColor: const Color.fromARGB(70, 255, 255, 255),
        filled: true,
        labelText: widget.labelText.tr, // Translation key for "Email"
        labelStyle: TextStyle(color: mainColor, fontSize: 16),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: secondaryColor),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mainColor),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      style: TextStyle(
        color: const Color.fromARGB(255, 0, 0, 0),
        fontSize: 16,
        fontFamily: 'mainFont',
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

//buttons
class CreateButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  const CreateButton({Key? key, required this.onPressed, required this.title})
    : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        padding: EdgeInsets.symmetric(horizontal: 120, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      child: Text(
        title.tr,
        style: TextStyle(
          fontSize: 24,
          color: mainColor,
          fontWeight: FontWeight.bold,
          fontFamily: 'mainFont',
        ),
      ), // Key for "Sign Up"
    );
  }
}
