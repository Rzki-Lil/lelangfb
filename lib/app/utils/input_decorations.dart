import 'package:flutter/material.dart';
import '../../core/constants/color.dart';

class CustomInputDecoration {
  static InputDecoration buildInputDecoration({
    required String labelText,
    required IconData icon,
    required bool hasValue,
    double borderRadius = 4.0,
  }) {
    final Color activeColor = AppColors.hijauTua;
    final Color inactiveColor = Colors.grey;

    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: hasValue ? activeColor : inactiveColor,
        fontSize: 15,
      ),
      prefixIcon: Icon(
        icon,
        color: hasValue ? activeColor : inactiveColor,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: inactiveColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: hasValue ? activeColor : inactiveColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: activeColor, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }

  static InputDecoration buildDropdownSearchDecoration({
    required String labelText,
    required IconData icon,
    required bool hasValue,
    double borderRadius = 4.0,
  }) {
    final Color activeColor = AppColors.hijauTua;
    final Color inactiveColor = Colors.grey;

    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: hasValue ? activeColor : inactiveColor,
        fontSize: 15,
      ),
      prefixIcon: Icon(
        icon,
        color: hasValue ? activeColor : inactiveColor,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: inactiveColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: hasValue ? activeColor : inactiveColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: activeColor, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }

  static BoxDecoration buildImageContainerDecoration({
    required bool hasImages,
    double borderRadius = 8.0,
  }) {
    final Color activeColor = AppColors.hijauTua;
    final Color inactiveColor = Colors.grey;

    return BoxDecoration(
      border: Border.all(
        color: hasImages ? activeColor : inactiveColor,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }
}

class CustomTimePickerTile extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDefaultValue;

  const CustomTimePickerTile({
    Key? key,
    required this.label,
    required this.time,
    required this.icon,
    required this.onTap,
    required this.isDefaultValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDefaultValue ? Colors.grey.shade300 : AppColors.hijauTua,
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
            leading: Icon(
              icon,
              color: isDefaultValue ? Colors.grey : AppColors.hijauTua,
            ),
            title: Text(
              time,
              style: TextStyle(color: AppColors.hijauTua),
            ),
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}
