import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDataField extends StatelessWidget {
  final IconData icon;
  final String text;

  UserDataField({this.icon, this.text});

  Widget build(BuildContext context) {
    var phone = {
      Provider.of<MemberData>(context, listen: false)
          .singleMember
          .phoneNumber
          .replaceAll("+", "")
    };
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12, width: 1)),
      height: 35.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 3.h),
              child: InkWell(
                onTap: () {
                  if (icon == Icons.phone) {
                    launch(
                        "tel:${Provider.of<MemberData>(context, listen: false).singleMember.phoneNumber}");
                  }
                },
                child: Icon(
                  icon,
                  color: Colors.orange,
                  size: 19,
                ),
              ),
            ),
            SizedBox(
              width: 15.w,
            ),
            Expanded(
                child: Container(
              height: 20.h,
              child: AutoSizeText(
                text ?? "",
                maxLines: 1,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: ScreenUtil().setSp(12, allowFontScalingSelf: true),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            )),
            if (icon == Icons.phone) ...[
              Container(
                child: IconButton(
                  icon: Icon(FontAwesomeIcons.whatsapp),
                  tooltip: "Open WhatsApp",
                  onPressed: () {
                    launch(
                        "https://api.whatsapp.com/send?phone=${phone}text=Write%20Your%20Message%20Here");
                  },
                  color: Colors.green[600],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class UserDataFieldInReport extends StatelessWidget {
  final IconData icon;
  final String text;

  UserDataFieldInReport({this.icon, this.text});

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12, width: 1)),
      height: 35.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 3.h),
              child: InkWell(
                onTap: () {
                  if (icon == Icons.phone) {
                    launch(
                        "tel:${Provider.of<MemberData>(context, listen: false).singleMember.phoneNumber}");
                  }
                },
                child: Icon(
                  icon,
                  color: Colors.orange,
                  size: 19,
                ),
              ),
            ),
            SizedBox(
              width: 15.w,
            ),
            Expanded(
                child: Container(
              height: 20.h,
              child: Text(
                text ?? "",
                maxLines: 1,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: ScreenUtil().setSp(12, allowFontScalingSelf: true),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
