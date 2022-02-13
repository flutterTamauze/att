import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/Reports/Services/Attend_Proof_Model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DisplayAttendProofList extends StatelessWidget {
  const DisplayAttendProofList({this.attendProofList});

  final AttendProofModel attendProofList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
          child: Row(
            children: [
              AutoSizeText(attendProofList.username, style: boldStyle),
              Expanded(
                child: Container(),
              ),
              Container(
                width: 170.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    attendProofList.isAttended
                        ? const Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 27,
                          )
                        : const Icon(
                            FontAwesomeIcons.times,
                            color: Colors.red,
                            size: 25,
                          ),
                    const SizedBox(
                      width: 10,
                    ),
                    AutoSizeText(attendProofList.time, style: boldStyle)
                  ],
                ),
              )
            ],
          ),
        ),
        const Divider()
      ],
    );
  }
}
