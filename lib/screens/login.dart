import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kidly/api/loginprovider.dart';
import 'package:kidly/constant/ApiConstant.dart';
import 'package:kidly/screens/SignUpScreen.dart';
import 'package:kidly/utils/connectivity.dart';
import 'package:kidly/utils/snackbar.dart';
import 'package:provider/provider.dart';
import '../constant/AppConstant.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ApiConstants apiConstants = ApiConstants();
  var placeHolderText = "";
  var countryFlagText = "🇮🇳 +91";
  var phoneCodeWithPlus = "+91";

  TextEditingController numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    LoginProvider loginProvider = Provider.of<LoginProvider>(context);
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final color = isOnline ? Colors.green : Colors.red;

    return WillPopScope(
      onWillPop: () async {
        exit(0);
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/backgound.png'),
                fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Positioned(
              //     top: 0,
              //     bottom: 0,
              //     left: 0,
              //     right: 0,
              //     child: Image.asset(
              //       "assets/images/backgound.png",
              //       fit: BoxFit.cover,
              //     )),
              Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/kidly-logo.png",
                        height: 70,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              // selectCountry();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              margin:
                                  const EdgeInsets.only(left: 25, right: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12,
                                        offset: Offset(2, 2),
                                        blurRadius: 10)
                                  ]),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    countryFlagText.isNotEmpty
                                        ? countryFlagText
                                        : "🇮🇳 +91",
                                    style: AppConstant.getScreenTitleWhite(),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              margin: const EdgeInsets.only(right: 25),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12,
                                        offset: Offset(2, 2),
                                        blurRadius: 10)
                                  ]),
                              child: TextField(
                                controller: numberController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10),
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration.collapsed(
                                    hintText: "Phone Number",
                                    hintStyle: TextStyle(
                                      fontFamily: 'NunitoRegular',
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Material(
                        // needed
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (numberController.text.isEmpty) {
                              Fluttertoast.showToast(msg: 'Enter your number');
                            } else if (numberController.text.length < 10) {
                              Fluttertoast.showToast(msg: 'Enter valid number');
                            } else {
                              !isOnline
                                  ? showInSnackBar(
                                      color,
                                      'Please check internet connection!',
                                      context)
                                  : loginProvider.sendOTP(
                                      context,
                                      phoneCodeWithPlus + numberController.text,
                                      'other',
                                      '');
                            }
                          }, // needed
                          child: Image.asset("assets/images/submit_button.png"),
                        ),
                      ),
                      // const SizedBox(
                      //   height: 20,
                      // ),
                      Material(
                        color: Colors.transparent,
                        child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionsBuilder: (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return FadeTransition(
                                        opacity: animation, child: child);
                                  },
                                  transitionDuration:
                                      const Duration(microseconds: 800),
                                  pageBuilder: (BuildContext context,
                                      Animation<double> animation,
                                      Animation<double> secondaryAnimation) {
                                    return SignUpScreen(
                                        '', 'login', '', '', '');
                                  },
                                ),
                              );
                            },
                            child: Image.asset("assets/new/signup.png")),
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void selectCountry() {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, color: Colors.blueGrey),
        bottomSheetHeight: 500, // Optional. Country list modal height
        //Optional. Sets the border radius for the bottomsheet.
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        //Optional. Styles the search field.
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          hintStyle: const TextStyle(
            fontFamily: 'NunitoRegular',
          ),
          labelStyle: const TextStyle(
            color: Colors.black38,
            fontSize: 14,
            fontFamily: 'NunitoRegular',
          ),
          prefixIcon: const Icon(Icons.search),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          countryFlagText = "${country.flagEmoji} +${country.phoneCode}";
          phoneCodeWithPlus = "+${country.phoneCode}";
        });
        if (kDebugMode) {
          print('Select country: +${country.flagEmoji}');
        }
      },
    );
  }

  showLoading() {
    return AlertDialog(
        content: Container(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/loder.gif',
            width: 80,
            height: 80,
          ),
        ],
      ),
    ));
  }
}
