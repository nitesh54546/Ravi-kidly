import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:kidly/constant/AppConstant.dart';
import 'package:kidly/constant/searchprovider.dart';
import 'package:kidly/modal/rhymsmodal.dart';
import 'package:kidly/modal/searchmodal.dart';
import 'package:kidly/modal/storyBooksmodal.dart';
import 'package:kidly/screens/webview.dart';
import 'package:kidly/utils/connectivity.dart';
import 'package:kidly/utils/constants.dart';
import 'package:kidly/utils/nointernet.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kidly/api/api.dart';
import 'package:kidly/constant/ApiConstant.dart';
import 'package:kidly/modal/subscriptionModal.dart';
import 'package:kidly/modal/userActivitiesModal.dart';
import 'package:kidly/screens/login.dart';
import 'package:kidly/screens/profilescreen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:kidly/utils/showcircleprogressdialog.dart';
import 'package:kidly/utils/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TextEditingController searchController = TextEditingController();
  ApiConstants apiConstants = ApiConstants();

  int selectTabBar = 0;
  String token = '';
  String selectedFlating = '';

  // To get token
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    routeType = prefs.getString('routeType').toString();
    if (prefs.getString('auth_token') != null) {
      setState(() {
        token = prefs.getString('auth_token').toString();
        fetchUserActivities(prefs.getString('auth_token').toString());
        fetchUserDetails(prefs.getString('auth_token').toString());
        fetchRhymsActivities(prefs.getString('auth_token').toString());
        fetchStoryBooksActivities(prefs.getString('auth_token').toString());
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
// To fetch user Activities
  List userActivities = [];
  fetchUserActivities(String authToken) async {
    try {
      setState(() {
        isLoading = true;
      });
      showCircleProgressDialog(context);
      var response = await http.get(
        Uri.parse(routeType == 'student'
            ? (studentBaseUrl + studentActivity)
            : (apiBaseurl + userActivity)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken'
        },
      );
      log(response.body);
      var dataAll = json.decode(response.body);
      if (dataAll['success'] == true) {
        Navigator.pop(context);
        setState(() {
          userActivities = dataAll['activities'];
          isLoading = false;
        });
      } else {
        showInSnackBar(Colors.red, dataAll['message'], context);
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }

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

//Razorpay payment getway
  String subscriptionId = '';
  late Razorpay razorpay;

  void openCheckout(
    String price,
  ) {
    var options = {
      "key": "rzp_live_2Z3YfTFWf0WiTN",
      "amount": num.parse(price) * 100,
      "name": "Kidly",
      "description": "Payment for the activity subscription",
      "prefill": {
        "contact": userInfo['mobile'].toString(),
        // "email": 'rraviggupta15@gmail.com'
      },
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void handlerPaymentSuccess(
    PaymentSuccessResponse response,
  ) async {
    print("Pament success${response.orderId}");
    print("payment id...${response.paymentId}");
    apiConstants.callSubscribedUser(context, subscriptionId.toString(),
        response.paymentId.toString(), token);
    Fluttertoast.showToast(msg: "Pament success");
  }

  void handlerErrorFailure(PaymentFailureResponse response) async {
    print("Pament error");

    Fluttertoast.showToast(msg: "Pament error");
  }

  void handlerExternalWallet() {
    print("External Wallet");
    Fluttertoast.showToast(msg: "External Wallet");
  }

  @override
  void initState() {
    fetchSubscription();
    getToken();
    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
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

  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // routeType = prefs.getString('routeType').toString();
    if (prefs.getString('auth_token') != null) {
      fetchUserDetails(prefs.getString('auth_token').toString());
    }
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
                    Container(
                      height: 110,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Color(0xffFF4980), Color(0xffFFDD00)])),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(
                        bottom: 7,
                        left: 23.06,
                        right: 31,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/newlogo.png',
                            height: 45.8,
                            width: 156,
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              searchBox(searchProvider);
                            },
                            child: Container(
                                height: 59,
                                width: 59,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    // shape: BoxShape.circle,
                                    borderRadius: BorderRadius.circular(100)),
                                alignment: Alignment.center,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.asset(
                                    'assets/images/search (2).jpeg',
                                    height: 30,
                                    width: 30,
                                  ),
                                )),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                            fetchSubscriptionList,
                                            userInfo,
                                            routeType))).then((value) {
                                  setState(() {
                                    selectedImage = value.toString();
                                  });
                                });
                              },
                              child: Container(
                                height: 59,
                                width: 59,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0xff00000066),
                                          blurRadius: 12,
                                          offset: Offset(0, 3)),
                                    ],
                                    border: Border.all(
                                        color: const Color(0xffFFFFFF)),
                                    borderRadius: BorderRadius.circular(100)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(selectedImage.isEmpty
                                        ? 'assets/new/Cat.png'
                                        : selectedImage)),
                              )),
                        ],
                      ),
                    ),
                    searchProvider.isSearchData == true
                        ? searchWidget(searchProvider)
                        : Expanded(
                            child: Column(
                              children: [
                                tabBar(),
                                selectedFlating == 'story'
                                    ? storyBooksWidget()
                                    : activityWidget()
                              ],
                            ),
                          )
                    // searchProvider.isSearchData == true ||
                    //         selectedFlating == 'rhyms'
                    //     ? Container()
                    //     : tabBar(),
                    // searchProvider.notfound == true
                    //     ? Container()
                    //     : searchProvider.isSearchData == true
                    //         ? searchWidget(searchProvider)
                    //         : selectedFlating == 'rhyms'
                    //             ? rhymsWidget()
                    //             : selectedFlating == 'story'
                    //                 ? storyBooksWidget()
                    //                 : activityWidget()
                  ],
                ),
        ),
      ),
    );
  }

  tabBar() {
    return Container(
      height: 51,
      margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(31),
          border: Border.all(color: tabBorderColor, width: 2),
          gradient: LinearGradient(
            colors: [grade1, grade2],
            tileMode: TileMode.clamp,
            begin: const Alignment(-1.0, -0.0),
            end: const Alignment(1.0, 0.0),
            transform: const GradientRotation(math.pi / 2),

            // tileMode: TileMode.repeated,
          )),
      child: Row(
        children: [
          Flexible(
            child: InkWell(
              onTap: () {
                setState(() {
                  selectTabBar = 0;
                  selectedFlating = 'home';
                });
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: selectTabBar == 0 ? Colors.white : null,
                      borderRadius: BorderRadius.circular(31)),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      selectTabBar == 0
                          ? Image.asset(
                              'assets/images/activities.jpeg',
                              width: 24,
                              height: 24,
                            )
                          : Container(),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Activities',
                        style: TextStyle(
                            fontFamily: arialRounded,
                            color: selectTabBar == 0 ? redColor : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  )),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: InkWell(
              onTap: () {
                setState(() {
                  selectTabBar = 1;
                  selectedFlating = 'story';
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    color: selectTabBar == 1 ? Colors.white : null,
                    borderRadius: BorderRadius.circular(31)),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    selectTabBar == 1
                        ? Image.asset(
                            'assets/images/stories.jpeg',
                            width: 24,
                            height: 24,
                          )
                        : Container(),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Stories',
                      style: TextStyle(
                          fontFamily: arialRounded,
                          color: selectTabBar == 1 ? redColor : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  searchWidget(SearchProvider searchProvider) {
    return Expanded(
      child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: searchProvider.searchList.isEmpty
              ? const Center(
                  child: Text("No Activities"),
                )
              : GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: searchProvider.searchList.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(
                      left: 19, right: 23, bottom: 10, top: 13),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 38,
                      mainAxisSpacing: 34,
                      childAspectRatio: 1 / .8),
                  itemBuilder: (context, index) {
                    SearchModal searchModal =
                        SearchModal.fromJson(searchProvider.searchList[index]);
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FullWebView(
                                    searchModal.url.toString()))).then((value) {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown
                          ]);
                        });
                      },
                      child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0xff00000029),
                                    offset: Offset(0, 3))
                              ],
                              border:
                                  Border.all(color: const Color(0xffD3D3D3)),
                              // color: Colors.green,
                              borderRadius: BorderRadius.circular(20)),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FullWebView(
                                              searchModal.url.toString())))
                                  .then((value) {
                                SystemChrome.setPreferredOrientations([
                                  DeviceOrientation.portraitUp,
                                  DeviceOrientation.portraitDown
                                ]);
                              });
                            },
                            child: Stack(
                              children: [
                                Positioned(
                                    top: 0,
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20)),
                                        child: FadeInImage.assetNetwork(
                                          placeholder:
                                              'assets/images/sample_list_image.jpeg',
                                          // placeholderFit: BoxFit.fill,
                                          fadeInCurve: Curves.easeInOut,
                                          fadeOutCurve: Curves.bounceInOut,
                                          image: searchModal.image.toString(),
                                          fit: BoxFit.cover,
                                        ))),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20)),
                                        color: Colors.black54),
                                    child: Center(
                                        child: Text(
                                      searchModal.name.toString(),
                                      style: const TextStyle(
                                          fontFamily: 'NunitoRegular',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    );
                  })),
    );
  }

  storyBooksWidget() {
    return Expanded(
      child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: storyBooksList.isEmpty
              ? const Center(
                  child: Text("No StoryBooks Activities"),
                )
              : GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: storyBooksList.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(
                      left: 19, right: 23, bottom: 10, top: 13),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 38,
                      mainAxisSpacing: 34,
                      childAspectRatio: 1 / .8),
                  itemBuilder: (context, index) {
                    StoryBooksModal storyBooksModal =
                        StoryBooksModal.fromJson(storyBooksList[index]);
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FullWebView(
                                        storyBooksModal.url.toString())))
                            .then((value) {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown
                          ]);
                        });
                      },
                      child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xff00000029),
                                    offset: Offset(0, 3))
                              ],
                              border:
                                  Border.all(color: const Color(0xffD3D3D3)),
                              // color: Colors.green,
                              borderRadius: BorderRadius.circular(20)),
                          child: Stack(
                            children: [
                              Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                      child: FadeInImage.assetNetwork(
                                        placeholder:
                                            'assets/images/sample_list_image.jpeg',
                                        // placeholderFit: BoxFit.fill,
                                        fadeInCurve: Curves.easeInOut,
                                        fadeOutCurve: Curves.bounceInOut,
                                        image: storyBooksModal.image.toString(),
                                        fit: BoxFit.cover,
                                      ))),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(20)),
                                      color: Colors.black54),
                                  child: Center(
                                      child: Text(
                                    storyBooksModal.name.toString(),
                                    style: const TextStyle(
                                        fontFamily: 'NunitoRegular',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  )),
                                ),
                              ),
                            ],
                          )),
                    );
                  })),
    );
  }

  activityWidget() {
    return Expanded(
      child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: userActivities.isEmpty
              ? const Center(
                  child: Text("No Activities"),
                )
              : GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: userActivities.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(
                      left: 19, right: 23, bottom: 10, top: 13),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 38,
                      mainAxisSpacing: 34,
                      childAspectRatio: 1 / .8),
                  itemBuilder: (context, index) {
                    UserActivitiesModal userActivitiesModal =
                        UserActivitiesModal.fromJson(userActivities[index]);
                    return InkWell(
                      onTap: () {
                        userActivitiesModal.isLocked == 0
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FullWebView(
                                        userActivitiesModal.url
                                            .toString()))).then((value) {
                                SystemChrome.setPreferredOrientations([
                                  DeviceOrientation.portraitUp,
                                  DeviceOrientation.portraitDown
                                ]);
                                SystemChrome.setEnabledSystemUIMode(
                                  SystemUiMode.edgeToEdge,
                                  // overlays: [SystemUiOverlay.top]
                                );
                              })
                            : _showSubscriptionDialog(context);
                      },
                      child: Stack(
                        children: [
                          Container(
                              height: 125,
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xff00000029),
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                  border: Border.all(
                                      color: const Color(0xffD3D3D3)),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Stack(
                                children: [
                                  Positioned(
                                      top: 0,
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                              bottomLeft: Radius.circular(20),
                                              bottomRight: Radius.circular(20)),
                                          child: FadeInImage.assetNetwork(
                                            placeholder:
                                                'assets/images/sample_list_image.jpeg',
                                            placeholderFit: BoxFit.fill,
                                            fadeInCurve: Curves.easeInOut,
                                            fadeOutCurve: Curves.bounceInOut,
                                            image: userActivitiesModal.image
                                                .toString(),
                                            fit: BoxFit.fitWidth,
                                          ))),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: () {
                                        userActivitiesModal.isLocked == 0
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FullWebView(
                                                            userActivitiesModal
                                                                .url
                                                                .toString()))).then(
                                                (value) {
                                                SystemChrome
                                                    .setPreferredOrientations([
                                                  DeviceOrientation.portraitUp,
                                                  DeviceOrientation.portraitDown
                                                ]);
                                                SystemChrome
                                                    .setEnabledSystemUIMode(
                                                  SystemUiMode.edgeToEdge,
                                                  // overlays: [SystemUiOverlay.top]
                                                );
                                              })
                                            : _showSubscriptionDialog(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(20),
                                                bottomLeft:
                                                    Radius.circular(20)),
                                            color: Colors.black54),
                                        child: Center(
                                            child: Text(
                                          userActivitiesModal.name.toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'NunitoRegular',
                                              fontWeight: FontWeight.w600),
                                        )),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          userActivitiesModal.isLocked == 0
                              ? Container()
                              : Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(boxShadow: [
                                        BoxShadow(
                                          color: Colors.white70,
                                          offset: Offset(0, 0),
                                        )
                                      ]),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          height: 73,
                                          width: 73,
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(100)),
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            'assets/new/lock.png',
                                            height: 50,
                                            width: 50,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                        ],
                      ),
                    );
                  })),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            // height: 394,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.only(top: 17, left: 20, right: 19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Oops!",
                    style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'NunitoRegular',
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    "Subscribe to KIDLY & get access of many activities for your child",
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff000000),
                        fontFamily: 'NunitoRegular',
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  ListView.separated(
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: 7,
                        );
                      },
                      itemCount: fetchSubscriptionList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        SubscriptionMoal getActivityModal =
                            SubscriptionMoal.fromJson(
                                fetchSubscriptionList[index]);
                        return customBtn(getActivityModal.name.toString(),
                            '₹${getActivityModal.price}', () {
                          setState(() {
                            subscriptionId = getActivityModal.id.toString();
                          });
                          openCheckout(getActivityModal.price.toString());
                          // apiConstants.callSubscribedUser(
                          //     context,
                          //     getActivityModal.id.toString(),
                          //     'trcgscsd765s7csc',
                          //     token);
                        });
                      }),
                  const SizedBox(
                    height: 29,
                  )
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: const Offset(0, 1), end: Offset.zero);
        } else {
          tween = Tween(begin: const Offset(0, 1), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  accountSheet() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        context: context,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(color: Color(0xff00000029), offset: Offset(-3, -3))
            ]),
            padding:
                const EdgeInsets.only(top: 35, left: 20, right: 15, bottom: 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                                fetchSubscriptionList,
                                userInfo,
                                routeType))).then((value) {
                      setState(() {
                        selectedImage = value.toString();
                      });
                    });
                  },
                  child: Row(
                    children: const [
                      Icon(
                        Icons.settings,
                        color: Colors.black45,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Account',
                        style: TextStyle(
                            fontFamily: 'NunitoRegular',
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.clear();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  },
                  child: Row(
                    children: const [
                      Icon(
                        Icons.logout,
                        color: Colors.black45,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Logout',
                        style: TextStyle(
                            fontFamily: 'NunitoRegular',
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 18),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  void searchDialg(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            // height: 394,

            // margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.only(top: 22, left: 23, right: 19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Search',
                    style: TextStyle(
                      fontFamily: 'NunitoRegular',
                      color: Color(0xff000000),
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: const Offset(0, 1), end: Offset.zero);
        } else {
          tween = Tween(begin: const Offset(0, 1), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  searchBox(SearchProvider searchProvider) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Search",
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'NunitoRegular',
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  height: 47,
                  padding: const EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(width: 1, color: Colors.grey.shade600)),
                  child: TextFormField(
                    controller: searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontFamily: 'NunitoRegular',
                        ),
                        hintText: 'What you want to search...'),
                    onChanged: (val) {},
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                GestureDetector(
                  onTap: () {
                    if (searchController.text.isEmpty) {
                      searchProvider.isSearchData = false;
                      setState(() {});
                    }
                    searchProvider.callSearchApi(
                        context, token, searchController.text, routeType);
                  },
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 19, right: 19),
                    decoration: BoxDecoration(
                        color: const Color(0xffFF3465),
                        borderRadius: BorderRadius.circular(29)),
                    child: const Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xffFFFFFF),
                        fontFamily: 'NunitoRegular',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget customBtn(String title, String price, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 63,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient:
                LinearGradient(colors: [Color(0xffFFDD00), Color(0xffFF4980)]),
            border: Border.all(color: const Color(0xffEA0047), width: 1)),
        padding: const EdgeInsets.only(left: 23, right: 23),
        alignment: Alignment.center,
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontFamily: 'NunitoRegular',
                  fontSize: 18,
                  color: Color(0xffFFFFFF),
                  decoration: TextDecoration.none),
            ),
            const Spacer(),
            Text(
              price,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'NunitoRegular',
                  color: const Color(0xffFFFFFF).withOpacity(1),
                  decoration: TextDecoration.none),
            )
          ],
        ),
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
        setState(() {
          fetchUserActivities(token);
        });
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

// fetch rhyms
  List rhymsList = [];
  fetchRhymsActivities(String authToken) async {
    try {
      var response = await http.get(
        Uri.parse(routeType == 'student'
            ? (studentBaseUrl + studentRhymsApi)
            : (apiBaseurl + rhymsApi)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken'
        },
      );
      log(response.body);
      var dataAll = json.decode(response.body);
      if (dataAll['success'] == true) {
        setState(() {
          rhymsList = dataAll['rhyms'];
        });
      } else {
        showInSnackBar(Colors.red, dataAll['message'], context);
      }
    } catch (e) {
      print(e.toString());
    }
  }

// fetch storyBooks
  List storyBooksList = [];
  fetchStoryBooksActivities(String authToken) async {
    try {
      var response = await http.get(
        Uri.parse(routeType == 'student'
            ? (studentBaseUrl + studentStoryBooksApi)
            : (apiBaseurl + storyBooksApi)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken'
        },
      );
      log(response.body);
      var dataAll = json.decode(response.body);
      if (dataAll['success'] == true) {
        setState(() {
          storyBooksList = dataAll['story_books'];
        });
      } else {
        showInSnackBar(Colors.red, dataAll['message'], context);
      }
    } catch (e) {
      print(e.toString());
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
