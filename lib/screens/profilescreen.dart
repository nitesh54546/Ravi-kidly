import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kidly/constant/ApiConstant.dart';
import 'package:kidly/modal/subscriptionModal.dart';
import 'package:kidly/modal/userInfoModal.dart';
import 'package:kidly/screens/SignUpScreen.dart';
import 'package:kidly/screens/login.dart';
import 'package:kidly/utils/connectivity.dart';
import 'package:kidly/utils/sharepreference.dart';
import 'package:kidly/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  List fetchSubscriptionList;
  Map userInfo;
  ProfileScreen(this.fetchSubscriptionList, this.userInfo);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController birthDayController = TextEditingController();

  ApiConstants apiConstants = ApiConstants();
  int selectedIndex = -1;

  String token = '';
  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('auth_token') != null) {
      setState(() {
        token = prefs.getString('auth_token').toString();
        print(token);
      });
      if (prefs.getString('img') != null) {
        setState(() {
          selectedImage = prefs.getString('img').toString();
        });
      }
    }
  }

  userInfo() async {
    setState(() {
      if (widget.userInfo['name'] != null) {
        profileDetails.name = widget.userInfo['name'];
      }
      if (widget.userInfo['mobile'] != null) {
        profileDetails.mobile = widget.userInfo['mobile'];
      }
      if (widget.userInfo['subscription'] != null) {
        subcriptionName = widget.userInfo['subscription']['name'].toString();
      }
      if (widget.userInfo['school_name'] != null) {
        profileDetails.schoolName = widget.userInfo['school_name'].toString();
      }

      if (widget.userInfo['dob'] != null) {
        birthDayController.text = widget.userInfo['dob'];
        setState(() {});
      }
    });
  }

  String subcriptionName = '';
  var profileDetails = UserInfoModal();

  List profileImages = [
    'assets/new/Cat.png',
    'assets/new/boy.png',
    'assets/new/chick.png',
    'assets/new/dog.png',
    'assets/new/cupcake.png',
    'assets/new/Girl.png',
    'assets/new/hippo.png',
    'assets/new/unicorn.png',
  ];
  String selectedImage = '';
  String subscriptionId = '';
  late Razorpay razorpay;
  @override
  void initState() {
    super.initState();
    getToken();
    userInfo();

    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void openCheckout(
    String price,
  ) {
    var options = {
      "key": "rzp_test_vtP7FZhZlmmzDf",
      "amount": num.parse(price) * 100,
      // 'account_id': 'acc_IP6e5i9oSjRDkV',
      "name": "Kidly",
      "description": "Payment for the activity subscription",
      // "currency": "INR",
      "prefill": {
        "contact": profileDetails.mobile,
        // "email": 'rraviggupta15@gmail.com'
      },
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print("bmdfkgdf...${e.toString()}");
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
    print("Pament error${response.message}");

    Fluttertoast.showToast(msg: "Pament error");
  }

  void handlerExternalWallet() {
    print("External Wallet");
    Fluttertoast.showToast(msg: "External Wallet");
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final color = isOnline ? Colors.green : Colors.red;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, selectedImage);
        return true;
      },
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover, image: AssetImage('assets/new/bg.png'))),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 20),
                  child: Row(
                    children: [
                      IconButton(
                          splashRadius: 5,
                          onPressed: () {
                            Navigator.pop(context, selectedImage);
                          },
                          icon: const Icon(Icons.arrow_back)),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.clear();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()));
                          },
                          child: Image.asset(
                            'assets/new/logout1.png',
                            height: 48,
                            width: 48,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 44, right: 43, top: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                                height: 155,
                                width: 155,
                                decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0xff00000066),
                                          blurRadius: 12,
                                          offset: Offset(0, 3)),
                                    ],
                                    color: const Color(0xffFFFFFF),
                                    borderRadius: BorderRadius.circular(100)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      selectedImage.isEmpty
                                          ? 'assets/new/Cat.png'
                                          : selectedImage,
                                    ))),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                profileDetails.name != null
                                    ? profileDetails.name.toString()
                                    : '',
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontFamily: 'NunitoRegular',
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              // const Icon(
                              //   Icons.edit,
                              //   size: 17,
                              //   color: Colors.black38,
                              // )
                            ],
                          ),
                          const SizedBox(
                            height: 21,
                          ),
                          const Text(
                            'Choose Profile',
                            style: TextStyle(
                              fontFamily: 'NunitoRegular',
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          GridView.builder(
                              shrinkWrap: true,
                              itemCount: profileImages.length,
                              physics: const ScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 22,
                                      mainAxisSpacing: 28),
                              itemBuilder: (context, index) {
                                return customImage(index, () async {
                                  setState(() {
                                    if (selectedIndex != index) {
                                      selectedIndex = index;
                                      selectedImage = profileImages[index];
                                      setProfileImage(selectedImage);
                                    } else {}
                                  });
                                });
                              }),
                          const SizedBox(
                            height: 28.25,
                          ),
                          textfield(),
                          const SizedBox(
                            height: 27.75,
                          ),
                          changePhoneBtn('CHANGE PHONE', () {
                            if (birthDayController.text.isEmpty) {
                              Fluttertoast.showToast(msg: 'Select your dob');
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpScreen(
                                          birthDayController.text,
                                          'profile',
                                          profileDetails.name.toString(),
                                          profileDetails.mobile.toString(),
                                          profileDetails.schoolName
                                              .toString())));
                            }
                          }),
                          const SizedBox(
                            height: 19,
                          ),
                          subscriptionBtn(
                              'SUBSCRIPTION',
                              subcriptionName.isEmpty
                                  ? 'Free'
                                  : subcriptionName,
                              isOnline,
                              color),
                          const SizedBox(
                            height: 81,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget changePhoneBtn(String title, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: const Color(0xffFF3465),
            borderRadius: BorderRadius.circular(29)),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xffFFFFFF),
            fontFamily: 'NunitoRegular',
          ),
        ),
      ),
    );
  }

  Widget subscriptionBtn(
      String title, String subtitle, bool isOnline, Color color) {
    return GestureDetector(
      onTap: () {
        // openCheckout('120');
        !isOnline
            ? showInSnackBar(
                color, 'Please check internet connection!', context)
            : subcriptionName.isEmpty
                ? showSubscriptionDialog(context)
                : null;
      },
      child: Container(
          height: 58,
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 19, right: 19),
          decoration: BoxDecoration(
              color: const Color(0xffFF3465),
              borderRadius: BorderRadius.circular(29)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xffFFFFFF),
                  fontFamily: 'NunitoRegular',
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xffFFFFFF),
                  fontFamily: 'NunitoRegular',
                ),
              ),
            ],
          )),
    );
  }

  Widget textfield() {
    return Container(
      height: 56,
      decoration: const BoxDecoration(),
      child: TextField(
        controller: birthDayController,
        readOnly: true,
        decoration: InputDecoration(
            labelText: 'Birthday',
            contentPadding: const EdgeInsets.only(left: 18.5),
            labelStyle: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFamily: 'NunitoRegular',
                decoration: TextDecoration.none),
            hintText: "Datepicker",
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'NunitoRegular',
            ),
            suffixIcon: IconButton(
                splashRadius: 1,
                onPressed: () {
                  birthdayPicker();
                },
                icon: const Icon(
                  Icons.date_range,
                  size: 16,
                  color: Colors.black38,
                )),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(width: 1, color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(width: 1, color: Colors.grey)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(width: 1, color: Colors.grey))),
      ),
    );
  }

  Widget customImage(
    int index,
    Function() onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(boxShadow: const [
          BoxShadow(
              color: Color(0xff00000066), blurRadius: 12, offset: Offset(0, 3)),
        ], color: Colors.white, borderRadius: BorderRadius.circular(100)),
        child: Stack(
          children: [
            Align(
                alignment: Alignment.center,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(profileImages[index]))),
            selectedIndex == index
                ? const Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
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
        birthDayController.text = "${selectedDate.year}-$month-$day";
      });
    }
  }

  void showSubscriptionDialog(BuildContext context) {
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
                        fontFamily: 'NunitoRegular',
                        fontSize: 30,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                        decoration: TextDecoration.none),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    "Subscribe to KIDLY & get access of many activities for your child",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
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
                      itemCount: widget.fetchSubscriptionList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        SubscriptionMoal getActivityModal =
                            SubscriptionMoal.fromJson(
                                widget.fetchSubscriptionList[index]);
                        return customBtn(getActivityModal.name.toString(),
                            '₹${getActivityModal.price}', () {
                          setState(() {
                            subscriptionId = getActivityModal.id.toString();
                          });
                          openCheckout(getActivityModal.price.toString());
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
                  fontSize: 18,
                  fontFamily: 'NunitoRegular',
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
}
