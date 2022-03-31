import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/loginScreen.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InheritDefault {
  login(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> userData = (prefs.getStringList('userData') ?? null);

    if (userData == null || userData.isEmpty) {
      debugPrint('null');
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      debugPrint('not null');
      await Provider.of<UserData>(context, listen: false)
          .loginPost(userData[0], userData[1], context, true);
    }
  }
}
