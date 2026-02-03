import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AttendeeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showProfile;
  final List<Widget>? actions;

  const AttendeeAppBar({
    super.key,
    required this.title,
    this.showProfile = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black, // Fallback if AppColors not const
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
