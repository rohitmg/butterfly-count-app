// lib/utils/snackbar_helper.dart
import 'package:flutter/material.dart';
import 'package:butterfly_counts/core/app_colors.dart'; // NEW: Import AppColors

// NEW: Define an enum for SnackBar types
enum SnackBarType { success, danger, info, warning, primary, secondary }

class SnackBarHelper {
  /// Shows a custom, floating, and dismissible SnackBar.
  ///
  /// [context]: The BuildContext to show the SnackBar.
  /// [message]: The text message to display.
  /// [type]: The type of SnackBar (e.g., success, danger, info) to determine its color.
  /// [textColor]: The color of the message text. Defaults to white.
  /// [duration]: How long the SnackBar should be visible. Defaults to 4 seconds.
  static void showFloatingSnackBar(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.secondary, // Default to secondary
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 4),
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar(); // Hide any current snackbars

    // Determine background color based on type
    Color backgroundColor;
    switch (type) {
      case SnackBarType.success:
        backgroundColor = AppColors.success;
        break;
      case SnackBarType.danger:
        backgroundColor = AppColors.danger;
        break;
      case SnackBarType.info:
        backgroundColor = AppColors.info;
        break;
      case SnackBarType.warning:
        backgroundColor = AppColors.warning;
        break;
      case SnackBarType.primary:
        backgroundColor = AppColors.primary;
        break;
      case SnackBarType.secondary:
        backgroundColor = AppColors.secondary;
        break;
    }

    final snackBar = SnackBar(
      content: GestureDetector(
        onTap: () {
          scaffoldMessenger.hideCurrentSnackBar();
        },
        child: Text(message, style: TextStyle(color: textColor)),
      ),
      backgroundColor: backgroundColor.withAlpha(
        (255 * 0.9).round(),
      ), // 90% opacity
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.1,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
      ),
      duration: duration,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    scaffoldMessenger.showSnackBar(snackBar);
  }
}
