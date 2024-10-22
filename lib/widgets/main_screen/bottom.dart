import 'dart:typed_data';

import 'package:android_package_manager/android_package_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:maximum/screens/add.dart';
import 'package:maximum/screens/main.dart';
import 'package:maximum/screens/notes.dart';
import 'package:maximum/screens/settings/pinned_apps.dart';
import 'package:maximum/screens/settings.dart';
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
    required this.afterFABPressed,
  });

  final ActiveScreen activeScreen;
  final void Function(ActiveScreen) setActiveScreen;
  final void Function(String) setInput;
  final void Function() afterFABPressed;

  final GlobalKey<AppsWidgetState> appsKey;

  @override
  State<Bottom> createState() => BottomState();
}

class BottomState extends State<Bottom> {
  FocusNode focus = FocusNode();
  Map<String, Uint8List>? pinnedApps;
  String search = '';
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPinnedApps();
  }

  void setInput(String input) {
    if (mounted) {
      setState(() {
        widget.setInput(input);
        search = input;
      });
    }
  }

  void clearInput() {
    controller.value = TextEditingValue.empty;
    if (mounted) {
      setState(() {
        search = '';
      });
    }
  }

  void fetchPinnedApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? pinnedAppsPackageNames = prefs.getStringList('pinnedApps');

    if (pinnedAppsPackageNames != null) {
      Map<String, Uint8List> tempPinnedApps = {};

      for (var packageName in pinnedAppsPackageNames) {
        tempPinnedApps[packageName] = (await AndroidPackageManager()
            .getApplicationIcon(packageName: packageName))!;
      }

      if (mounted) {
        setState(() {
          pinnedApps = tempPinnedApps;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          pinnedApps = {};
        });
      }
      prefs.setStringList('pinnedApps', []);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
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
                                  child: Text(l.set_pinned_apps))
                            ]
                          : pinnedApps!.entries.map((e) {
                              return PinnedApp(
                                icon: e.value,
                                packageName: e.key,
                              );
                            }).toList()),
            ),
            Flexible(
              flex: 25,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => const AddScreen()))
                      .then((value) {
                    widget.afterFABPressed();
                  });

                  widget.setActiveScreen(ActiveScreen.start);
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SearchBar(
            hintText: l.search_placeholder,
            focusNode: focus,
            controller: controller,
            onChanged: setInput,
            onTap: () {
              if (widget.activeScreen != ActiveScreen.apps) {
                widget.setActiveScreen(ActiveScreen.apps);
              }
            },
            onSubmitted: (value) {
              if (widget.activeScreen == ActiveScreen.apps &&
                  value.isNotEmpty) {
                var outcome = widget.appsKey.currentState?.openTopMatch();

                if (outcome == OpenOutcome.openedExternal) {
                  widget.setActiveScreen(ActiveScreen.start);
                  clearInput();
                }
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
                          maintainState: false,
                          builder: (context) => const SettingsScreen()));
                      fetchPinnedApps();

                      widget.setActiveScreen(ActiveScreen.start);
                    },
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(MdiIcons.noteMultipleOutline),
                        const SizedBox(width: 8),
                        Text(l.notes)
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const NotesScreen()));

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
