import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RadioButtonWidg extends StatelessWidget {
  final Function onchannge;
  final int radioVal;
  final String title;
  const RadioButtonWidg({
    this.onchannge,
    this.radioVal,
    this.title,
    Key key,
    @required this.radioVal2,
  }) : super(key: key);

  final int radioVal2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Radio(
          activeColor: Colors.orange,
          value: radioVal,
          groupValue: radioVal2,
          onChanged: (value) {
            onchannge(value);
          },
        ),
        Text(title),
      ],
    );
  }
}
