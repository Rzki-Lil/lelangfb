import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/color.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPassword;
  final Icon? prefixIcon;
  final Widget? prefix;
  final double borderRadius;
  final TextInputType keyboardType;
  final double? height;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final int? maxLength;
  final int? maxLines;
  final TextAlignVertical? textAlignVertical;
  final bool expands;
  final List<TextInputFormatter>? inputFormatters;
  final Color? textColor;
  final TextInputAction? textInputAction; // Add this

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.isPassword = false,
    this.prefixIcon,
    this.prefix,
    this.borderRadius = 4.0,
    this.keyboardType = TextInputType.text,
    this.height,
    this.onChanged,
    this.focusNode,
    this.onSubmitted,
    this.maxLength,
    this.maxLines,
    this.textAlignVertical,
    this.expands = false,
    this.textColor,
    this.inputFormatters,
    this.textInputAction, // Add this
  })  : assert(!isPassword || maxLines == null && !expands,
            'Password fields cannot be multiline'),
        super(key: key);

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
    final bool hasValue = widget.controller.text.isNotEmpty;

    return SizedBox(
      height: widget.height,
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        keyboardType: widget.keyboardType,
        focusNode: _focusNode,
        onFieldSubmitted: widget.onSubmitted,
        onChanged: widget.onChanged,
        maxLength: widget.maxLength,
        maxLines: widget.isPassword ? 1 : widget.maxLines,
        expands: widget.expands,
        textAlignVertical: widget.textAlignVertical,
        inputFormatters: widget.inputFormatters,
        style: TextStyle(
          color: widget.textColor ?? AppColors.hijauTua,
          fontFamily: 'MotivaSans',
          fontSize: 15,
        ),
        cursorColor: activeColor,
        textInputAction: widget.textInputAction, // Add this
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: TextStyle(
            color: hasValue || _isFocused ? activeColor : inactiveColor,
            fontFamily: 'MotivaSans',
            fontSize: 15,
          ),
          prefixIcon: widget.prefixIcon != null
              ? IconTheme(
                  data: IconThemeData(
                    color: hasValue || _isFocused ? activeColor : inactiveColor,
                  ),
                  child: widget.prefixIcon!,
                )
              : null,
          prefix: widget.prefix,
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
            borderSide: BorderSide(
              color: hasValue ? activeColor : inactiveColor,
            ),
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
