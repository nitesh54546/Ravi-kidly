import 'package:flutter/material.dart';

class AppConstant {
  static showSnackBar(context, message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          fontFamily: 'NunitoRegular',
        ),
      ),
      backgroundColor: Colors.green,
    ));
  }

  static getScreenTitleWhite() => const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'NunitoRegular',
      );
}
