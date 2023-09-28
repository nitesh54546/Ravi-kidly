import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget {
  MyAppBar({super.key, this.titleText, this.trailingWidget});

  String? titleText;
  Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 110,
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xffFF4980), Color(0xffFFDD00)])),
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).viewPadding.top + 10,
        bottom: 10,
        left: 10,
        right: 10,
      ),
      child: Row(
        children: [
          GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                  height: 30,
                  width: 30,
                  padding: EdgeInsets.all(5),
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
                        "assets/images/ic_back_arrow.png",
                      )))),
          const Spacer(),
          Text(
            titleText ?? "",
            style: TextStyle(fontSize: 17, color: Colors.white),
          ),
          const Spacer(),
          trailingWidget != null ?trailingWidget!:SizedBox(width: 30),
        ],
      ),
    );
  }
}
