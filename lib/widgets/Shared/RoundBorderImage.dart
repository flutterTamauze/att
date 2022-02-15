import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/services/user_data.dart';

class RoundBorderedImage extends StatelessWidget {
  final String imageUrl;
  final double radius, width, height;
  const RoundBorderedImage({
    this.imageUrl,
    this.radius,
    this.width,
    this.height,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: MediaQuery.of(context).size.height / radius,
      child: Container(
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: const Color(0xffFF7E00),
          ),
          shape: BoxShape.circle,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(75.0),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            httpHeaders: {
              "Authorization": "Bearer " +
                  Provider.of<UserData>(context, listen: false).user.userToken
            },
            fit: BoxFit.cover,
            placeholder: (context, url) => Platform.isIOS
                ? const CupertinoActivityIndicator(
                    radius: 20,
                  )
                : const CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
            errorWidget: (context, url, error) =>
                Provider.of<UserData>(context, listen: true).changedWidget,
          ),
        ),
      ),
    );
  }
}

class RoundBorderedImageWithoutCache extends StatelessWidget {
  final String imageUrl;
  final double radius, width, height;
  const RoundBorderedImageWithoutCache({
    this.imageUrl,
    this.radius,
    this.width,
    this.height,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        backgroundColor: Colors.white,
        radius: MediaQuery.of(context).size.height / radius,
        child: Container(
          width: width.w,
          height: height.h,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: const Color(0xffFF7E00),
            ),
            shape: BoxShape.circle,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(75.0),
            child: Image(
                image: NetworkImage(
                  imageUrl,
                  headers: {
                    "Authorization": "Bearer " +
                        Provider.of<UserData>(context, listen: false)
                            .user
                            .userToken
                  },
                ),
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                        color: ColorManager.primary,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes
                            : null),
                  );
                }),
          ),
        ));
  }
}
