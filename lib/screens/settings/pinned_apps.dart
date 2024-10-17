import 'dart:typed_data';

import 'package:android_package_manager/android_package_manager.dart';
import 'package:app_launcher/app_launcher.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PinnedAppsScreen extends StatefulWidget {
  const PinnedAppsScreen({super.key});

  @override
  State<PinnedAppsScreen> createState() => _PinnedAppsScreenState();
}

class _PinnedAppsScreenState extends State<PinnedAppsScreen> {
  List<String>? pinnedApps;
  List<ApplicationInfo>? allApps;
  Map<String, String>? appLabels;
  List<ApplicationInfo> filteredApps = [];
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
    if (savedPinnedApps != null && mounted) {
      setState(() {
        pinnedApps = savedPinnedApps;
      });
    } else if (mounted) {
      setState(() {
        pinnedApps = [];
      });
      prefs.setStringList('pinnedApps', []);
    }
  }

  void fetchAllApps() async {
    List<ApplicationInfo> apps =
        (await AndroidPackageManager().getInstalledApplications())!
            .where((app) =>
                app.name != null && app.icon != null && app.packageName != null)
            .toList();

    apps = await Future.wait(apps.map((app) async {
      return (await AppLauncher.hasApp(
                  androidApplicationId: app.packageName!)) ==
              true
          ? app
          : null;
    })).then((values) => values
        .where((element) => element != null)
        .toList()
        .cast<ApplicationInfo>());

    // Get the labels before sorting
    List<String> labels =
        await Future.wait(apps.map((app) async => (await app.getAppLabel())!));

    appLabels = Map.fromIterables(apps.map((app) => app.packageName!), labels);

    // Sort the apps based on their labels
    apps.sort((a, b) {
      String labelA = appLabels![a.packageName!]!;
      String labelB = appLabels![a.packageName!]!;
      return labelA.toLowerCase().compareTo(labelB.toLowerCase());
    });

    if (mounted) {
      setState(() {
        allApps = apps;
      });
    }
    updateList(searchQuery);
  }

  void updateList(value) async {
    if (value.isEmpty && mounted) {
      setState(() {
        if (allApps != null) {
          filteredApps = allApps!;
        }
      });
    } else if (mounted && allApps != null) {
      setState(() {
        filteredApps = allApps!
            .where((app) => appLabels![app.packageName!]!
                .toLowerCase()
                .contains(value.toLowerCase()))
            .toList();
      });
    }
    if (mounted) {
      setState(() {
        searchQuery = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.pinned_apps),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  onChanged: updateList,
                  decoration: InputDecoration(
                    hintText: l.search_apps,
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: allApps == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemBuilder: (itemBuilder, index) {
                return ListTile(
                  leading: FutureBuilder<Uint8List?>(
                    future: filteredApps[index].getAppIcon(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(snapshot.data!, width: 40);
                      } else {
                        return CircularProgressIndicator(); // or some other loading indicator
                      }
                    },
                  ),
                  trailing: Checkbox(
                      value:
                          pinnedApps!.contains(filteredApps[index].packageName),
                      onChanged: (value) async {
                        if (value == true) {
                          setState(() {
                            pinnedApps!.add(filteredApps[index].packageName!);
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
                  title: FutureBuilder<String?>(
                    future: filteredApps[index].getAppLabel(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data!);
                      } else {
                        return Skeletonizer(
                            enabled: !snapshot.hasData,
                            child: Text(
                                "${filteredApps[index].packageName}")); // or some other loading indicator
                      }
                    },
                  ),
                );
              },
              itemCount: filteredApps.length),
    );
  }
}
