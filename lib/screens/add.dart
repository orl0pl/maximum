// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maximum/database/database_helper.dart';
import 'package:maximum/models/note.dart';
import 'package:intl/intl.dart';
import 'package:maximum/models/task.dart';
import 'package:maximum/utils.dart/location.dart';
import 'package:sqflite/sqflite.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

enum EntryType { note, task }

class _AddScreenState extends State<AddScreen> {
  String text = "";
  EntryType entryType = EntryType.note;

  Note noteDraft = Note(
    text: "",
    datetime: DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
  );

  Task taskDraft = Task(
    title: "",
    date: DateFormat('yyyyMMdd').format(DateTime.now()),
  );

  Future<void> fetchAndSetLatLng() async {
    Position? position = await determinePositionWithSnackBar(context, mounted);
    if (position != null && mounted) {
      setState(() {
        noteDraft.lat = position.latitude;
        noteDraft.lng = position.longitude;
      });
    }
    print(position);
  }

  @override
  void initState() {
    super.initState();

    if (mounted) {
      fetchAndSetLatLng();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l?.add ?? "Add")),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
            autofocus: true,
            onChanged: (value) {
              text = value.trim();
              noteDraft.text = text;
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: l?.content_to_add ?? "Content to add"),
          ),
          Spacer(),
          Column(
            children: [
              entryType == EntryType.task
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: Text(l?.today ?? "today"),
                            selected: taskDraft.date ==
                                DateFormat('yyyyMMdd').format(DateTime.now()),
                            onSelected: (bool value) {
                              setState(() {
                                taskDraft.date = DateFormat('yyyyMMdd')
                                    .format(DateTime.now());
                              });
                            },
                          ),
                          SizedBox(width: 8),
                          FilterChip(
                            label: Text(l?.asap ?? "asap"),
                            selected: taskDraft.date == 'ASAP',
                            onSelected: (bool value) {
                              setState(() {
                                taskDraft.date = 'ASAP';
                              });
                            },
                          ),
                          SizedBox(width: 8),
                          FilterChip(
                            label: taskDraft.date != '' &&
                                    taskDraft.date != 'ASAP' &&
                                    taskDraft.date !=
                                        DateFormat('yyyyMMdd')
                                            .format(DateTime.now())
                                ? Text(DateFormat.yMEd().format(
                                    taskDraft.convertDatetime() ??
                                        DateTime.now()))
                                : Text(l?.pick_date ?? "pick date"),
                            selected: taskDraft.date != '' &&
                                taskDraft.date != 'ASAP' &&
                                taskDraft.date !=
                                    DateFormat('yyyyMMdd')
                                        .format(DateTime.now()),
                            onSelected: (bool value) async {
                              final selectedDate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1970),
                                  lastDate: DateTime(2100),
                                  currentDate: taskDraft.convertDatetime() ??
                                      DateTime.now());
                              if (selectedDate != null && mounted) {
                                setState(() {
                                  taskDraft.date = DateFormat('yyyyMMdd')
                                      .format(selectedDate);
                                });
                              }
                            },
                          ),
                          SizedBox(width: 8),
                          FilterChip(
                            label: Text(l?.pick_time ?? "pick time"),
                            onSelected: (bool value) {},
                          ),
                          SizedBox(width: 8),
                          FilterChip(
                            label: Text(l?.someday ?? "someday"),
                            selected: taskDraft.date == '',
                            onSelected: (bool value) {},
                          ),
                        ],
                      ),
                    )
                  : Container(),
              SizedBox(height: 16),
              Row(
                children: [
                  FilterChip(
                      label: Text(l?.note ?? "note"),
                      selected: entryType == EntryType.note,
                      onSelected: (bool selected) {
                        setState(() {
                          entryType = EntryType.note;
                        });
                      }),
                  SizedBox(width: 8),
                  FilterChip(
                      label: Text(l?.task ?? "task"),
                      selected: entryType == EntryType.task,
                      onSelected: (bool selected) {
                        setState(() {
                          entryType = EntryType.task;
                        });
                      }),
                ],
              ),
            ],
          )
        ]),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print(noteDraft.toMap());
          DatabaseHelper dh = DatabaseHelper();
          Database db = await dh.database;
          if (entryType == EntryType.note) {
            db.insert("Note", noteDraft.toMap());
          }
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
