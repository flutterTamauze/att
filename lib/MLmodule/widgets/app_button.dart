import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton(
      {this.onPressed,
      this.text,
      this.color = const Color(0xFF0F0BDB),
      this.icon = const Icon(
        Icons.add,
        color: Colors.white,
      )});
  final Function onPressed;
  final String text;
  final Icon icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AutoSizeText(
              text,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(
              width: 10,
            ),
            icon
          ],
        ),
      ),
    );
  }
}
