import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:installed_apps/app_info.dart';
import 'package:maximum/database/database_helper.dart';
import 'package:maximum/models/note.dart';
import 'package:intl/intl.dart';

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
    if (allMatches[0].type == ElementType.app) {
      LaunchApp.openApp(
        androidPackageName: allMatches[0].app!.packageName,
      );
    }
  }

  Widget build(BuildContext context) {
    List<AppInfo> allapps = widget.apps;
    bool isLoading = widget.isLoading;

    final fuse = Fuzzy(allapps.map((e) => e.name.toLowerCase()).toList());
    final matches = fuse.search(widget.inputValue.toLowerCase());
    final appMatches = widget.inputValue == ""
        ? allapps
        : matches.where((match) => match.score < 0.50).map((match) {
            return allapps
                .firstWhere((app) => app.name.toLowerCase() == match.item);
          }).toList();

    List<AppInfo> apps = appMatches;

    var noteMatches = [];
    DatabaseHelper().database.then((db) async {
      if (!notesLoaded) {
        db.query('Note').then((notes) {
          setState(() {
            allnotes = notes.map((note) => Note.fromMap(note)).toList();
            notesLoaded = true;
          });

          print(notes);
        });
      }
    });
    var notefuse = Fuzzy(allnotes.map((e) => e.text.toLowerCase()).toList());
    var notematches = notefuse.search(widget.inputValue.toLowerCase());

    noteMatches = notematches.where((match) => match.score < 0.50).map((match) {
      return allnotes
          .firstWhere((note) => note.text.toLowerCase() == match.item);
    }).toList();
    allMatches = widget.inputValue == ""
        ? apps.map((e) => Element.fromApp(e)).toList()
        : apps.map((e) => Element.fromApp(e)).toList() +
            noteMatches.map((e) => Element.fromNote(e)).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: widget.inputValue != ""
                ? Text(
                    "Best match:",
                    style: widget.textTheme.titleSmall,
                  )
                : Text(
                    "All apps",
                    style: widget.textTheme.titleSmall,
                  ),
          ),
          Text(allMatches
              .where((x) => x.type == ElementType.note)
              .length
              .toString()),
          Text(allnotes.length.toString()),
          Flexible(
            flex: 1,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : allMatches.isEmpty
                    ? const Center(
                        child: Text("Nothing found!"),
                      )
                    : ListView.builder(
                        itemCount: allMatches.length,
                        itemBuilder: (context, index) {
                          if (allMatches[index].type == ElementType.app) {
                            return ListTile(
                              tileColor: index == 0 && widget.inputValue != ""
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              leading: allMatches[index].app!.icon != null
                                  ? Image.memory(
                                      allMatches[index].app!.icon!,
                                      width: 40,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.error);
                                      },
                                    )
                                  : null,
                              trailing: index == 0 && widget.inputValue != ""
                                  ? const Icon(Icons.chevron_right)
                                  : null,
                              title: Text(allMatches[index].app!.name),
                              onTap: openTopMatch,
                            );
                          } else if (allMatches[index].type ==
                              ElementType.note) {
                            return ListTile(
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
                                  .format(allMatches[index]
                                      .note!
                                      .converDatetime())),
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
