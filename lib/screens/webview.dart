import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart' as wv;

class FullWebView extends StatefulWidget {
  final String url;
  FullWebView(this.url);

  @override
  State<FullWebView> createState() => _FullWebViewState();
}

class _FullWebViewState extends State<FullWebView> {
  final Completer<wv.WebViewController> controller =
      Completer<wv.WebViewController>();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      // overlays: [SystemUiOverlay.bottom]
    );

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: wv.WebView(
            initialUrl: widget.url,
            zoomEnabled: false,
            onWebViewCreated: (wv.WebViewController webViewController) {
              controller.complete(webViewController);
            },
            javascriptMode: wv.JavascriptMode.unrestricted,
          ),
        ),
      ),
    );
  }
}
