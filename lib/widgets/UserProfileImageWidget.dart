import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/services/user_data.dart';

class UserPrfileImageWidget extends StatelessWidget {
  const UserPrfileImageWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.w,
      height: 70.h,
      decoration: BoxDecoration(
          border: Border.all(width: 2, color: Colors.orange),
          borderRadius: BorderRadius.circular(70.w)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(70.w),
        child: CachedNetworkImage(
            httpHeaders: {
              "Authorization": "Bearer " +
                  Provider.of<UserData>(context, listen: false).user.userToken
            },
            placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.orange)),
                ),
            fit: BoxFit.cover,
            imageUrl:
                Provider.of<UserData>(context, listen: false).user.userImage),
      ),
    );
  }
}
