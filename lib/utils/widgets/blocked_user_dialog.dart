import 'package:flutter/material.dart';
import 'package:grofery_user/config/theme.dart';

class BlockedUserDialog {
  static void show(BuildContext context, String message) {
    String cleanMessage = message;
    cleanMessage = cleanMessage.replaceAll(
        RegExp(r'API Error \(\d+\):\s*', caseSensitive: false), '');
    cleanMessage = cleanMessage.replaceAll(
        RegExp(r'Exception:\s*', caseSensitive: false), '');
    cleanMessage = cleanMessage.trim();

    showDialog(
      context: context,

      barrierDismissible: false, // Force the user to interact with the button
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block, color: Colors.redAccent, size: 70),
                const SizedBox(height: 16),
                const Text(
                  "Account Blocked",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  cleanMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
