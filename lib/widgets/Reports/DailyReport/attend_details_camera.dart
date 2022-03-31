import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/Shared/RoundBorderImage.dart';

class AttendDetails {
  showAttendByCameraDetails({
    BuildContext context,
    String timeIn,
    String timeOut,
    DateTime todayDate,
    String normalizedName,
  }) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          final DateTime dateTime = todayDate;
          final DateFormat imageDate = DateFormat('yy/MM/dd');

          // debugPrint(outputFormat.format(dateTime).replaceAll("/", ""));
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Directionality(
                textDirection: ui.TextDirection.rtl,
                child: Stack(
                  children: [
                    Container(
                      height: 180.h,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Container(
                              height: 50.h,
                              child: Center(
                                child: Container(
                                  height: 20.h,
                                  child: AutoSizeText(
                                    getTranslated(context,
                                        "تسجيل ببطاقة التعريف الشخصية"),
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: ScreenUtil().setSp(14,
                                            allowFontScalingSelf: true),
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                timeIn != "-"
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AttendLeaveImageDisplay(
                                              imgUrl:
                                                  '$imageUrl$normalizedName${imageDate.format(dateTime).replaceAll("/", "")}' +
                                                      "A.jpg",
                                              imageDate: imageDate,
                                              dateTime: dateTime),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                          Container(
                                            height: 20,
                                            child: AutoSizeText(
                                              getTranslated(
                                                  context, "تسجيل الحضور"),
                                              maxLines: 1,
                                            ),
                                          )
                                        ],
                                      )
                                    : Container(),
                                timeIn != "-" && timeOut != "-"
                                    ? SizedBox(
                                        width: 30.w,
                                      )
                                    : Container(),
                                timeOut != "-"
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AttendLeaveImageDisplay(
                                              imgUrl:
                                                  '$imageUrl$normalizedName${imageDate.format(dateTime).replaceAll("/", "")}' +
                                                      "L.jpg",
                                              imageDate: imageDate,
                                              dateTime: dateTime),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                          Container(
                                            height: 20,
                                            child: AutoSizeText(
                                              getTranslated(
                                                  context, "تسجيل الانصراف"),
                                              maxLines: 1,
                                            ),
                                          )
                                        ],
                                      )
                                    : Container(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 5.0.w,
                      top: 5.0.h,
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            color: ColorManager.primary,
                            size: ScreenUtil()
                                .setSp(25, allowFontScalingSelf: true),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        });
  }
}

class AttendLeaveImageDisplay extends StatelessWidget {
  const AttendLeaveImageDisplay(
      {Key key,
      @required this.imageDate,
      @required this.dateTime,
      @required this.imgUrl})
      : super(key: key);

  final DateFormat imageDate;
  final DateTime dateTime;
  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 2.w,
          color: const Color(0xffFF7E00),
        ),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 35,
        child: Container(
          width: 80.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: RoundBorderedImageWithoutCache(
              radius: 10, width: 90, height: 95, imageUrl: imgUrl),
        ),
      ),
    );
  }
}
