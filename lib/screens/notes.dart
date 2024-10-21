import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/note.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:maximum/screens/add.dart';
import 'package:maximum/widgets/common/note.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maximum/widgets/common/tag_label.dart';

enum NotesListViewEntryType { note, label }

class NotesListViewEntry {
  NotesListViewEntryType type;
  Note? note;
  Text? label;
  NotesListViewEntry({required this.type, this.note, this.label});
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  NotesScreenState createState() => NotesScreenState();
}

class NotesScreenState extends State<NotesScreen> {
  List<NotesListViewEntry>? entryList;
  List<Note>? notes;
  List<Place>? places;
  Set<int> selectedPlacesIds = {};
  List<Tag>? tags;
  Set<int> selectedTagsIds = {};

  DatabaseHelper db = DatabaseHelper();
  void fetchNotes() async {
    late List<Note> notes;
    if (selectedTagsIds.isEmpty) {
      notes = await db.notes;
    } else {
      notes = await db.getNotesByTags(selectedTagsIds.toList());
    }

    if (selectedPlacesIds.isNotEmpty) {
      notes = notes.where((note) {
        return selectedPlacesIds.contains(note.placeId);
      }).toList();
    }
    List<NotesListViewEntry> entryListTemp = [];
    var groupedNotes = groupNotesByDate(notes);

    groupedNotes.forEach((key, value) {
      entryListTemp.add(NotesListViewEntry(
          type: NotesListViewEntryType.label,
          label: Text(
            DateFormat.yMMMMEEEEd().format(key),
            style: Theme.of(context).textTheme.labelLarge,
          )));
      entryListTemp.addAll(value.map((note) =>
          NotesListViewEntry(type: NotesListViewEntryType.note, note: note)));
    });

    if (mounted) {
      setState(() {
        this.notes = notes;
        entryList = entryListTemp;
      });
    }
  }

  void fetchPlaces() async {
    List<Place> places = await db.getPlaces();
    if (mounted) {
      setState(() {
        this.places = places;
      });
    }
  }

  void fetchTags() async {
    List<Tag> tags = await db.noteTags;
    if (mounted) {
      setState(() {
        this.tags = tags;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotes();
    fetchPlaces();
    fetchTags();
  }

  Map<DateTime, List<Note>> groupNotesByDate(List<Note>? notes) {
    if (notes == null) {
      return {};
    }

    Map<DateTime, List<Note>> groupedNotes = {};

    for (var note in notes) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(note.datetime)
          .copyWith(
              hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
      if (!groupedNotes.containsKey(date)) {
        groupedNotes[date] = [];
      }
      groupedNotes[date]?.add(note);
    }

    return groupedNotes;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.notes),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) {
            return const AddScreen(
                entryType: EntryType.note, returnToHome: false);
          }));
          fetchNotes();
        },
      ),
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ...?tags?.map((tag) {
                        return Row(
                          children: [
                            FilterChip(
                                label: TagLabel(tag: tag),
                                selected: selectedTagsIds.contains(tag.tagId),
                                onSelected: (_) {
                                  setState(() {
                                    if (selectedTagsIds.contains(tag.tagId)) {
                                      selectedTagsIds.remove(tag.tagId);
                                    } else {
                                      selectedTagsIds.add(tag.tagId ?? -1);
                                    }
                                    fetchNotes();
                                  });
                                }),
                            const SizedBox(width: 8),
                          ],
                        );
                      }),
                      const VerticalDivider(),
                      const SizedBox(width: 8),
                      ...?places?.map((place) {
                        return Row(
                          children: [
                            FilterChip(
                                label: Text(place.name),
                                selected:
                                    selectedPlacesIds.contains(place.placeId),
                                onSelected: (_) {
                                  setState(() {
                                    if (selectedPlacesIds
                                        .contains(place.placeId)) {
                                      selectedPlacesIds.remove(place.placeId);
                                    } else {
                                      selectedPlacesIds
                                          .add(place.placeId ?? -1);
                                    }
                                    fetchNotes();
                                  });
                                }),
                            const SizedBox(width: 8),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              )),
          const Divider(),
          Expanded(
              child: entryList == null
                  ? const Center(child: CircularProgressIndicator())
                  : notes?.isNotEmpty == false
                      ? Center(child: Text(l.no_notes))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: entryList!.length,
                          itemBuilder: (context, index) {
                            if (entryList![index].type ==
                                NotesListViewEntryType.label) {
                              return Container(
                                child: entryList![index].label!,
                                margin: EdgeInsets.only(bottom: 8, top: 16),
                              );
                            } else if (entryList![index].note != null) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: NoteWidget(
                                  note: entryList![index].note!,
                                  refresh: () => fetchNotes(),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ))
        ]),
      ),
    );
  }
}
