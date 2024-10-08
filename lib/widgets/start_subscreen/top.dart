// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maximum/utils/intents.dart';
import 'package:maximum/widgets/start_subscreen/alarm.dart';
import 'weather.dart';

class Top extends StatefulWidget {
  const Top({
    super.key,
  });

  @override
  State<Top> createState() => _TopState();
}

class _TopState extends State<Top> {
  DateTime currentDatetime = DateTime.now();

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          currentDatetime = DateTime.now();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => openCalendar.launch(),
              child: Text(
                DateFormat('EEE d MMMM').format(DateTime.now()),
                style: textTheme.titleLarge,
              ),
            ),
            InkWell(
              onTap: () => openAlarmClock.launch(),
              child: Text(
                DateFormat('HH:mm:ss').format(DateTime.now()),
                style: textTheme.displayLarge,
              ),
            ),
          ],
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [Weather(), SizedBox(height: 8), Alarm()],
        ),
      ],
    );
  }
}
