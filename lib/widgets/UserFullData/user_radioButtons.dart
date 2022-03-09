import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/Core/colorManager.dart';

class RadioButtonWidg extends StatelessWidget {
  final Function onchannge;
  final int radioVal;
  final String title;
  const RadioButtonWidg({
    this.onchannge,
    this.radioVal,
    this.title,
    @required this.radioVal2,
  });

  final int radioVal2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Radio(
          activeColor: ColorManager.primary,
          value: radioVal,
          groupValue: radioVal2,
          onChanged: (value) {
            onchannge(value);
          },
        ),
        AutoSizeText(title),
      ],
    );
  }
}
