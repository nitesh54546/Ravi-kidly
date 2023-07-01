import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidly/constant/ScreenConstant.dart';
import 'package:kidly/screens/SignUpScreen.dart';
import 'package:kidly/screens/login.dart';
import 'package:kidly/screens/studentlogin.dart';
import 'package:kidly/utils/sharepreference.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/backgound.png'),
              fit: BoxFit.cover)),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset(
                  'assets/images/newlogo.png',
                  // fit: BoxFit.cover,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 4, right: 7),
                  child: Text(
                    'Carefully Designed Activities for Kids',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'ProductSans',
                        color: Color(0xffFFFFFF),
                        shadows: [
                          Shadow(
                            offset: Offset(0, 3),
                            blurRadius: 6,
                            color: Color(0xff0000006B),
                          ),
                        ]),
                  ),
                ),
                const SizedBox(
                  height: 75,
                ),
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setRouteType('signup');
                      Get.to(SignUpScreen('', 'signup', '', '', ''),
                          transition: Transition.noTransition);
                    },
                    child: Image.asset(
                      "assets/new/button.png",
                      height: 60,
                      width: 189,
                      fit: BoxFit.cover,
                    )),
                const SizedBox(
                  height: 15,
                ),
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setRouteType('student');
                      Get.to(const StudentLoginScreen('student'),
                          transition: Transition.noTransition);
                    },
                    child: Image.asset(
                      "assets/new/schoolchild.png",
                      height: 60,
                      width: 189,
                      fit: BoxFit.cover,
                    )),
                const SizedBox(
                  height: 15,
                ),
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setRouteType('login');
                      Get.to(const LoginScreen(),
                          transition: Transition.noTransition);
                    },
                    child: Image.asset(
                      "assets/new/signin.png",
                      height: 60,
                      width: 189,
                      fit: BoxFit.cover,
                    )),
                const Spacer(),
              ],
            ),
          )),
    );
  }
}
