import 'package:flutter/cupertino.dart';

Widget noInternet() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'No internet connection!',
          style: TextStyle(
              fontSize: 22,
              fontFamily: 'NunitoRegular',
              fontWeight: FontWeight.w600),
        ),
        Text(
          'Please check your internet connection',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'NunitoRegular',
          ),
        )
      ],
    ),
  );
}
