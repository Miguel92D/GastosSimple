import 'package:flutter/material.dart';

class AppGuard {
  static Future<T?> runSafe<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      debugPrint("AppGuard error: $e");
      return null;
    }
  }
}
