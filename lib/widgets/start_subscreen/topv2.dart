// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:intl/intl.dart';
import 'package:maximum/utils/intents.dart';
import 'package:maximum/widgets/start_subscreen/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'weather.dart';

class TopV2 extends StatefulWidget {
  const TopV2({
    super.key,
  });

  @override
  State<TopV2> createState() => _TopV2State();
}

class _TopV2State extends State<TopV2> {
  DateTime currentDatetime = DateTime.now();
  bool? showSecondsInClock;

  @override
  void initState() {
    super.initState();
    fetchPreferences();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        fetchPreferences();
        setState(() {
          currentDatetime = DateTime.now();
        });
      }
    });
  }

  void fetchPreferences() async {
    var prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        showSecondsInClock = prefs.getBool('showSecondsInClock') ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('EEE d MMM').format(currentDatetime),
                      style: textTheme.titleLarge),
                  Text(
                      DateFormat(
                              'HH:mm${showSecondsInClock == true ? ':ss' : ''}')
                          .format(currentDatetime),
                      style: textTheme.displayLarge),
                ],
              ),
              SizedBox(width: 16),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(Icons.wb_shade_sharp),
                          SizedBox(width: 8),
                          Text("Replace me later", style: textTheme.titleSmall),
                        ],
                      ),
                      Text(
                          "Example text for the description of the day of the week and timer here",
                          style: textTheme.bodySmall),
                    ],
                  ),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.only(left: 6, right: 16, top: 6, bottom: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              MdiIcons.accessPoint,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            SizedBox(width: 4),
                            Text("123",
                                style: textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer)),
                          ],
                        )),
                    const SizedBox(width: 8),
                    Text("Replace me later", style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
