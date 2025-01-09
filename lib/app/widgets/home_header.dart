import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:lelang_fb/core/constants/color.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final Function(int) onPageChange;

  final VoidCallback onNotificationTap;
  final int notificationCount;

  const HomeHeader({
    Key? key,
    required this.onPageChange,
    required this.onNotificationTap,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
      ),
      pinned: false,
      leadingWidth: 50,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () => onPageChange(4),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final userData = snapshot.data?.data() as Map<String, dynamic>?;
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: userData?['photoURL'] != null
                      ? CachedNetworkImage(
                          imageUrl: userData!['photoURL'],
                          fit: BoxFit.contain,
                          width: 40,
                          height: 40,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                        )
                      : Icon(Icons.person, color: Colors.grey[400], size: 20),
                );
              }
              return Container(
                width: 40, // Changed to match
                height: 40, // Changed to match
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: Icon(Icons.person, color: Colors.grey[400], size: 20),
              );
            },
          ),
        ),
      ),
      titleSpacing: 0,
      title: Container(
        height: 40,
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: TextField(
            onTap: () {
              onPageChange(1);
            },
            onTapOutside: (event) =>
                FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              hintText: 'Search items...',
              hintStyle: TextStyle(fontSize: 13),
              prefixIcon:
                  Icon(Icons.search, color: AppColors.hijauTua, size: 18),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.grey,),
              onPressed: onNotificationTap,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .collection('notifications')
                  .where('read', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                final unreadCount = snapshot.data?.docs.length ?? 0;
                if (unreadCount == 0) return SizedBox();

                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
