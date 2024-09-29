import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:maximum/main.dart';
import 'package:maximum/screens/add.dart';
import 'package:maximum/screens/pinned_apps.dart';
import 'package:maximum/screens/settings.dart';
import 'package:maximum/utils/apps_cache.dart';
import 'package:maximum/widgets/main_screen/pinned_app.dart';
import 'package:maximum/widgets/subscreens/apps.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Bottom extends StatefulWidget {
  const Bottom({
    super.key,
    required this.activeScreen,
    required this.setActiveScreen,
    required this.setInput,
    required this.appsKey,
  });

  final ActiveScreen activeScreen;
  final void Function(ActiveScreen) setActiveScreen;
  final void Function(String) setInput;

  final GlobalKey<AppsWidgetState> appsKey;

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  FocusNode focus = FocusNode();
  List<AppInfo>? pinnedApps;

  @override
  void initState() {
    super.initState();
    fetchPinnedApps();
  }

  void fetchPinnedApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? pinnedAppsPackageNames = prefs.getStringList('pinnedApps');
    List<AppInfo>? appsFromCache = getAppsFromCache(prefs);

    if (pinnedAppsPackageNames != null) {
      List<AppInfo> apps =
          appsFromCache ?? await InstalledApps.getInstalledApps(false, true);

      if (mounted) {
        setState(() {
          pinnedApps = apps.where((app) {
            return pinnedAppsPackageNames.contains(app.packageName);
          }).toList();
        });
      }

      saveAppsToCache(prefs, apps);
    } else {
      if (mounted) {
        setState(() {
          pinnedApps = [];
        });
      }
      prefs.setStringList('pinnedApps', []);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context)!;
    if (widget.activeScreen == ActiveScreen.start) {
      focus.unfocus();
    }
    if (widget.activeScreen == ActiveScreen.apps) {
      focus.requestFocus();
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 80,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: pinnedApps == null
                      ? [Text(l.loading)]
                      : pinnedApps!.isEmpty
                          ? [
                              FilledButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) =>
                                          const PinnedAppsScreen(),
                                    ));
                                    fetchPinnedApps();
                                  },
                                  child: const Text("l.set_pinned_apps"))
                            ]
                          : pinnedApps!.map((app) {
                              return PinnedApp(app: app);
                            }).toList()),
            ),
            Flexible(
              flex: 25,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AddScreen()));

                  widget.setActiveScreen(ActiveScreen.start);
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Divider(),
        SearchBar(
            hintText: l.search_placeholder,
            focusNode: focus,
            onChanged: (value) {
              widget.setInput(value);
            },
            onTap: () {
              if (widget.activeScreen != ActiveScreen.apps) {
                widget.setActiveScreen(ActiveScreen.apps);
              }
            },
            onSubmitted: (value) {
              if (widget.activeScreen == ActiveScreen.apps &&
                  value.isNotEmpty) {
                widget.appsKey.currentState?.openTopMatch();
              }
            },
            leading: PopupMenuButton(
              position: PopupMenuPosition.over,
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Icons.settings),
                        const SizedBox(width: 8),
                        Text(l.settings)
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SettingsScreen()));
                      fetchPinnedApps();

                      widget.setActiveScreen(ActiveScreen.start);
                    },
                  ),
                ];
              },
              icon: const Icon(Icons.menu),
            ),
            trailing: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
            ]),
      ],
    );
  }
}
