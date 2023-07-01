import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kidly/api/studentprovider.dart';
import 'package:kidly/helper/customtextfield.dart';
import 'package:kidly/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentLoginScreen extends StatefulWidget {
  final String type;
  const StudentLoginScreen(this.type);

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('routeType').toString());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/backgound.png'),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/newlogo.png",
                  height: 70,
                ),
                const SizedBox(
                  height: 52,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: CustomTextField(
                      hintText: 'Username',
                      controller: provider.userNameController),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: CustomTextField(
                      hintText: 'Password',
                      controller: provider.passwordController),
                ),
                const SizedBox(
                  height: 68,
                ),
                Material(
                  // needed
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      provider.validation(context);
                    }, // needed
                    child: Image.asset("assets/images/submit_button.png"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
