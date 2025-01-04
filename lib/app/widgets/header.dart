import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color backgroundColor;
  final double height;

  const Header({
    Key? key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor = AppColors.hijauTua,
    this.height = 65,
  })  : assert(title != null || titleWidget != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (leading != null) leading!,
              Expanded(
                child: Center(
                  child: titleWidget ??
                      Text(
                        title!,
                        style: TextStyle(
                          color: AppColors.hijauTua,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                ),
              ),
              if (actions != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                )
              else
                SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
