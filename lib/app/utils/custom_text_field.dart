import 'package:flutter/material.dart';
import '../../../../core/constants/color.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPassword;
  final Icon? prefixIcon;
  final double borderRadius;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final double? height;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.isPassword = false,
    this.prefixIcon,
    this.borderRadius = 4.0,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.height,
    this.onChanged,
    this.focusNode,
    this.onSubmitted,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppColors.hijauTua;
    final Color inactiveColor = Colors.grey;

    return SizedBox(
      height: widget.height,
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        focusNode: _focusNode,
        onFieldSubmitted: widget.onSubmitted,
        onChanged: widget.onChanged,
        style: TextStyle(
          color: AppColors.hijauTua,
          fontFamily: 'MotivaSans',
          fontSize: 15,
        ),
        cursorColor: activeColor,
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: TextStyle(
            color: _isFocused ? activeColor : inactiveColor,
            fontFamily: 'MotivaSans',
            fontSize: 15,
          ),
          prefixIcon: widget.prefixIcon != null
              ? IconTheme(
                  data: IconThemeData(
                    color: _isFocused ? activeColor : inactiveColor,
                  ),
                  child: widget.prefixIcon!,
                )
              : null,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: _isFocused ? activeColor : inactiveColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: inactiveColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: inactiveColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: activeColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
