import 'package:flutter/material.dart';

void showInSnackBar(Color color, String value, context) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Text(
        value,
        style: const TextStyle(
          fontFamily: 'NunitoRegular',
        ),
      )));
}
