import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kidly/constant/ApiConstant.dart';
import 'package:kidly/constant/ScreenConstant.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:kidly/api/api.dart';
import 'package:kidly/utils/connectivity.dart';
import 'package:kidly/utils/customcircledialog.dart';
import 'package:kidly/utils/showcircleprogressdialog.dart';
import 'package:kidly/utils/snackbar.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPVerificationScreen extends StatefulWidget {
  String name;
  String number;
  String type;
  String schoolName;
  OTPVerificationScreen(this.name, this.number, this.type, this.schoolName);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  ApiConstants apiConstants = ApiConstants();
  late Timer _timer;
  int _start = 30;
  bool isShowResend = false;

  TextEditingController otpController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getFcmToken();
    startTimer();
  }

  resendOTP() async {
    var body = json.encode({'mobile': widget.number, 'type': widget.type});

    print(body);
    try {
      showCircleProgressDialog(context);
      var response = await http.post(
        Uri.parse(apiBaseurl + resendOtp),
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      log(response.body);
      var dataAll = json.decode(response.body);
      if (dataAll['success'] == true) {
        setState(() {
          isShowResend = false;
          _start = 30;
          startTimer();
        });
        showInSnackBar(Colors.green, dataAll['message'], context);

        Navigator.pop(context);
      } else {
        showInSnackBar(Colors.red, dataAll['message'], context);
        Navigator.pop(context);
      }
    } catch (e) {
      print(e.toString());
      Navigator.pop(context);
    }
  }

  getFcmToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    fcmToken = prefs.getString('fcmToken').toString();
    print("fcmToken...$fcmToken");
    setState(() {});
  }

  String fcmToken = '';

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final color = isOnline ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/backgound.png'),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/newlogo.png",
              height: 70,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Verification",
              style: TextStyle(
                  fontFamily: 'NunitoRegular',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

              child: PinCodeTextField(
                controller: otpController,
                hintCharacter: '-',
                hintStyle: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'NunitoRegular',
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                  activeColor: Colors.white,
                  disabledColor: Colors.white,
                  selectedColor: Colors.white,
                  inactiveColor: Colors.white,
                  fieldHeight: 50,
                  fieldWidth: 48,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  activeFillColor: Colors.white,
                ),
                blinkWhenObscuring: true,
                animationType: AnimationType.fade,
                length: 6,
                animationDuration: const Duration(milliseconds: 300),
                appContext: context,
                keyboardType: TextInputType.number,
                pastedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'NunitoRegular',
                  decorationColor: Colors.white,
                  backgroundColor: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                enableActiveFill: true,
                onChanged: (val) {},
                onCompleted: (result) {
                  print(result);
                  //pin=result;

                  print(result);
                },
              ),
              // TextField(
              //   controller: otpController,

              //   textDirection: TextDirection.ltr,
              //   keyboardType: TextInputType.number,
              //   textAlign: TextAlign.center,
              //   enableSuggestions: false,
              //   inputFormatters: [
              //     LengthLimitingTextInputFormatter(6),
              //   ],
              //   decoration: const InputDecoration.collapsed(
              //     hintText: "------",
              //     hintStyle: TextStyle(
              //       letterSpacing: 20.0,
              //     ),
              //   ),
              // ),
            ),
            InkWell(
                onTap: () {
                  if (isShowResend) {
                    !isOnline
                        ? showInSnackBar(
                            color, 'Please check internet connection!', context)
                        : resendOTP();
                  }
                  //  else {
                  //   apiConstants.resendOTP(context, widget.number);
                  // }
                },
                child: Text(
                  isShowResend ? "Resend OTP" : "00:$_start",
                  style: const TextStyle(
                      fontFamily: 'NunitoRegular',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                )),
            const SizedBox(
              height: 20,
            ),
            Material(
              // needed
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (otpController.text.isEmpty) {
                    Fluttertoast.showToast(msg: 'Enter your otp');
                  } else if (otpController.text.length < 6) {
                    Fluttertoast.showToast(msg: 'Invalid otp');
                  } else {
                    !isOnline
                        ? showInSnackBar(
                            color, 'Please check internet connection!', context)
                        : apiConstants
                            .verifyOTP(
                                context,
                                widget.number,
                                otpController.text,
                                widget.type,
                                widget.name,
                                fcmToken,
                                widget.schoolName)
                            .then((value) {});
                  }
                }, // needed
                child: Image.asset("assets/images/submit_button.png"),
              ),
            )
          ],
        ),
      ),
    );
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            isShowResend = true;
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    otpController.dispose();
    super.dispose();
  }
}
