import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool isonline = false;
  bool get isOnline => isonline;

  ConnectivityProvider() {
    Connectivity _connectivity = Connectivity();

    _connectivity.onConnectivityChanged.listen((result) async {
      if (result == ConnectivityResult.none) {
        isonline = false;
        notifyListeners();
      } else {
        isonline = true;
        notifyListeners();
      }
    });
  }
}
