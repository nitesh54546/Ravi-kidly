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
                  child: passwordTextField(provider),
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

  passwordTextField(StudentProvider provider) {
    return Container(
      height: 53,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(
          // horizontal: 25,
          ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, offset: Offset(2, 2), blurRadius: 10)
          ]),
      alignment: Alignment.centerLeft,
      child: TextField(
        obscureText: provider.isVisible,
        controller: provider.passwordController,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontFamily: productSans, color: Colors.black),
        decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  if (provider.isVisible) {
                    provider.isVisible = false;
                  } else {
                    provider.isVisible = true;
                  }
                });
              },
              child: Icon(
                provider.isVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
                size: 22,
              ),
            ),
            hintText: 'Password',
            hintStyle:
                const TextStyle(fontFamily: productSans, color: Colors.black)),
      ),
    );
  }
}
