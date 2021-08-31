import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';

class DataTablePermessionRow extends StatelessWidget {
  final UserPermessions permessions;

  DataTablePermessionRow(this.permessions);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 160.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20.h,
                    child: AutoSizeText(
                      permessions.user,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: ScreenUtil()
                              .setSp(14, allowFontScalingSelf: true),
                          fontWeight: FontWeight.w300,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                        height: 30.h,
                        child: Center(
                          child: Container(
                            alignment: Alignment.center,
                            height: 30.h,
                            child: AutoSizeText(
                              permessions.permessionType == 1
                                  ? "تأخير عن الحضور"
                                  : "انصراف مبكر",
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: ScreenUtil()
                                    .setSp(14, allowFontScalingSelf: true),
                              ),
                            ),
                          ),
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(right: 10.w),
                      height: 35.h,
                      child: Center(
                        child: Container(
                          alignment: Alignment.center,
                          height: 20.h,
                          child: AutoSizeText(
                            permessions.date.toString(),
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: ScreenUtil()
                                  .setSp(14, allowFontScalingSelf: true),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(right: 20.w),
                      height: 30.h,
                      child: Center(
                        child: Container(
                          alignment: Alignment.center,
                          height: 20.h,
                          child: AutoSizeText(
                            permessions.duration,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: ScreenUtil()
                                  .setSp(14, allowFontScalingSelf: true),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
