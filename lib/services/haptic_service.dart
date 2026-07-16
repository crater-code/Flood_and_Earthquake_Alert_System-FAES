import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class HapticService {
  /// Light impact feedback (for subtle interactions)
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Haptic feedback not available: $e');
    }
  }

  /// Medium impact feedback (for standard interactions)
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Haptic feedback not available: $e');
    }
  }

  /// Heavy impact feedback (for important interactions)
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Haptic feedback not available: $e');
    }
  }

  /// Selection click feedback (for selection changes)
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Haptic feedback not available: $e');
    }
  }

  /// Vibration feedback (device vibration)
  static Future<void> vibrate() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      debugPrint('Vibration not available: $e');
    }
  }

  /// Success pattern - light then medium impact
  static Future<void> success() async {
    await lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await mediumImpact();
  }

  /// Error pattern - heavy impact
  static Future<void> error() async {
    await heavyImpact();
  }

  /// Warning pattern - medium impact
  static Future<void> warning() async {
    await mediumImpact();
  }

  /// Button tap feedback - light impact
  static Future<void> buttonTap() async {
    await lightImpact();
  }

  /// Navigation feedback - selection click
  static Future<void> navigation() async {
    await selectionClick();
  }

  /// Submit/send feedback - success pattern
  static Future<void> submit() async {
    await success();
  }
}