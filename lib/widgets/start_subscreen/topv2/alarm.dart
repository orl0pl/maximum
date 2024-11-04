import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:intl/intl.dart';
import 'package:maximum/utils/alarm.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maximum/utils/intents.dart';
import 'package:maximum/widgets/start_subscreen/topv2/topchip.dart';

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
      if (mounted) {
        setState(() {
          nextAlarm = value;
          loading = false;
        });
      }
    });
  }

  bool get displayDayOfNextAlarm {
    if (nextAlarm == null) return false;
    if (nextAlarm!.add(const Duration(days: 1)).isAfter(DateTime.now())) {
      return true;
    }

    return false;
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
    } else if (displayDayOfNextAlarm) {
      return DateFormat.jm().format(nextAlarm!);
    } else if (displayTimeOfNextAlarm) {
      return DateFormat("EEE, HH:mm").format(nextAlarm!);
    } else {
      return DateFormat.Md().format(nextAlarm!);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return TopChip(
      icon: displayTimeOfNextAlarm ? MdiIcons.alarm : MdiIcons.alarmOff,
      title: getNextAlarmString(AppLocalizations.of(context)),
      onTap: () => openAlarmClock.launch(),
    );
  }
}
