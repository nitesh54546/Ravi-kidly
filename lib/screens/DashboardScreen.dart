import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kidly/constant/searchprovider.dart';
import 'package:kidly/modal/dashboard_list_model.dart';
import 'package:kidly/modal/searchmodal.dart';
import 'package:kidly/modal/storyBooksmodal.dart';
import 'package:kidly/screens/settings_screen.dart';
import 'package:kidly/screens/webview.dart';
import 'package:kidly/utils/connectivity.dart';
import 'package:kidly/utils/constants.dart';
import 'package:kidly/utils/nointernet.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kidly/api/api.dart';
import 'package:kidly/constant/ApiConstant.dart';
import 'package:kidly/modal/subscriptionModal.dart';
import 'package:kidly/modal/userActivitiesModal.dart';
import 'package:kidly/screens/login.dart';
import 'package:kidly/screens/profilescreen.dart';
import 'package:kidly/utils/showcircleprogressdialog.dart';
import 'package:kidly/utils/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/AppColors.dart';
import 'kids_activities_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TextEditingController searchController = TextEditingController();
  ApiConstants apiConstants = ApiConstants();

  List<DashboardListModel> listData = [
    DashboardListModel(
        title: 'Kids Educational\nActivities',
        imagePath: 'assets/images/bg_activities.png',
        bgColor: AppColors.activitiesColorBg,
        imageWidth: 1.0),
    DashboardListModel(
        title: 'Kids Stories',
        imagePath: 'assets/images/bg_stories.png',
        bgColor: AppColors.storiesColorBg,
        imageWidth: 1.0),
    DashboardListModel(
        title: 'Learning the \nbasics',
        imagePath: 'assets/images/bg_learning_basics.png',
        bgColor: AppColors.lBasicsColorBg,
        imageWidth: 1.6),
    DashboardListModel(
        title: 'Look & Choose',
        imagePath: 'assets/images/bg_look_and_choose.png',
        bgColor: AppColors.lookChooseColorBg,
        imageWidth: 1.0),
    DashboardListModel(
        title: 'Listen & Guess',
        imagePath: 'assets/images/bg_listen_guess.png',
        bgColor: AppColors.listenGuessColorBg,
        imageWidth: 1.0),
    DashboardListModel(
        title: 'Kids Preschool \nLearning',
        imagePath: 'assets/images/bg_preschool.png',
        bgColor: AppColors.preSchoolColorBg,
        imageWidth: 1.6),
    DashboardListModel(
        title: 'Kids Drawing',
        imagePath: 'assets/images/bg_kids_drawing.png',
        bgColor: AppColors.drawingColorBg,
        imageWidth: 1.0),
  ];

  String token = '';
  String selectedFlating = '';

  // To get token
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    routeType = prefs.getString('routeType').toString();
    if (prefs.getString('auth_token') != null) {
      setState(() {
        token = prefs.getString('auth_token').toString();
        fetchUserDetails(prefs.getString('auth_token').toString());
        print(token);
      });
    }
    if (prefs.getString('img') != null) {
      setState(() {
        selectedImage = prefs.getString('img').toString();
      });
    }
  }

  bool isLoading = false;
  String selectedImage = '';

// To fetch subscription
  List fetchSubscriptionList = [];

  fetchSubscription() async {
    try {
      var response = await http.get(
        Uri.parse(apiBaseurl + getSubscription),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      log(response.body);
      var dataAll = json.decode(response.body);
      if (dataAll['success'] == true) {
        setState(() {
          fetchSubscriptionList = dataAll['subscriptions'];
        });
      } else {
        showInSnackBar(Colors.red, dataAll['message'], context);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    fetchSubscription();
    getToken();

    Future.delayed(Duration(seconds: 6), () {
      callRateDiloagBox();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
          gravity: ToastGravity.CENTER,
          msg: 'Press again to exit app',
          fontSize: 16);
      return Future.value(false);
    }
    exit(0);
  }

  getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // routeType = prefs.getString('routeType').toString();
    if (prefs.getString('auth_token') != null) {
      fetchUserDetails(prefs.getString('auth_token').toString());
    }
  }

  final RateMyApp rateMyApp = RateMyApp(
      minDays: 0,
      minLaunches: 2,
      remindDays: 7,
      remindLaunches: 10,
      googlePlayIdentifier: 'com.tabschool.kidly');

  callRateDiloagBox() {
    rateMyApp.init().then((value) {
      rateMyApp.conditions.forEach((condition) {
        if (condition is DebuggableCondition) {
          print("condition..${condition.valuesAsString}");
        }
      });
      if (rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(context,
            title: 'Rate this app',
            message:
                "If you like this app, please take a little bit of your time to review it!\nIt really helps us and it shouldn't take you more than one minute.",
            rateButton: 'RATE',
            noButton: "NO THANKS",
            laterButton: "MAYBE LATER",
            dialogStyle: DialogStyle(),
            onDismissed: () =>
                rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    SearchProvider searchProvider = Provider.of<SearchProvider>(context);
    return WillPopScope(
      onWillPop: onWillPop,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: Color(0xffFFDD00),
            image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(
                  'assets/new/bg.png',
                ))),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: !isOnline
              ? noInternet()
              : Column(
                  children: [
                    _appBar(),
                    Expanded(
                      child: ListView.builder(
                          padding: EdgeInsets.all(10),
                          itemCount: listData.length,
                          shrinkWrap: true,
                          itemBuilder: _buildItem),
                    )
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => KidsActivitiesScreen()));
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: listData[index].bgColor,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        margin: EdgeInsets.only(bottom: 10),
        height: MediaQuery.sizeOf(context).width / 2.5,
        width: double.infinity,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                listData[index].title,
                style: TextStyle(color: Colors.white),
              ),
            ).paddingOnly(left: 5),
            Positioned(
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20), // Image border
                  child: Image.asset(
                    listData[index].imagePath,
                    fit: BoxFit.fitWidth,
                    width: MediaQuery.sizeOf(context).width /
                        listData[index].imageWidth,
                  ),
                ))
          ],
        ),
      ),
    );
  }

  _appBar() {
    return Container(
      // height: 110,
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xffFF4980), Color(0xffFFDD00)])),
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).viewPadding.top + 5,
        bottom: 7,
        left: 23.06,
        right: 31,
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/ic_kidly_logo.png',
            height: 45.8,
            width: 156,
          ),
          const Spacer(),
          const SizedBox(
            width: 12,
          ),
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()));
                return;

                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                                fetchSubscriptionList, userInfo, routeType)))
                    .then((value) {
                  setState(() {
                    selectedImage = value.toString();
                  });
                });
              },
              child: Container(
                height: 30,
                width: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0xff00000066),
                          blurRadius: 12,
                          offset: Offset(0, 3)),
                    ],
                    border: Border.all(color: const Color(0xffFFFFFF)),
                    borderRadius: BorderRadius.circular(100)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      'assets/images/ic_settings.png',
                      height: 20,
                      width: 20,
                    )),
              )),
        ],
      ),
    );
  }

  callSubscribedUser(BuildContext context, String id, String transactionId,
      String token) async {
    var body =
        json.encode({'subscription_id': id, 'transaction_id': transactionId});

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
        Navigator.pop(context);
        Navigator.pop(context);
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

  // To fetch user info
  Map userInfo = {};

  fetchUserDetails(authToken) async {
    try {
      var response = await http.get(
        Uri.parse(routeType == 'student'
            ? (studentBaseUrl + studentGetDetails)
            : (apiBaseurl + usergetDetails)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken'
        },
      );
      log(response.body);
      print(response.request);
      var dataAll = json.decode(response.body);
      if (dataAll['success'] == true) {
        userInfo =
            routeType == 'student' ? dataAll['student'] : dataAll['user'];
      } else {
        showInSnackBar(Colors.red, dataAll['message'], context);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
