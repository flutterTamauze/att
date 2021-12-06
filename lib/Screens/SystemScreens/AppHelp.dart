import 'package:flutter/material.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/DisplayHelpVideo.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';

class AppHelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: MultipleFloatingButtons(
          mainTitle: "",
          shiftName: "",
          comingFromShifts: false,
          mainIconData: Icons.add_location_alt,
        ),
        endDrawer: NotificationItem(),
        backgroundColor: Colors.white,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (_) {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Header(
                  goUserHomeFromMenu: false,
                  nav: false,
                  goUserMenu: true,
                ),
                Text(
                  "دليل الأستخدام",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: setResponsiveFontSize(17)),
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      onChanged: (value) {
                        print(value);
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'البحث',
                          prefixIcon: Icon(
                            Icons.search,
                          ),
                          focusColor: Colors.orange,
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.orange[600]))),
                    ),
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Expanded(
                      child: ListView(children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Card(
                        elevation: 2,
                        child: Container(
                          alignment: Alignment.centerRight,
                          width: double.infinity,
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: InkWell(
                              onTap: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => DisplayHelpVideo(),
                                //     ));
                              },
                              child: Row(
                                children: [
                                  Text("شرح التسجيل بالQR",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: setResponsiveFontSize(14))),
                                  Expanded(child: Container()),
                                  Icon(Icons.help)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ])),
                )
              ],
            ),
          ),
        ));
  }
}
