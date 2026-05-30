import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateService {
  static Future<void> checkForUpdates() async {
    // In-app updates via Play Core API are Android only.
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        // Prioritize immediate updates (blocking) if allowed by Play Console.
        // Otherwise, try a flexible update (background download).
        if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          // Note: To install a flexible update after downloading, 
          // you'd typically listen for download completion and prompt the user.
          // For simplicity, we just start it here.
        }
      }
    } catch (e) {
      debugPrint('[UpdateService] Error checking for updates: $e');
    }
  }
}
