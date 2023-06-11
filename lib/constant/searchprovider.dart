import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kidly/api/api.dart';
import 'package:kidly/utils/snackbar.dart';

class SearchProvider extends ChangeNotifier {
  List searchList = [];
  String text = '';
  bool isSearchData = false;
  bool notfound = false;

  changeSearchStatus(bool value) {
    isSearchData = value;
    print(isSearchData);
    notifyListeners();
  }

  changeNotFoundStatus(bool value) {
    notfound = value;
    print(notfound);
    notifyListeners();
  }

  callSearchApi(BuildContext context, String token, String text) async {
    try {
      var response = await http.get(
        Uri.parse(baseurl + searchApi + text),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      log(response.body);
      notifyListeners();
      var dataAll = json.decode(response.body);
      if (dataAll['success'] == true) {
        Navigator.pop(context);
        notfound = false;
        isSearchData = true;
        searchList = dataAll['activities'];
        notifyListeners();
        showInSnackBar(Colors.green, dataAll['message'], context);
      } else {
        Navigator.pop(context);
        text = dataAll['message'];
        notfound = true;
        isSearchData = false;
        notifyListeners();
        showInSnackBar(Colors.red, dataAll['message'], context);
      }
    } catch (e) {
      Navigator.pop(context);
      print(e.toString());
    }
  }
}
