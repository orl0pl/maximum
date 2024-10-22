import 'dart:typed_data';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:android_package_manager/android_package_manager.dart';
import 'package:app_launcher/app_launcher.dart';

import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/appopen.dart';
import 'package:maximum/data/models/note.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ElementType { app, note }

class Element {
  final ElementType type;
  final ApplicationInfo? app;
  final Note? note;

  Element({required this.type, this.app, this.note});

  static Element fromApp(ApplicationInfo app) {
    return Element(type: ElementType.app, app: app);
  }

  static Element fromNote(Note note) {
    return Element(type: ElementType.note, note: note);
  }
}

class AppsWidget extends StatefulWidget {
  const AppsWidget(
      {super.key,
      required this.textTheme,
      required this.inputValue,
      required this.apps,
      required this.isLoading});

  final TextTheme textTheme;

  final String inputValue;

  final List<ApplicationInfo> apps;

  final bool isLoading;

  @override
  State<AppsWidget> createState() => AppsWidgetState();
}

enum OpenOutcome { notOpened, openedExternal }

class AppsWidgetState extends State<AppsWidget> {
  List<Element> allMatches = [];
  Map<String, int>? appOpenMap;
  bool notesLoaded = false;
  List<Note> allnotes = [];
  Map<String, String> appLabelsMap = {};
  String inputValue = '';
  bool doneSortingAndSearching = false;

  OpenOutcome openTopMatch() {
    if (widget.inputValue.trim().endsWith('.g')) {
      var intent =
          AndroidIntent(action: 'android.intent.action.WEB_SEARCH', flags: [
        Flag.FLAG_ACTIVITY_NEW_TASK
      ], arguments: {
        'query':
            widget.inputValue.trim().substring(0, widget.inputValue.length - 2)
      });

      intent.launch();

      return OpenOutcome.openedExternal;
    } else if (allMatches.isNotEmpty) {
      if (allMatches[0].type == ElementType.app) {
        DatabaseHelper().insertAppOpen(AppOpen(
          packageName: allMatches[0].app!.packageName!,
          datetime: DateTime.now(),
          weekQuarter: getWeekQuarter(DateTime.now()),
          openedVia: AppOpenOpenedVia.search,
        ));
        AppLauncher.openApp(
          androidApplicationId: allMatches[0].app!.packageName!,
        );

        return OpenOutcome.openedExternal;
      }
    }

    return OpenOutcome.notOpened;
  }

  bool get searchExternal {
    if (widget.inputValue.trim().endsWith('.g')) {
      return true;
    }
    return false;
  }

  void fetchAppOpenMap() async {
    appOpenMap = await DatabaseHelper().getRecentAppOpensMapPackageNameCount();
    if (mounted) {
      setState(() {
        appOpenMap = appOpenMap;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    inputValue = widget.inputValue;
    fetchAppOpenMap();
    fetchNotes();
    fetchAppLabelsMap();
    sortAndSearchElements(null);
  }

  void fetchAppLabelsMap() async {
    Map<String, String> appLabelsMapTemp = {};

    for (var app in widget.apps) {
      if (app.packageName != null) {
        var label = (await app.getAppLabel());
        if (label != null) {
          appLabelsMapTemp[app.packageName!] = label;
        }
      }
    }
    if (mounted) {
      setState(() {
        appLabelsMap = appLabelsMapTemp;
      });
    }
  }

  void fetchNotes() async {
    DatabaseHelper().notes.then((notes) async {
      allnotes = notes;
    });
  }

  void sortAndSearchElements(String? input) {
    setState(() {
      doneSortingAndSearching = false;
      inputValue = input ?? widget.inputValue;
    });

    String inp = input ?? widget.inputValue;
    if (inp.isEmpty) {
      allMatches = widget.apps.map((e) => Element.fromApp(e)).toList()
        ..sort((a, b) {
          int? appOpenCountA = appOpenMap?[a.app!.packageName] ?? 0;
          int? appOpenCountB = appOpenMap?[b.app!.packageName] ?? 0;
          return appOpenCountB.compareTo(appOpenCountA);
        });
    } else {
      Fuzzy<Element> fuse = Fuzzy(
          allnotes.map((e) => (Element.fromNote(e))).toList() +
              widget.apps.map((e) => (Element.fromApp(e))).toList(),
          options: FuzzyOptions(
            keys: [
              WeightedKey(
                  name: 'name',
                  getter: (obj) {
                    if (obj.type == ElementType.note) {
                      return obj.note!.text.toLowerCase();
                    } else {
                      return appLabelsMap[obj.app!.packageName]
                              ?.toLowerCase() ??
                          obj.app!.nonLocalizedLabel ??
                          obj.app!.name!;
                    }
                  },
                  weight: 1),
            ],
            threshold: 0.4,
            sortFn: (a, b) {
              if (a.item.type == ElementType.note && appOpenMap == null) {
                return a.score.compareTo(b.score);
              } else if ((a.item.app == null || b.item.app == null)) {
                return a.score.compareTo(b.score);
              } else if (appOpenMap![a.item.app!.packageName] == null ||
                  appOpenMap![b.item.app!.packageName] == null) {
                return a.score.compareTo(b.score);
              } else {
                return a.score.compareTo(b.score) *
                    appOpenMap![a.item.app!.packageName!]!
                        .compareTo(appOpenMap![b.item.app!.packageName!]!);
              }
            },
          ));
      final matches = fuse.search(inp.toLowerCase());
      allMatches = matches.map((e) => e.item).toList();
    }

    setState(() {
      doneSortingAndSearching = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: inputValue != ""
                ? Text(
                    l.best_match,
                    style: widget.textTheme.titleSmall,
                  )
                : Text(
                    l.all_apps,
                    style: widget.textTheme.titleSmall,
                  ),
          ),
          Flexible(
            flex: 1,
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : allMatches.isEmpty
                    ? Center(
                        child: Text(l.nothing_found),
                      )
                    : AnimatedOpacity(
                        opacity: doneSortingAndSearching ? 1.0 : 0.0,
                        duration: Durations.medium1,
                        child: ListView.builder(
                          // shrinkWrap: true,
                          itemCount: allMatches.length,

                          itemBuilder: (context, index) {
                            if (allMatches.length <= index) {
                              return Container();
                            }
                            if (allMatches[index].type == ElementType.app) {
                              return AppListEntry(
                                widget: widget,
                                app: allMatches[index].app!,
                                appLabel: appLabelsMap[
                                    allMatches[index].app!.packageName],
                                appOpenCount: appOpenMap?[
                                        allMatches[index].app!.packageName!] ??
                                    0,
                                isInSearchMode: widget.inputValue != "",
                              );
                            } else if (allMatches[index].type ==
                                ElementType.note) {
                              return ListTile(
                                leading: const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Icon(Icons.note_outlined),
                                ),
                                tileColor: index == 0 && widget.inputValue != ""
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Text(allMatches[index].note!.text),
                                subtitle: Text(DateFormat("dd.MM.yyyy HH:mm")
                                    .format(DateTime.fromMillisecondsSinceEpoch(
                                        allMatches[index].note!.datetime))),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
          )
        ],
      ),
    );
  }
}

enum AppCategory {
  accessibility,
  audio,
  game,
  image,
  maps,
  news,
  productivity,
  social,
  undefined,
  video
}

AppCategory appCategoryFromInt(int i) {
  switch (i) {
    case -1:
      return AppCategory.undefined;
    case 8:
      return AppCategory.accessibility;
    case 1:
      return AppCategory.audio;
    case 0:
      return AppCategory.game;
    case 3:
      return AppCategory.image;
    case 6:
      return AppCategory.maps;
    case 5:
      return AppCategory.news;
    case 7:
      return AppCategory.productivity;
    case 4:
      return AppCategory.social;
    case 2:
      return AppCategory.video;
    default:
      return AppCategory.undefined;
  }
}

class AppListEntry extends StatelessWidget {
  const AppListEntry({
    super.key,
    required this.widget,
    required this.app,
    required this.appLabel,
    required this.appOpenCount,
    this.isInSearchMode = false,
    this.highlight = false,
  });

  final AppsWidget widget;
  final ApplicationInfo app;

  final bool highlight;

  final int? appOpenCount;

  final bool isInSearchMode;

  final String? appLabel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor:
          highlight ? Theme.of(context).colorScheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      leading: FutureBuilder<Uint8List?>(
        future: app.getAppIcon(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              width: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error);
              },
            );
          } else {
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            );
          }
        },
      ),
      //subtitle: appOpenCount == null ? null : Text("$appOpenCount"),
      //subtitle: Text(appCategoryFromInt(app.category ?? -1).toString()),
      trailing: highlight ? const Icon(Icons.chevron_right) : null,
      title: appLabel != null
          ? Text(appLabel!)
          : FutureBuilder<String?>(
              future: app.getAppLabel(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!);
                } else {
                  return Container(
                    width: app.packageName!.length * 8,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    height: 16,
                  );
                }
              },
            ),
      onTap: () async {
        DatabaseHelper().insertAppOpen(AppOpen(
          packageName: app.packageName!,
          datetime: DateTime.now(),
          weekQuarter: getWeekQuarter(DateTime.now()),
          openedVia: isInSearchMode
              ? AppOpenOpenedVia.search
              : AppOpenOpenedVia.appList,
        ));
        AndroidPackageManager().openApp(app.packageName!);
      },
    );
  }
}
