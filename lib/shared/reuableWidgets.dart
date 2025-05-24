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
  final Color? color;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? labelColor;
  final TextAlign? textAlign;
  final bool? isReadOnly;
  final VoidCallback? onTap;
  const CreateInput({
    Key? key,
    required this.onChanged,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.isPassword = false,
    this.prefix,
    this.suffix,
    this.color,
    this.borderColor,
    this.labelColor,
    this.textAlign,
    this.focusedBorderColor,
    this.isReadOnly,
    this.onTap
  }) : super(key: key);
  @override
  State<CreateInput> createState() => _CreateInputState();
}

class _CreateInputState extends State<CreateInput> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: widget.onTap,
      controller: widget.controller,
      obscureText: widget.isPassword == true ? true : false,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      textAlign: widget.textAlign ?? TextAlign.left,
      readOnly: widget.isReadOnly ?? false,
      decoration: InputDecoration(
        prefixIcon: widget.prefix,
        suffixIcon: widget.suffix,
        fillColor: widget.color ?? const Color.fromARGB(70, 255, 255, 255),
        filled: true,
        labelText: widget.labelText.tr, // Translation key for "Email"
        labelStyle: TextStyle(
          color: widget.labelColor ?? mainColor,
          fontSize: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: secondaryColor),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.focusedBorderColor ?? mainColor),
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      style: TextStyle(
        color: const Color.fromARGB(255, 0, 0, 0),
        fontSize: 18,
        fontFamily: 'Tajawal',
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

//buttons
class CreateButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget title;

  const CreateButton({Key? key, required this.onPressed, required this.title})
    : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [mainColor, Color.fromARGB(255, 0, 243, 223)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: title,
      ),
    );
  }
}
