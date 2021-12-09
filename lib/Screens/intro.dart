import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/constants.dart';
import "../services/user_data.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'HomePage.dart';
import 'loginScreen.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

class PageIntro extends StatefulWidget {
  final int userType;
  PageIntro({this.userType});

  @override
  _PageIntroState createState() => _PageIntroState();
}

Animation<double> animation;

class _PageIntroState extends State<PageIntro> with TickerProviderStateMixin {
  int _currentIndex = 0;

  PageController _controller = PageController();

  @override
  void initState() {
    super.initState();
  }

  _onPageChange(int indx) {
    setState(() {
      _currentIndex = indx;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      IntroContent(
        title: "",
        imageUrl: "resources/introStart.json",
      ),
      IntroContent(
        imageUrl: "resources/intro1.json",
        title:
            "تقدر تسجل حضور و انصراف بمنتهى السهولة عن طريق الكود / البطاقة .",
      ),
      IntroContent(
        title:
            "من حسابك تقدر تقدم على طلب (اذن/اجازة) بكل سهولة و تتابعة و تقدر تتابع حضورك و انصرافك و مناوباتك .",
        imageUrl: "resources/intro2.json",
      ),
      IntroContent(
        title:
            "كمدير تقدر تتابع موظفينك و تقاريرهم و ترد على طلباتهم من اى مكان و فى اى وقت .",
        imageUrl: "resources/intro3.json",
      ),
    ];
    SystemChrome.setEnabledSystemUIOverlays([]);
    return GestureDetector(
      onTap: () =>
          print(Provider.of<UserData>(context, listen: false).loggedIn),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _pages[index];
                  },
                  scrollDirection: Axis.horizontal,
                  controller: _controller,
                  onPageChanged: _onPageChange),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _currentIndex < _pages.length - 1
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              List<Widget>.generate(_pages.length - 1, (index) {
                            return AnimatedContainer(
                              margin: EdgeInsets.only(bottom: 29.h),
                              duration: Duration(milliseconds: 100),
                              height: 12.h,
                              width: index == _currentIndex ? 30.w : 20.w,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: index == _currentIndex
                                      ? Colors.black
                                      : Colors.orange[700]),
                            );
                          }),
                        )
                      : InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Provider.of<UserData>(
                                              context,
                                              listen: false)
                                          .loggedIn
                                      ? Provider.of<UserData>(context,
                                                      listen: false)
                                                  .user
                                                  .userType ==
                                              0
                                          ? HomePage()
                                          : NavScreenTwo(0)
                                      : LoginScreen(),
                                ));
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Center(
                              child: Text(
                                "ابدأ",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            width: 150.w,
                            decoration: BoxDecoration(
                              color: Colors.orange[800],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                  Container(
                    height: 10,
                  )
                ],
              ),
              _currentIndex != _pages.length - 1
                  ? Positioned(
                      right: 20,
                      top: 20.h,
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Provider.of<UserData>(context, listen: true)
                                          .loggedIn
                                      ? Provider.of<UserData>(context,
                                                      listen: false)
                                                  .user
                                                  .userType ==
                                              0
                                          ? HomePage()
                                          : NavScreenTwo(0)
                                      : LoginScreen(),
                            )),
                        child: Container(
                          height: 20,
                          child: AutoSizeText(
                            Provider.of<UserData>(context, listen: true)
                                    .loggedIn
                                ? "إنهاء"
                                : "تخطى",
                            maxLines: 1,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[600]),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class IntroContent extends StatelessWidget {
  const IntroContent({
    this.imageUrl,
    this.title,
    Key key,
  }) : super(key: key);

  final String imageUrl, title;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(bottom: 50.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Stack(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        height: 50.h,
                      ),
                      Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            'resources/image.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                        height: 80.h,
                        width: 70.w,
                      ),
                    ],
                  ),
                  Positioned(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.only(right: 5, top: 5),
                        width: 180.w,
                        height: 45.h,
                        child: Lottie.asset("resources/fire.json",
                            fit: BoxFit.fitWidth),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: 400.w,
              height: 400.h,
              child: Lottie.asset(imageUrl),
            ),
            SizedBox(
              height: 10.h,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ZoomIn(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.orange[600]),
                        borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 10.h),
                      child: title == ""
                          ? FadeIn(
                              child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      ". وداعا لمشاكل الصيانة و الأعطال",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: setResponsiveFontSize(14)),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle),
                                      width: 5,
                                      height: 5,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      ". وداعا لمشاكل الحضور و الأنصراف بالطرق التقليدية",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: setResponsiveFontSize(14)),
                                      textAlign: TextAlign.right,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle),
                                      width: 5,
                                      height: 5,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      ". وداعا للروتين و التأخير",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: setResponsiveFontSize(14)),
                                      textAlign: TextAlign.right,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle),
                                      width: 5,
                                      height: 5,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Directionality(
                                      textDirection: ui.TextDirection.rtl,
                                      child: Text(
                                        "الأن الحضور و الأنصراف اصبح اسهل مع CHILANGO .",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                setResponsiveFontSize(13)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle),
                                      width: 5,
                                      height: 5,
                                    ),
                                  ],
                                ),
                              ],
                            ))
                          : FadeIn(
                              child: Text(title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: setResponsiveFontSize(14),
                                    height: 1.3,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.justify,
                                  textDirection: ui.TextDirection.rtl),
                            ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
