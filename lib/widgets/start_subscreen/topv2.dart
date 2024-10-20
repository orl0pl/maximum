import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:intl/intl.dart';
import 'package:maximum/utils/intents.dart';
import 'topv2/alarm.dart';
import 'package:maximum/widgets/start_subscreen/topv2/topchip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'topv2/weather.dart';

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
    ColorScheme colorScheme = Theme.of(context).colorScheme;
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
              // Flexible(
              //   flex: 1,
              //   fit: FlexFit.tight,
              //   child: Container(
              //     child: Column(
              //       mainAxisSize: MainAxisSize.max,
              //       children: [
              //         Row(
              //           mainAxisSize: MainAxisSize.max,
              //           children: [
              //             Icon(Icons.wb_shade_sharp),
              //             SizedBox(width: 8),
              //             Text("Replace me later", style: textTheme.titleSmall),
              //           ],
              //         ),
              //         Text(
              //             "Example text for the description of the day of the week and timer here",
              //             style: textTheme.bodySmall),
              //       ],
              //     ),
              //     padding: EdgeInsets.all(8),
              //     decoration: BoxDecoration(
              //       border: Border.all(color: colorScheme.outline),
              //       borderRadius: BorderRadius.circular(16),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Alarm(),
              const SizedBox(width: 8),
              Weather(),
            ],
          ),
        )
      ],
    );
  }
}
