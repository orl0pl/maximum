import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

AndroidIntent openAlarmClock = const AndroidIntent(
  action: 'android.intent.action.SHOW_ALARMS',
  flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
);

AndroidIntent openCalendar = const AndroidIntent(
  action: 'android.intent.action.MAIN',
  category: 'android.intent.category.APP_CALENDAR',
  flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
);
