import 'package:flutter/material.dart';
import 'package:qr_users/widgets/headers.dart';

class AttendanceSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Header(
              goUserHomeFromMenu: false,
              nav: false,
              goUserMenu: false,
            ),
          ],
        ),
      ),
    );
  }
}
