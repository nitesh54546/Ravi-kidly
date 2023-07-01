import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:kidly/utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? textInputType;
  const CustomTextField(
      {required this.hintText,
      required this.controller,
      this.inputFormatters,
      this.textInputType});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(
          // horizontal: 25,
          ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, offset: Offset(2, 2), blurRadius: 10)
          ]),
      child: TextField(
        controller: controller,
        inputFormatters: inputFormatters,
        keyboardType: textInputType,
        style: const TextStyle(fontFamily: productSans, color: Colors.black),
        decoration: InputDecoration.collapsed(
            hintText: hintText,
            hintStyle:
                const TextStyle(fontFamily: productSans, color: Colors.black)),
      ),
    );
  }
}
