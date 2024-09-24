import 'package:flutter/services.dart';

class AlarmHelper {
  static const MethodChannel _channel = MethodChannel('orl0pl.maximum/alarm');

  static Future<String?> getNextAlarm() async {
    try {
      final String? nextAlarm = await _channel.invokeMethod('getNextAlarm');
      return nextAlarm;
    } on PlatformException catch (e) {
      print("Failed to get next alarm: '${e.message}'.");
      return null;
    }
  }
}
