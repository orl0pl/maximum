import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restart_app/restart_app.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  SharedPreferences? prefs;
  bool? forceEnglish;
  String? temperatureUnit;
  String? windSpeedUnit;
  String? precipitationUnit;

  @override
  void initState() {
    super.initState();
    fetchPreferences();
  }

  void fetchPreferences() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      forceEnglish = prefs?.getBool('forceEnglish') ?? false;
      temperatureUnit = prefs?.getString('temperatureUnit') ?? "C";
      windSpeedUnit = prefs?.getString('windSpeedUnit') ?? "m/s";
      precipitationUnit = prefs?.getString('precipitationUnit') ?? "mm";
    });

    return;
  }

  void savePreferences() async {
    prefs = await SharedPreferences.getInstance();
    prefs?.setBool('forceEnglish', forceEnglish ?? false);
    prefs?.setString('temperatureUnit', temperatureUnit ?? "C");
    prefs?.setString('windSpeedUnit', windSpeedUnit ?? "m/s");
    prefs?.setString('precipitationUnit', precipitationUnit ?? "mm");

    return;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.preferences),
      ),
      body: ListView(
        children: [
          ListTile(
              title: Text(l.temperature_unit),
              trailing: SegmentedButton(
                  segments: const [
                    ButtonSegment(
                      value: "C",
                      label: Text("°C"),
                    ),
                    ButtonSegment(
                      value: "F",
                      label: Text("°F"),
                    ),
                  ],
                  selected: {
                    temperatureUnit
                  },
                  multiSelectionEnabled: false,
                  onSelectionChanged: (value) {
                    setState(() {
                      temperatureUnit = value.first;
                      savePreferences();
                    });
                  })),
          ListTile(
              title: Text(l.wind_speed_unit),
              subtitle: SegmentedButton(
                  segments: const [
                    ButtonSegment(
                      value: "m/s",
                      label: Text("m/s"),
                    ),
                    ButtonSegment(
                      value: "mph",
                      label: Text("mph"),
                    ),
                    ButtonSegment(
                      value: "kn",
                      label: Text("kn"),
                    ),
                    ButtonSegment(value: "kmh", label: Text("km/h")),
                  ],
                  selected: {
                    windSpeedUnit
                  },
                  multiSelectionEnabled: false,
                  onSelectionChanged: (value) {
                    setState(() {
                      windSpeedUnit = value.first;
                      savePreferences();
                    });
                  })),
          ListTile(
              title: Text(l.precipitation_unit),
              trailing: SegmentedButton(
                  segments: const [
                    ButtonSegment(
                      value: "mm",
                      label: Text("mm"),
                    ),
                    ButtonSegment(
                      value: "in",
                      label: Text("in"),
                    ),
                  ],
                  selected: {
                    precipitationUnit
                  },
                  multiSelectionEnabled: false,
                  onSelectionChanged: (value) {
                    setState(() {
                      precipitationUnit = value.first;
                      savePreferences();
                    });
                  })),
          const Divider(),
          ListTile(
            title: const Text("Force english"),
            trailing: Switch(
              value: forceEnglish ?? false,
              onChanged: (value) {
                setState(() {
                  forceEnglish = value;
                });
                savePreferences();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.restart_app_to_apply),
                    action: SnackBarAction(
                      label: l.restart_app,
                      onPressed: () {
                        Restart.restartApp();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
