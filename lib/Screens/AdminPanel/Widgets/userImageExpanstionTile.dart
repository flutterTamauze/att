import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/services/user_data.dart';

class LeadingExpanstionImage extends StatelessWidget {
  const LeadingExpanstionImage({
    Key key,
    @required this.image,
  }) : super(key: key);

  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: ColorManager.primary,
          ),
          shape: BoxShape.circle),
      child: CircleAvatar(
        backgroundImage: NetworkImage(image, headers: {
          "Authorization": "Bearer " +
              Provider.of<UserData>(context, listen: false).user.userToken
        }),
        backgroundColor: Colors.white,
      ),
    );
  }
}
