import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../utils/colors.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;

  const ProfileAvatar({super.key, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profile, child) {
        final hasImage = profile.hasProfileImage;

        return CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primary,
          backgroundImage: hasImage
              ? FileImage(File(profile.profileImagePath!))
              : null,
          child: hasImage
              ? null
              : Icon(Icons.person, size: radius * 1.1, color: Colors.white),
        );
      },
    );
  }
}
