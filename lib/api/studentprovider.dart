import 'dart:convert';
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kidly/api/api.dart';
import 'package:kidly/constant/ScreenConstant.dart';
import 'package:kidly/utils/sharepreference.dart';
import 'package:kidly/utils/showcircleprogressdialog.dart';
import 'package:kidly/utils/snackbar.dart';

class StudentProvider extends ChangeNotifier {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isVisible = true;

  validation(BuildContext context) {
    if (userNameController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Enter your username');
    } else if (passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Enter your password');
    } else {
      login(context);
      // provider.
    }
  }

  login(
    BuildContext context,
  ) async {
    var body = json.encode({
      "username": userNameController.text,
      "password": passwordController.text
    });
    try {
      showCircleProgressDialog(context);
      notifyListeners();
      var response = await http.post(
        Uri.parse(studentBaseUrl + studentLogin),
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      log(response.body);
      var dataAll = json.decode(response.body);
      if (dataAll['success'] == true) {
        setToken(dataAll['student']['token']);
        //   setActive(dataAll['user']['active'].toString());
        setLogin(true);
        Navigator.pushReplacementNamed(context, ScreenConstant.dashboard);
        userNameController.clear();
        passwordController.clear();

        // Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) =>
        //             OTPVerificationScreen(name, number, type, '')));
        showInSnackBar(Colors.green, dataAll['message'], context);
      } else {
        showInSnackBar(Colors.red, dataAll['message'], context);
        Navigator.pop(context);
      }
    } catch (e) {
      print(e.toString());
      Navigator.pop(context);
    }
  }
}
