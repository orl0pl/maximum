import 'package:flutter/material.dart';
import 'package:maximum/utils/alarm.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Weather extends StatelessWidget {
  const Weather({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(children: [
      Row(
        children: [
          const Icon(Icons.sunny),
          const SizedBox(width: 4),
          Text('23°', style: textTheme.titleLarge)
        ],
      ),
      Text('13° w nocy', style: textTheme.titleSmall),
    ]);
  }
}

class Alarm extends StatefulWidget {
  const Alarm({
    super.key,
  });

  @override
  State<Alarm> createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  String? nextAlarm;

  @override
  void initState() {
    super.initState();

    AlarmHelper.getNextAlarm().then((value) {
      setState(() {
        if (value != null) {
          nextAlarm = value;
        } else if (value == null) {
          nextAlarm = "???";
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    nextAlarm ??= AppLocalizations.of(context)!.loading;
    return Row(
      children: [
        const Icon(Icons.alarm),
        const SizedBox(width: 4),
        Text(nextAlarm ?? "", style: textTheme.titleLarge)
      ],
    );
  }
}
