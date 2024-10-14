import 'package:android_intent_plus/android_intent.dart';
import 'package:app_launcher/app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:installed_apps/app_info.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/note.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/* TODO: Use LauncherApps
 * documentation: https://developer.android.com/reference/android/content/pm/LauncherApps
 * get activity list method: https://developer.android.com/reference/android/content/pm/LauncherApps#getActivityList(java.lang.String,%20android.os.UserHandle)
*/

enum ElementType { app, note }

class Element {
  final ElementType type;
  final AppInfo? app;
  final Note? note;

  Element({required this.type, this.app, this.note});

  static Element fromApp(AppInfo app) {
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

  final List<AppInfo> apps;

  final bool isLoading;

  @override
  State<AppsWidget> createState() => AppsWidgetState();
}

class AppsWidgetState extends State<AppsWidget> {
  List<Element> allMatches = [];

  bool notesLoaded = false;
  List<Note> allnotes = [];

  void openTopMatch() {
    if (widget.inputValue.trim().endsWith('.g')) {
      var intent =
          AndroidIntent(action: 'android.intent.action.WEB_SEARCH', arguments: {
        'query':
            widget.inputValue.trim().substring(0, widget.inputValue.length - 2)
      });

      intent.launch();
    } else if (allMatches.isNotEmpty) {
      if (allMatches[0].type == ElementType.app) {
        AppLauncher.openApp(
          androidApplicationId: allMatches[0].app!.packageName,
        );
      }
    }
  }

  bool get searchExternal {
    if (widget.inputValue.trim().endsWith('.g')) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    if (!notesLoaded) {
      DatabaseHelper().notes.then((notes) async {
        allnotes = notes;
      });
    }

    if (widget.inputValue.isEmpty) {
      allMatches = widget.apps.map((e) => Element.fromApp(e)).toList();
    } else {
      Fuzzy<Element> fuse = Fuzzy(
          allnotes.map((e) => (Element.fromNote(e))).toList() +
              widget.apps.map((e) => (Element.fromApp(e))).toList(),
          options: FuzzyOptions(keys: [
            WeightedKey(
                name: 'name',
                getter: (obj) {
                  if (obj.type == ElementType.note) {
                    return obj.note!.text.toLowerCase();
                  } else {
                    return obj.app!.name.toLowerCase();
                  }
                },
                weight: 1)
          ], threshold: 0.4));
      final matches = fuse.search(widget.inputValue.toLowerCase());
      allMatches = matches.map((e) => e.item).toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: widget.inputValue != ""
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
                    : ListView.builder(
                        // shrinkWrap: true,
                        itemCount: allMatches.length,
                        itemBuilder: (context, index) {
                          if (allMatches[index].type == ElementType.app) {
                            return AppListEntry(
                                widget: widget, app: allMatches[index].app!);
                          } else if (allMatches[index].type ==
                              ElementType.note) {
                            return ListTile(
                              leading: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
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
          )
        ],
      ),
    );
  }
}

class AppListEntry extends StatelessWidget {
  const AppListEntry({
    super.key,
    required this.widget,
    required this.app,
    this.highlight = false,
  });

  final AppsWidget widget;
  final AppInfo app;

  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor:
          highlight ? Theme.of(context).colorScheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      leading: app.icon != null
          ? Image.memory(
              app.icon!,
              width: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error);
              },
            )
          : null,
      trailing: highlight ? const Icon(Icons.chevron_right) : null,
      title: Text(app.name),
      onTap: () {
        AppLauncher.openApp(androidApplicationId: app.packageName);
      },
    );
  }
}
