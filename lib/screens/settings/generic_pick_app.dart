import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> launchAppPicker(
    BuildContext context, String? initialApp, String? title) {
  if (context.mounted) {
    return Navigator.of(context).push<String?>(
      MaterialPageRoute(
          builder: (context) =>
              GenericPickAppScreen(initialApp: initialApp, title: title),
          maintainState: false),
    );
  } else {
    return Future(() => null);
  }
}

class GenericPickAppScreen extends StatefulWidget {
  const GenericPickAppScreen({super.key, this.initialApp, this.title});
  final String? title;

  final String? initialApp;

  @override
  State<GenericPickAppScreen> createState() => _GenericPickAppScreenState();
}

class _GenericPickAppScreenState extends State<GenericPickAppScreen> {
  String? pickedApp;
  List<ApplicationWithIcon>? allApps;
  List<ApplicationWithIcon> filteredApps = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchAllApps();
    if (widget.initialApp != null) {
      pickedApp = widget.initialApp;
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
    if (value.isEmpty && mounted) {
      setState(() {
        if (allApps != null) {
          filteredApps = allApps!;
        }
      });
    } else if (mounted && allApps != null) {
      setState(() {
        filteredApps = allApps!
            .where((app) =>
                app.appName.toLowerCase().contains(value.toLowerCase()))
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
      floatingActionButton: pickedApp == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).pop(pickedApp);
              },
              icon: const Icon(Icons.save),
              label: Text(l.save),
            ),
      appBar: AppBar(
        title: widget.title == null ? Text(l.pick_app) : Text(widget.title!),
        centerTitle: true,
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
                  leading: Image.memory(filteredApps[index].icon, width: 40),
                  onTap: () {
                    setState(() {
                      pickedApp = filteredApps[index].packageName;
                    });
                  },
                  trailing: Radio(
                      value: filteredApps[index].packageName,
                      groupValue: pickedApp,
                      onChanged: (value) {
                        setState(() {
                          pickedApp = value;
                        });
                      }),
                  title: Text(filteredApps[index].appName),
                );
              },
              itemCount: filteredApps.length),
    );
  }
}
