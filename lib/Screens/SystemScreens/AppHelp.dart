import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:qr_users/widgets/multiple_floating_buttons.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppHelpPage extends StatefulWidget {
  @override
  _AppHelpPageState createState() => _AppHelpPageState();
}

class _AppHelpPageState extends State<AppHelpPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FloatingActionButton(
              onPressed: () => Navigator.pop(context),
              child: Icon(
                Icons.chevron_left,
                color: Colors.black,
              ),
              backgroundColor: Colors.orange[600],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: WebView(
                  initialUrl:
                      "https://chilango.tamauzeds.com/#/sdfhs2340_wsdASDA_SDADASD_A",
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (controller) {
                    setState(() {
                      _controller.complete(controller);
                    });
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
