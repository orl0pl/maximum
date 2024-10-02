import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maximum/utils/alarm.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maximum/utils/intents.dart';

class Alarm extends StatefulWidget {
  const Alarm({
    super.key,
  });

  @override
  State<Alarm> createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  DateTime? nextAlarm;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    AlarmHelper.getNextAlarmDateTime().then((value) {
      setState(() {
        nextAlarm = value;
        loading = false;
      });
    });
  }

  bool get displayTimeOfNextAlarm {
    if (nextAlarm == null) return false;
    if (nextAlarm!.add(const Duration(days: 7)).isAfter(DateTime.now())) {
      return true;
    }

    return false;
  }

  String getNextAlarmString(AppLocalizations l) {
    if (loading) {
      return l.loading;
    } else if (!loading && nextAlarm == null) {
      return l.no_alarm;
    } else if (displayTimeOfNextAlarm) {
      return DateFormat("EEE, HH:mm").format(nextAlarm!);
    } else {
      return DateFormat.Md().format(nextAlarm!);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => openAlarmClock.launch(),
      child: Row(
        children: [
          const Icon(Icons.alarm),
          const SizedBox(width: 4),
          Text(getNextAlarmString(AppLocalizations.of(context)!),
              style: textTheme.titleLarge)
        ],
      ),
    );
  }
}
