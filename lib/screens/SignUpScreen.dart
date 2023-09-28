import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kidly/constant/ApiConstant.dart';
import 'package:kidly/helper/customtextfield.dart';
import 'package:kidly/utils/connectivity.dart';
import 'package:kidly/utils/constants.dart';
import 'package:kidly/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/AppConstant.dart';

class SignUpScreen extends StatefulWidget {
  final String dob;
  final String routes;
  final String name;
  final String number;
  final String schoolName;
  SignUpScreen(this.dob, this.routes, this.name, this.number, this.schoolName);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  ApiConstants apiConstants = ApiConstants();
  var placeHolderText = "";
  var countryFlagText = "🇮🇳 +91";
  var phoneCodeWithPlus = "+91";
  int selectedGender = -1;
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController schoolNameController = TextEditingController();

  String token = '';
  String fcmToken = '';
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('auth_token') != null) {
      setState(() {
        fcmToken = prefs.getString('fcmToken').toString();
        routeType = prefs.getString('routeType').toString();
        token = prefs.getString('auth_token').toString();
        print(token);

        nameController.text = widget.name.isNotEmpty ? widget.name : '';
        numberController.text =
            widget.number.isNotEmpty ? widget.number.substring(3) : '';
        phoneCodeWithPlus =
            widget.number.isNotEmpty ? widget.number.substring(0, 3) : '+91';
        schoolNameController.text =
            widget.schoolName.isNotEmpty ? widget.schoolName : '';
        setState(() {});
        print(widget.number.substring(0, 3));
      });
    }
  }

  @override
  void initState() {
    getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final color = isOnline ? Colors.green : Colors.red;
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/backgound_old.png'),
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
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: CustomTextField(
                    hintText: 'Name', controller: nameController)),
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
                    height: 53,
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(left: 25, right: 10),
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
                  child: Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: CustomTextField(
                      hintText: 'Phone',
                      controller: numberController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10)
                      ],
                      textInputType: TextInputType.phone,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: CustomTextField(
                    hintText: 'School Name', controller: schoolNameController)),
            const SizedBox(
              height: 20,
            ),
            Material(
              // needed
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (nameController.text.isEmpty) {
                    Fluttertoast.showToast(msg: 'Enter your name');
                  } else if (schoolNameController.text.isEmpty) {
                    Fluttertoast.showToast(msg: 'Enter your school name');
                  } else if (numberController.text.isEmpty) {
                    Fluttertoast.showToast(msg: 'Enter your number');
                  } else if (numberController.text.length < 10) {
                    Fluttertoast.showToast(msg: 'Enter valid number');
                  } else {
                    !isOnline
                        ? showInSnackBar(
                            color, 'Please check internet connection!', context)
                        : widget.routes == 'profile'
                            ? apiConstants.userUpdateDetail(
                                context,
                                nameController.text,
                                widget.dob,
                                phoneCodeWithPlus + numberController.text,
                                token,
                                schoolNameController.text,
                                routeType,
                              )
                            : apiConstants.sendOTP(
                                context,
                                phoneCodeWithPlus + numberController.text,
                                'register',
                                nameController.text,
                                schoolNameController.text);
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

  genderWidget() {
    return Container(
      padding: const EdgeInsets.only(left: 25, right: 15, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gender',
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'NunitoRegular',
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 2,
          ),
          Row(
            children: [
              radioBtn('Male', 0, () {
                setState(() {
                  selectedGender = 0;
                });
              }),
              const SizedBox(
                width: 20,
              ),
              radioBtn('Female', 1, () {
                setState(() {
                  selectedGender = 1;
                });
              }),
            ],
          )
        ],
      ),
    );
  }

  radioBtn(String title, int index, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
                shape: BoxShape.circle, border: Border.all(color: Colors.blue)),
            padding: const EdgeInsets.all(2),
            child: selectedGender == index
                ? Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red),
                  )
                : Container(),
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            title,
            style: const TextStyle(
                fontSize: 17,
                fontFamily: 'NunitoRegular',
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void selectCountry() {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 16,
          color: Colors.blueGrey,
          fontFamily: 'NunitoRegular',
        ),
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

  DateTime selectedDate = DateTime.now();
  var day, month, year;

  Future<void> birthdayPicker() async {
    DateTime? picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: ThemeData(colorSchemeSeed: Color(0xffFF3465)),
            // ThemeData.estimateBrightnessForColor(
            //   colorScheme: ColorScheme.fromSwatch(
            //     primarySwatch: Colors.red,
            //     primaryColorDark: Colors.red,
            //     accentColor: Colors.red,
            //   ),
            //   dialogBackgroundColor: Colors.white,
            // ),
            child: child!,
          );
        },
        helpText: "Select Birthday Date",
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1935, 1),
        lastDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day));

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        selectedDate = picked;
        day = selectedDate.day < 10 ? '0${selectedDate.day}' : selectedDate.day;
        month = selectedDate.month < 10
            ? '0${selectedDate.month}'
            : selectedDate.month;
        year = selectedDate.year;
        print(selectedDate);
        ageController.text = "${selectedDate.year}-$month-$day";
      });
    }
  }
}
