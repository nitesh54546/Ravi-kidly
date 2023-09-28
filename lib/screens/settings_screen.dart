import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidly/screens/widgets/my_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MyAppBar(titleText: "Settings"),
          _subscribeWidget(),
          _listItem(image: 'ic_profile.png', title: 'Profile', callback: () {}),
          _listItem(image: 'ic_sound.png', title: 'Sound', callback: () {}),
          _listItem(image: 'ic_thumb.png', title: 'Rate', callback: () {}),
          _listItem(image: 'ic_share.png', title: 'Share', callback: () {}),
          _listItem(
              image: 'ic_privacy_policy.png',
              title: 'Privacy Policy',
              callback: () {}),
        ],
      ),
    );
  }

  _subscribeWidget() {
    return Container(
      color: Colors.red,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Row(
          children: [
            Image.asset(
              "assets/images/ic_people.png",
              height: 30,
            ).marginOnly(right: 15),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SUBSCRIPTION",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                Text(
                  "No Ads! Go Pro",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                )
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios)
          ],
        ),
      ),
    );
  }

  _listItem(
      {required String image,
      required String title,
      required Function() callback}) {
    return Column(
      children: [
        Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey, width: 1)),
                  child: Image.asset(
                    "assets/images/$image",
                    height: 25,
                  ),
                ),
                SizedBox(width: 10,),
                Text(title)
              ],
            ),
          ],
        ).paddingAll(10),
        Divider(
          height: 1,
          thickness: 1,
        )
      ],
    );
  }
}
