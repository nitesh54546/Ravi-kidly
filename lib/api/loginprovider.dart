import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kidly/api/api.dart';
import 'package:kidly/screens/OTPVerificationScreen.dart';
import 'package:kidly/utils/showcircleprogressdialog.dart';
import 'package:kidly/utils/snackbar.dart';

class LoginProvider extends ChangeNotifier {
  bool isLoading = false;
  sendOTP(BuildContext context, String number, String type, String name) async {
    var body = json.encode({'mobile': number, 'type': type});
    print(body);
    try {
      isLoading = true;
      showCircleProgressDialog(context);
      notifyListeners();
      var response = await http.post(
        Uri.parse(apiBaseurl + sendOtp),
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      log(response.body);
      var dataAll = json.decode(response.body);
      if (dataAll['success'] == true) {
        isLoading = false;

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OTPVerificationScreen(name, number, type, '')));
        showInSnackBar(Colors.green, dataAll['message'], context);
      } else {
        isLoading = false;
        showInSnackBar(Colors.red, dataAll['message'], context);
        Navigator.pop(context);
      }
    } catch (e) {
      isLoading = false;
      print(e.toString());
      Navigator.pop(context);
    }
  }
}
