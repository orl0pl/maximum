import 'dart:typed_data';

import 'package:android_package_manager/android_package_manager.dart';

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
  List<ApplicationInfo>? allApps;
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
        (await AndroidPackageManager().getInstalledApplications())!;
    apps.sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
    if (mounted) {
      setState(() {
        allApps = apps;
      });
    }
    updateList(searchQuery);
  }

  void updateList(value) {
    if (value.isEmpty && mounted) {
      setState(() {
        if (allApps != null) {
          filteredApps = allApps!;
        }
      });
    } else if (mounted && allApps != null) {
      setState(() {
        filteredApps = allApps!
            .where(
                (app) => app.name!.toLowerCase().contains(value.toLowerCase()))
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
                  title: Text(filteredApps[index].name!),
                );
              },
              itemCount: filteredApps.length),
    );
  }
}
