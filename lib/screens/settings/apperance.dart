import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApperanceScreen extends StatefulWidget {
  const ApperanceScreen({super.key});

  @override
  State<ApperanceScreen> createState() => _ApperanceScreenState();
}

class _ApperanceScreenState extends State<ApperanceScreen> {
  bool? showSecondsInClock;

  @override
  void initState() {
    super.initState();
    fetchPreferences();
  }

  void fetchPreferences() async {
    var prefs = await SharedPreferences.getInstance();

    setState(() {
      showSecondsInClock = prefs.getBool('showSecondsInClock') ?? false;
    });

    return;
  }

  void savePreferences() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('showSecondsInClock', showSecondsInClock ?? false);

    return;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.apperance),
        ),
        body: ListView(
          children: [
            SwitchListTile(
                value: showSecondsInClock ?? true,
                title: Text(l.show_seconds_in_clock),
                onChanged: (value) {
                  setState(() {
                    showSecondsInClock = value;
                    savePreferences();
                  });
                }),
          ],
        ),
      ),
    );
  }
}
