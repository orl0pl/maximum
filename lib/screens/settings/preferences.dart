import 'package:android_package_manager/android_package_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maximum/screens/settings/generic_pick_app.dart';
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
  String? weatherAppName;

  @override
  void initState() {
    super.initState();
    fetchPreferences();
    fetchweatherAppName();
  }

  void fetchPreferences() async {
    prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        forceEnglish = prefs?.getBool('forceEnglish') ?? false;
        temperatureUnit = prefs?.getString('temperatureUnit') ?? "C";
        windSpeedUnit = prefs?.getString('windSpeedUnit') ?? "m/s";
        precipitationUnit = prefs?.getString('precipitationUnit') ?? "mm";
      });
    }

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

  void fetchweatherAppName() async {
    prefs = await SharedPreferences.getInstance();
    var packageName = prefs?.getString('weatherApp');
    if (packageName != null) {
      var app = await AndroidPackageManager()
          .getApplicationLabel(packageName: packageName);
      if (mounted) {
        setState(() {
          weatherAppName = app;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          weatherAppName = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.preferences),
        ),
        body: ListView(
          children: [
            const Divider(),
            ListTile(
              title: Text(l.set_weather_app),
              subtitle: Text(weatherAppName == null
                  ? l.app_not_selected
                  : l.selected_app(weatherAppName!)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                var app =
                    await launchAppPicker(context, null, l.set_weather_app);
                if (app != null) {
                  prefs = await SharedPreferences.getInstance();
                  prefs?.setString('weatherApp', app);
                  fetchweatherAppName();
                }
              },
            ),
            const Divider(),
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
                      if (mounted) {
                        setState(() {
                          temperatureUnit = value.first;
                          savePreferences();
                        });
                      }
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
                      if (mounted) {
                        setState(() {
                          windSpeedUnit = value.first;
                          savePreferences();
                        });
                      }
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
                      if (mounted) {
                        setState(() {
                          precipitationUnit = value.first;
                          savePreferences();
                        });
                      }
                    })),
            const Divider(),
            ListTile(
              title: const Text("Force english"),
              trailing: Switch(
                value: forceEnglish ?? false,
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      forceEnglish = value;
                    });
                  }
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
      ),
    );
  }
}
