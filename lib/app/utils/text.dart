import 'package:flutter/material.dart';
import 'package:lelang_fb/core/constants/color.dart';

class TextCust extends StatelessWidget {
  final double fontSize;
  final Color? color;
  final String text;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  const TextCust({
    super.key,
    required this.text,
    required this.fontSize,
    this.color,
    this.fontWeight,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }
}

class IconC extends StatelessWidget {
  VoidCallback onPressed;
  IconC({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        Icons.camera_alt,
        color: AppColors.hijauMuda,
      ),
    );
  }
}
