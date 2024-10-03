import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AlarmHelper {
  static const MethodChannel _channel = MethodChannel('orl0pl.maximum/alarm');

  static Future<int?> getNextAlarmMilisecondsAfterEpoch() async {
    final int? nextAlarm = await _channel.invokeMethod('getNextAlarm');
    return nextAlarm;
  }

  static Future<DateTime?> getNextAlarmDateTime() async {
    final int? nextAlarm = await getNextAlarmMilisecondsAfterEpoch();
    if (nextAlarm == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(nextAlarm);
  }

  static Future<String?> getNextAlarm() async {
    final DateTime? nextAlarm = await getNextAlarmDateTime();
    if (nextAlarm == null) return null;
    return DateFormat('EEE HH:mm').format(nextAlarm);
  }
}
