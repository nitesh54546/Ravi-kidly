import 'package:shared_preferences/shared_preferences.dart';

setToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('auth_token', token);
}

setSubscription(String subscription) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('subscription', subscription);
}

setActive(String active) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('active', active);
}

setLogin(bool login) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('login', login);
}

setProfileImage(String img) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('img', img);
}

setFcmToken(String fcmToken) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString("fcmToken", fcmToken);
}
