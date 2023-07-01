import 'dart:convert';
import 'dart:developer';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kidly/api/api.dart';
import 'package:kidly/constant/ScreenConstant.dart';
import 'package:kidly/screens/DashboardScreen.dart';
import 'package:kidly/screens/DashboardScreen2.dart';
import 'package:kidly/screens/OTPVerificationScreen.dart';
import 'package:kidly/utils/customcircledialog.dart';
import 'package:kidly/utils/sharepreference.dart';
import 'package:kidly/utils/snackbar.dart';

class ApiConstants {
  static final facebookAppEvents = FacebookAppEvents();
  bool isLoading = false;
  sendOTP(BuildContext context, String number, String type, String name,
      String schoolName) async {
    var body = json.encode({
      'mobile': number,
      'type': type,
    });
    print(body);
    try {
      isLoading = true;
      // EasyLoading.show();
      showCircleProgressDialog(context);
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
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OTPVerificationScreen(name, number, type, schoolName)));
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

  Future verifyOTP(BuildContext context, String number, String otp, String type,
      String name, String fcmToken, String schoolName) async {
    var body =
        json.encode({'mobile': number, 'otp': otp, 'device_token': fcmToken});
    print(body);
    try {
      showCircleProgressDialog(context);
      var response = await http.post(
        Uri.parse(apiBaseurl + verify),
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      log(response.body);
      var dataAll = json.decode(response.body);
      if (dataAll['success'] == true) {
        if (type == 'other') {
          setToken(dataAll['user']['token']);
          setActive(dataAll['user']['active'].toString());
          setLogin(true);
          Navigator.pushReplacementNamed(context, ScreenConstant.dashboard);
          facebookAppEvents.setUserData(
            phone: number,
          );
          // await FirebaseAnalytics.instance
          //     .logEvent(name: 'login', parameters: {'number': number});
        } else {
          callSignup(context, number, name, fcmToken, schoolName);
        }
        return dataAll;
      } else {
        showInSnackBar(Colors.red, dataAll['message'], context);
        Navigator.pop(context);
      }
    } catch (e) {
      print(e.toString());
      Navigator.pop(context);
    }
  }

  Future callSignup(BuildContext context, String number, String name,
      String fcmToken, String schoolName) async {
    var body = json.encode({
      'mobile': number,
      'name': name,
      'device_token': fcmToken,
      'school_name': schoolName
    });
    print("body...$body");
    try {
      showCircleProgressDialog(context);
      var response = await http.post(
        Uri.parse(apiBaseurl + signup),
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      log(response.body);
      var dataAll = json.decode(response.body);
      if (dataAll['success'] == true) {
        print(dataAll['user']['token']);
        setToken(dataAll['user']['token'].toString());
        setActive("${dataAll['user']['active'].toString()}");
        setLogin(true);
        facebookAppEvents.setUserData(
          phone: number,
          firstName: name,
        );
        // await FirebaseAnalytics.instance.logEvent(
        //     name: 'signup', parameters: {'name': name, 'number': number});

        Navigator.pushReplacementNamed(context, ScreenConstant.dashboard);
      } else {
        showInSnackBar(Colors.red, dataAll['message'], context);
        Navigator.pop(context);
      }
    } catch (e) {
      print(e.toString());
      Navigator.pop(context);
    }
  }

  callSubscribedUser(BuildContext context, String id, String transactionId,
      String token) async {
    var body =
        json.encode({'subscription_id': id, 'transaction_id': transactionId});
    print(body);
    try {
      showCircleProgressDialog(context);
      var response = await http.post(
        Uri.parse(apiBaseurl + subscribedUser),
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      log(response.body);
      var dataAll = json.decode(response.body);
      if (dataAll['success'] == true) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
            (route) => true);
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

  userUpdateDetail(BuildContext context, String name, String dob, String number,
      String token, String schoolName, String type) async {
    var body = json.encode({
      'name': name,
      'dob': dob,
      'mobile': number,
      'school_name': schoolName
    });
    print("body...$body");
    try {
      showCircleProgressDialog(context);
      var response = await http.post(
        Uri.parse(type == 'student'
            ? (studentBaseUrl + studentUpdateDetail)
            : (apiBaseurl + updateDetail)),
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      log(response.body);
      var dataAll = json.decode(response.body);
      if (dataAll['success'] == true) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DashboardScreen()));
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

  // callSearchApi(BuildContext context, String token, String text) async {
  //   try {
  //     var response = await http.get(
  //       Uri.parse(baseurl + searchApi + text),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token'
  //       },
  //     );
  //     log(response.body);
  //     var dataAll = json.decode(response.body);
  //     if (dataAll['success'] == true) {
  //       showInSnackBar(Colors.green, dataAll['message'], context);
  //     } else {
  //       showInSnackBar(Colors.red, dataAll['message'], context);
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  showCircleProgressDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            child: CustomCircularProgressIndicator(),
            onWillPop: () async {
              return false;
            },
          );
        });
  }
}
