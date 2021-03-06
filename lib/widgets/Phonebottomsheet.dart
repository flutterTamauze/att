import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhoneBottomSheet extends StatelessWidget {
  const PhoneBottomSheet({
    Key key,
    @required this.icon,
  }) : super(key: key);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: 120.h,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          InkWell(
            onTap: () => launch("tel:+0223521011"),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.green),
                Text(
                  "0223521011",
                  style: TextStyle(
                      letterSpacing: 2,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          InkWell(
            onTap: () => launch("tel:0223521010"),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.green),
                Text(
                  "0223521010",
                  style: TextStyle(
                      letterSpacing: 2,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
