import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;

  const ProfileAvatar({
    Key? key,
    this.imageUrl,
    this.radius = 30,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.white,
      backgroundImage:
          imageUrl != null ? CachedNetworkImageProvider(imageUrl!) : null,
      child: imageUrl == null
          ? Icon(
              Icons.person,
              size: radius * 0.8,
              color: Colors.grey[400],
            )
          : null,
    );
  }
}
