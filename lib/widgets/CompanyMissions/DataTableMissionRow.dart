import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/services/UserMissions/CompanyMissions.dart';

class DataTableMissionRow extends StatelessWidget {
  final CompanyMissions _holidays;

  DataTableMissionRow(this._holidays);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              height: 30.h,
              child: Center(
                child: Container(
                  alignment: Alignment.centerRight,
                  height: 30.h,
                  child: AutoSizeText(
                    _holidays.typeId == 4 ? "خارجية" : "داخلية",
                    maxLines: 2,
                    style: TextStyle(
                      fontSize:
                          ScreenUtil().setSp(14, allowFontScalingSelf: true),
                    ),
                  ),
                ),
              )),
          Container(
            height: 35.h,
            child: Center(
              child: Container(
                alignment: Alignment.center,
                height: 20.h,
                child: AutoSizeText(
                  _holidays.fromdate.toString().substring(0, 11),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize:
                        ScreenUtil().setSp(13, allowFontScalingSelf: true),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          _holidays.fromdate.isBefore(_holidays.toDate)
              ? Container(
                  height: 30.h,
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      height: 20.h,
                      child: AutoSizeText(
                        _holidays.toDate.toString().substring(0, 11),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: ScreenUtil()
                              .setSp(13, allowFontScalingSelf: true),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 35.h,
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      height: 20.h,
                      child: AutoSizeText(
                        _holidays.fromdate.toString().substring(0, 11),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: ScreenUtil()
                              .setSp(13, allowFontScalingSelf: true),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
