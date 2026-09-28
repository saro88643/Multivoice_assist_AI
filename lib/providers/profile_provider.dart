import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  // ============================================================
  // DEFAULT PROFILE DATA
  // ============================================================

  String _userName = 'Soundarajan';
  String _userEmail = 'soundarajan@gmail.com';
  String? _profileImagePath;

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  final ImagePicker _imagePicker = ImagePicker();

  // ============================================================
  // GETTERS
  // ============================================================

  String get userName => _userName;

  String get userEmail => _userEmail;

  String? get profileImagePath => _profileImagePath;

  bool get hasProfileImage {
    if (_profileImagePath == null || _profileImagePath!.isEmpty) {
      return false;
    }

    return File(_profileImagePath!).existsSync();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _userName = prefs.getString('user_name') ?? 'Soundarajan';

      _userEmail = prefs.getString('user_email') ?? 'soundarajan@gmail.com';

      final savedPath = prefs.getString('profile_image_path');

      if (savedPath != null && savedPath.isNotEmpty) {
        final file = File(savedPath);

        if (await file.exists()) {
          _profileImagePath = savedPath;
        } else {
          _profileImagePath = null;
          await prefs.remove('profile_image_path');
        }
      } else {
        _profileImagePath = null;
      }

      notifyListeners();

      // Recover image if Android killed the activity
      // while Gallery was open.
      await _recoverLostImage();
    } catch (e) {
      debugPrint('Load profile error: $e');
    }
  }

  // ============================================================
  // RECOVER LOST IMAGE
  // ============================================================

  Future<void> _recoverLostImage() async {
    try {
      debugPrint('Checking for lost image data...');

      final LostDataResponse response = await _imagePicker.retrieveLostData();

      if (response.isEmpty) {
        debugPrint('No lost image found.');
        return;
      }

      if (response.files != null && response.files!.isNotEmpty) {
        final XFile lostImage = response.files!.first;

        debugPrint('Lost image recovered: ${lostImage.path}');

        await _saveSelectedImage(lostImage);
      }

      if (response.exception != null) {
        debugPrint('Lost image exception: ${response.exception}');
      }
    } catch (e) {
      debugPrint('Recover lost image error: $e');
    }
  }

  // ============================================================
  // PICK PROFILE IMAGE
  // ============================================================

  Future<bool> pickProfileImage() async {
    try {
      debugPrint('Opening gallery...');

      final XFile? selectedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        requestFullMetadata: false,
      );

      // User cancelled
      if (selectedImage == null) {
        debugPrint('User cancelled gallery.');
        return false;
      }

      debugPrint('Selected image: ${selectedImage.path}');

      return await _cropAndSaveImage(selectedImage);
    } catch (e, stackTrace) {
      debugPrint('Pick profile image error: $e');

      debugPrint('Stack trace: $stackTrace');

      return false;
    }
  }

  // ============================================================
  // CROP AND SAVE IMAGE
  // ============================================================

  Future<bool> _cropAndSaveImage(XFile selectedImage) async {
    try {
      final selectedFile = File(selectedImage.path);

      if (!await selectedFile.exists()) {
        debugPrint('Selected image does not exist.');
        return false;
      }

      debugPrint('Opening image cropper...');

      final CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: selectedImage.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,

        uiSettings: [
          // ==================================================
          // ANDROID
          // ==================================================
          AndroidUiSettings(
            toolbarTitle: 'Adjust Profile Picture',
            toolbarColor: const Color(0xFF5146E5),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
            cropStyle: CropStyle.circle,
          ),

          // ==================================================
          // IOS
          // ==================================================
          IOSUiSettings(
            title: 'Adjust Profile Picture',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            cropStyle: CropStyle.circle,
          ),
        ],
      );

      // User cancelled cropper
      if (croppedImage == null) {
        debugPrint('User cancelled cropper.');
        return false;
      }

      debugPrint('Cropped image: ${croppedImage.path}');

      final croppedFile = File(croppedImage.path);

      if (!await croppedFile.exists()) {
        debugPrint('Cropped image does not exist.');
        return false;
      }

      // ======================================================
      // APP DOCUMENT DIRECTORY
      // ======================================================

      final directory = await getApplicationDocumentsDirectory();

      // ======================================================
      // UNIQUE FILE NAME
      // ======================================================

      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final String permanentPath = '${directory.path}/$fileName';

      // ======================================================
      // COPY IMAGE
      // ======================================================

      final File savedImage = await croppedFile.copy(permanentPath);

      debugPrint('Permanent image saved: ${savedImage.path}');

      // ======================================================
      // KEEP OLD IMAGE PATH
      // ======================================================

      final String? oldImagePath = _profileImagePath;

      // ======================================================
      // UPDATE MEMORY
      // ======================================================

      _profileImagePath = savedImage.path;

      // ======================================================
      // SAVE PATH
      // ======================================================

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('profile_image_path', savedImage.path);

      // ======================================================
      // DELETE OLD IMAGE
      // ======================================================

      if (oldImagePath != null &&
          oldImagePath.isNotEmpty &&
          oldImagePath != savedImage.path) {
        try {
          final oldFile = File(oldImagePath);

          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        } catch (e) {
          debugPrint('Old image delete error: $e');
        }
      }

      // ======================================================
      // UPDATE UI
      // ======================================================

      notifyListeners();

      debugPrint('Profile image updated successfully.');

      return true;
    } catch (e, stackTrace) {
      debugPrint('Crop/save image error: $e');

      debugPrint('Stack trace: $stackTrace');

      return false;
    }
  }

  // ============================================================
  // SAVE SELECTED IMAGE
  // USED FOR ANDROID LOST-DATA RECOVERY
  // ============================================================

  Future<bool> _saveSelectedImage(XFile selectedImage) async {
    try {
      final file = File(selectedImage.path);

      if (!await file.exists()) {
        debugPrint('Recovered image does not exist.');
        return false;
      }

      debugPrint('Saving recovered image...');

      final directory = await getApplicationDocumentsDirectory();

      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final String permanentPath = '${directory.path}/$fileName';

      final File savedImage = await file.copy(permanentPath);

      final String? oldImagePath = _profileImagePath;

      _profileImagePath = savedImage.path;

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('profile_image_path', savedImage.path);

      // Delete old image
      if (oldImagePath != null &&
          oldImagePath.isNotEmpty &&
          oldImagePath != savedImage.path) {
        try {
          final oldFile = File(oldImagePath);

          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        } catch (e) {
          debugPrint('Old image delete error: $e');
        }
      }

      notifyListeners();

      debugPrint('Recovered image saved successfully.');

      return true;
    } catch (e, stackTrace) {
      debugPrint('Save recovered image error: $e');

      debugPrint('Stack trace: $stackTrace');

      return false;
    }
  }

  // ============================================================
  // UPDATE NAME AND EMAIL
  // ============================================================

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final cleanName = name.trim();
      final cleanEmail = email.trim();

      if (cleanName.isEmpty || cleanEmail.isEmpty) {
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('user_name', cleanName);

      await prefs.setString('user_email', cleanEmail);

      _userName = cleanName;
      _userEmail = cleanEmail;

      notifyListeners();
    } catch (e) {
      debugPrint('Update profile error: $e');
    }
  }

  // ============================================================
  // REMOVE PROFILE IMAGE
  // ============================================================

  Future<void> removeProfileImage() async {
    try {
      final String? oldPath = _profileImagePath;

      // Clear memory
      _profileImagePath = null;

      // Remove saved path
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('profile_image_path');

      // Delete actual image
      if (oldPath != null && oldPath.isNotEmpty) {
        try {
          final file = File(oldPath);

          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('Delete image error: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Remove profile image error: $e');
    }
  }
}
