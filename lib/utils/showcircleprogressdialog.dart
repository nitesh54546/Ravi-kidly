import 'package:flutter/material.dart';
import 'package:kidly/utils/customcircledialog.dart';

showCircleProgressDialog(BuildContext context) async {
  return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          child: CustomCircularProgressIndicator(),
          onWillPop: () async {
            return false;
          },
        );
      });
}
