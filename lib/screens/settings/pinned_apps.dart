import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinnedAppsScreen extends StatefulWidget {
  const PinnedAppsScreen({super.key});

  @override
  State<PinnedAppsScreen> createState() => _PinnedAppsScreenState();
}

class _PinnedAppsScreenState extends State<PinnedAppsScreen> {
  List<String>? pinnedApps;
  List<ApplicationWithIcon>? allApps;
  List<ApplicationWithIcon> filteredApps = [];
  String searchQuery = '';

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
    List<Application> apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        onlyAppsWithLaunchIntent: true,
        includeSystemApps: true);
    apps.sort(
        (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    if (mounted) {
      setState(() {
        allApps = apps.cast();
      });
    }
    updateList(searchQuery);
  }

  void updateList(value) {
    if (value.isEmpty) {
      setState(() {
        if (allApps != null) {
          filteredApps = allApps!;
        }
      });
    } else {
      setState(() {
        filteredApps = allApps!
            .where((app) =>
                app.appName.toLowerCase().contains(value.toLowerCase()))
            .toList();
      });
    }
    setState(() {
      searchQuery = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.pinned_apps),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Column(
            children: [
              TextField(
                onChanged: updateList,
              ),
            ],
          ),
        ),
      ),
      body: allApps == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemBuilder: (itemBuilder, index) {
                return ListTile(
                  leading: Image.memory(filteredApps[index].icon, width: 40),
                  trailing: Checkbox(
                      value:
                          pinnedApps!.contains(filteredApps[index].packageName),
                      onChanged: (value) async {
                        if (value == true) {
                          setState(() {
                            pinnedApps!.add(filteredApps[index].packageName);
                          });
                        } else {
                          setState(() {
                            pinnedApps!.remove(filteredApps[index].packageName);
                          });
                        }
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setStringList('pinnedApps', pinnedApps!);
                      }),
                  title: Text(filteredApps[index].appName),
                );
              },
              itemCount: filteredApps.length),
    );
  }
}
