import 'package:flutter/material.dart';

enum ButtonStyle { filled, outlined }

class Button extends StatelessWidget {
  const Button.filled({
    Key? key,
    required this.onPressed,
    required this.label,
    this.color = Colors.blue,
    this.textColor = Colors.white,
    this.width = double.infinity,
    this.height = 50.0,
    this.borderRadius = 4.0,
    this.icon,
    this.disabled = false,
    this.fontSize = 16.0,
  })  : style = ButtonStyle.filled,
        borderColor = Colors.transparent,
        super(key: key);

  const Button.outlined({
    Key? key,
    required this.onPressed,
    required this.label,
    this.color = Colors.white,
    this.textColor = Colors.black,
    this.borderColor = Colors.black,
    this.width = double.infinity,
    this.height = 50.0,
    this.borderRadius = 4.0,
    this.icon,
    this.disabled = false,
    this.fontSize = 14.0,
  })  : style = ButtonStyle.outlined,
        super(key: key);

  final Function() onPressed;
  final String label;
  final ButtonStyle style;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final double width;
  final double height;
  final double borderRadius;
  final Widget? icon;
  final bool disabled;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: style == ButtonStyle.filled
          ? FilledButton(
              onPressed: disabled ? null : onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: _buildButtonContent(),
            )
          : OutlinedButton(
              onPressed: disabled ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: _buildButtonContent(),
            ),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 10.0),
        ],
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: style == ButtonStyle.outlined ? FontWeight.w600 : FontWeight.normal,
            fontFamily: style == ButtonStyle.filled ? 'MotivaSans' : null,
          ),
        ),
      ],
    );
  }
}
