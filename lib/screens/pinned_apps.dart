import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinnedAppsScreen extends StatefulWidget {
  const PinnedAppsScreen({super.key});

  @override
  State<PinnedAppsScreen> createState() => _PinnedAppsScreenState();
}

class _PinnedAppsScreenState extends State<PinnedAppsScreen> {
  List<String>? pinnedApps;
  List<AppInfo>? allApps;

  @override
  void initState() {
    super.initState();
    fetchPinnedApps();
    fetchAllApps();
  }

  void fetchPinnedApps() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedPinnedApps = prefs.getStringList('pinnedApps');
    if (savedPinnedApps != null) {
      setState(() {
        pinnedApps = savedPinnedApps;
      });
    } else {
      setState(() {
        pinnedApps = [];
      });
      prefs.setStringList('pinnedApps', []);
    }
  }

  void fetchAllApps() async {
    List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
    if (mounted) {
      setState(() {
        allApps = apps;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.pinned_apps),
      ),
      body: allApps == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemBuilder: (itemBuilder, index) {
                return ListTile(
                  leading: Image.memory(allApps![index].icon!, width: 40),
                  trailing: Checkbox(
                      value: pinnedApps!.contains(allApps![index].packageName),
                      onChanged: (value) async {
                        if (value == true) {
                          setState(() {
                            pinnedApps!.add(allApps![index].packageName);
                          });
                        } else {
                          setState(() {
                            pinnedApps!.remove(allApps![index].packageName);
                          });
                        }
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setStringList('pinnedApps', pinnedApps!);
                      }),
                  title: Text(allApps![index].name),
                );
              },
              itemCount: allApps!.length),
    );
  }
}
