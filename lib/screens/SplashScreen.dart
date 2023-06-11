import 'package:flutter/material.dart';
import 'package:kidly/constant/ScreenConstant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                "assets/images/backgound.png",
                fit: BoxFit.cover,
              )),
          Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Image.asset("assets/images/kidly-logo.png"),
                  ),
                  Material(
                    // needed
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, ScreenConstant.login);
                      }, // needed
                      child: Image.asset("assets/images/splash_button.png"),
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
