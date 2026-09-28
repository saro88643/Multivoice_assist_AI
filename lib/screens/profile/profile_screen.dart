import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../utils/colors.dart';
import '../auth/login_screen.dart';
import '../history/history_screen.dart';
import 'edit_profile_screen.dart';
import 'voice_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) {
      return;
    }

    Provider.of<AuthProvider>(context, listen: false).logout();

    if (!context.mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  Future<void> _editProfile(BuildContext context) async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          currentName: profileProvider.userName,
          currentEmail: profileProvider.userEmail,
        ),
      ),
    );
  }

  // ============================================================
  // CHANGE PROFILE IMAGE
  // ============================================================

  Future<void> _changeProfileImage(BuildContext context) async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    final bool success = await profileProvider.pickProfileImage();

    if (!context.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // ============================================================
  // ABOUT
  // ============================================================

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.smart_toy, color: AppColors.primary, size: 30),
              SizedBox(width: 10),
              Text('About'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MultiVoice Assist',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                'A multilingual AI chatbot that allows '
                'users to communicate using text and voice '
                'in different languages.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 10),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '© 2026 MultiVoice Assist',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SECURITY
  // ============================================================

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.security, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Security'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Security',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Your account security features will be '
                'available here.',
              ),
              SizedBox(height: 15),
              Text(
                'Password management and other security '
                'options can be added in the next version.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PROFILE OPTION
  // ============================================================

  Widget _profileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.15),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Widget _buildProfileImage(BuildContext context, ProfileProvider profile) {
    final bool hasImage = profile.hasProfileImage;

    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.primary,
          backgroundImage: hasImage
              ? FileImage(File(profile.profileImagePath!))
              : null,
          child: !hasImage
              ? const Icon(Icons.person, size: 65, color: Colors.white)
              : null,
        ),

        // ======================================================
        // CAMERA BUTTON
        // ======================================================
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              _changeProfileImage(context);
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 3),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 21,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, profile, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // ==================================================
                  // PROFILE PHOTO
                  // ==================================================
                  _buildProfileImage(context, profile),

                  const SizedBox(height: 15),

                  // ==================================================
                  // NAME
                  // ==================================================
                  Text(
                    profile.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // ==================================================
                  // EMAIL
                  // ==================================================
                  Text(
                    profile.userEmail,
                    style: const TextStyle(color: Colors.white60, fontSize: 15),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // EDIT PROFILE
                  // ==================================================
                  SizedBox(
                    height: 45,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _editProfile(context);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // VOICE SETTINGS
                  // ==================================================
                  _profileOption(
                    context,
                    icon: Icons.mic,
                    title: 'Voice Settings',
                    subtitle: 'Manage voice and speech settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VoiceSettingsScreen(),
                        ),
                      );
                    },
                  ),

                  // ==================================================
                  // CHAT HISTORY
                  // ==================================================
                  _profileOption(
                    context,
                    icon: Icons.history,
                    title: 'Chat History',
                    subtitle: 'View and manage your conversations',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),

                  // ==================================================
                  // SECURITY
                  // ==================================================
                  _profileOption(
                    context,
                    icon: Icons.security,
                    title: 'Security',
                    subtitle: 'Manage your account security',
                    onTap: () {
                      _showSecurityDialog(context);
                    },
                  ),

                  // ==================================================
                  // ABOUT
                  // ==================================================
                  _profileOption(
                    context,
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'About MultiVoice Assist',
                    onTap: () {
                      _showAbout(context);
                    },
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // LOGOUT
                  // ==================================================
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _logout(context);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
