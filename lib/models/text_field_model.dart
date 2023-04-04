import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget customTextField(
    {required String hintText,
    required TextEditingController controller,
    bool isLast = false,
    bool isPassword = false}) {
  return TextField(
    controller: controller,
    obscureText: isPassword,
    textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
    decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.roboto(
            color: Colors.black87.withOpacity(0.5),
            fontSize: 18,
            fontWeight: FontWeight.w700),
        enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            borderSide:
                BorderSide(width: 2.5, color: Colors.black87.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            borderSide: BorderSide(
                width: 2.5, color: Colors.black87.withOpacity(0.5)))),
    style: GoogleFonts.roboto(
        color: Colors.black87.withOpacity(0.7),
        fontSize: 18,
        fontWeight: FontWeight.w700),
  );
}
