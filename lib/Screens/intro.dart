import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import "../services/user_data.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/Screens/SystemScreens/NavSceen.dart';
import 'HomePage.dart';
import 'package:lottie/lottie.dart';
import 'loginScreen.dart';
import 'package:provider/provider.dart';

class PageIntro extends StatefulWidget {
  int userType;
  PageIntro({@required this.userType});

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
      Image(
        image: AssetImage("resources/intro1.webp"),
        fit: BoxFit.fill,
      ),
      Image(
        image: AssetImage("resources/intro2.webp"),
        fit: BoxFit.fill,
      ),
      Image(
        image: AssetImage("resources/intro3.webp"),
        fit: BoxFit.fill,
      ),
      Image(
        image: AssetImage("resources/intro4.webp"),
        fit: BoxFit.fill,
      ),
      Image(
        image: AssetImage("resources/intro5.webp"),
        fit: BoxFit.fill,
      ),
    ];
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
                                      ? Colors.white
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
                            decoration: BoxDecoration(
                              color: Colors.orange[800],
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20)),
                            ),
                            width: MediaQuery.of(context).size.width,
                            height: 60.h,
                            child: Center(
                              child: Container(
                                height: 20,
                                child: AutoSizeText(
                                  Provider.of<UserData>(context, listen: true)
                                          .loggedIn
                                      ? "رجوع"
                                      : "ابدأ",
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 2,
                                      fontSize: ScreenUtil().setSp(17,
                                          allowFontScalingSelf: true),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
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
                                ? "رجوع"
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
