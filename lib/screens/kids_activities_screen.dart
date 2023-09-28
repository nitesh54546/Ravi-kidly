import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kidly/modal/userActivitiesModal.dart';
import 'package:kidly/screens/webview.dart';
import 'package:kidly/screens/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../api/api.dart';
import '../constant/ApiConstant.dart';
import '../modal/subscriptionModal.dart';
import '../utils/connectivity.dart';
import '../utils/constants.dart';
import '../utils/nointernet.dart';
import '../utils/showcircleprogressdialog.dart';
import '../utils/snackbar.dart';

class KidsActivitiesScreen extends StatefulWidget {
  const KidsActivitiesScreen({super.key});

  @override
  State<KidsActivitiesScreen> createState() => _KidsActivitiesScreenState();
}

class _KidsActivitiesScreenState extends State<KidsActivitiesScreen> {
  ApiConstants apiConstants = ApiConstants();

  String token = '';
  bool isLoading = false;
  String selectedImage = '';
  String subscriptionId = '';
  late Razorpay razorpay;
  Map userInfo = {};

// To fetch user Activities
  List userActivities = [];
  List fetchSubscriptionList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init(){
    fetchSubscription();
    getToken();

    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);

  }

  @override
  void dispose() {
    super.dispose();
  }

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

  // To get token
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    routeType = prefs.getString('routeType').toString();
    if (prefs.getString('auth_token') != null) {
      setState(() {
        token = prefs.getString('auth_token').toString();
        fetchUserActivities(prefs.getString('auth_token').toString());
        print(token);
      });
    }
    if (prefs.getString('img') != null) {
      setState(() {
        selectedImage = prefs.getString('img').toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;

    return Scaffold(
      body: Column(children: [
        MyAppBar(titleText: "Kids Activities",),
        Expanded(child:!isOnline
            ? noInternet()
            :  Column(children: [
          activityWidget()

        ],))
      ],),
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


  void openCheckout(
      String price,
      ) {
    //  rzp_test_vtP7FZhZlmmzDf
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



}
