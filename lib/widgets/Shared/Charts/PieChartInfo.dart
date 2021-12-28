import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SinglePieChartItem extends StatelessWidget {
  final String title;
  final Color color;
  final String count;
  const SinglePieChartItem({
    this.title,
    this.color,
    this.count,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180.w,
      child: Row(
        children: [
          AutoSizeText(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(14)),
          ),
          Expanded(
            child: Container(),
          ),
          Text(count),
          const SizedBox(
            width: 5,
          ),
          Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ],
      ),
    );
  }
}
