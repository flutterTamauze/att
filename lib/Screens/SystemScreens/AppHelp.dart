import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import 'package:webview_flutter/webview_flutter.dart';

class AppHelpPage extends StatefulWidget {
  @override
  _AppHelpPageState createState() => _AppHelpPageState();
}

class _AppHelpPageState extends State<AppHelpPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    isLoading = true;
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  int currentProgress = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: MultipleFloatingButtonsNoADD(),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: WebView(
                  onProgress: (int progress) {
                    setState(() {
                      currentProgress = progress;
                    });
                    debugPrint('WebView is loading (progress : $progress%)');
                  },
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
              Positioned(
                  top: MediaQuery.of(context).size.height / 2,
                  right: MediaQuery.of(context).size.width / 3.4,
                  child: currentProgress != 100
                      ? Column(
                          children: [
                            AutoSizeText(
                              "جارى تحميل الصفحة %$currentProgress",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: setResponsiveFontSize(17)),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              height: 10,
                            ),
                            CircularProgressIndicator(
                              backgroundColor: Colors.orange,
                            )
                          ],
                        )
                      : Container())
            ],
          ),
        ));
  }
}
