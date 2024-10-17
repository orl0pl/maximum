// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/note.dart';
import 'package:intl/intl.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/data/models/repeat_data.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:maximum/data/models/task.dart';
import 'package:maximum/screens/add_place.dart';
import 'package:maximum/utils/location.dart';
import 'package:maximum/utils/relative_date.dart';
import 'package:maximum/widgets/alert_dialogs/pick_repeat.dart';
import 'package:maximum/widgets/alert_dialogs/pick_steps_count.dart';
import 'package:maximum/widgets/alert_dialogs/tag_edit.dart';
import 'package:maximum/widgets/common/tag_label.dart';

class AddScreen extends StatefulWidget {
  const AddScreen(
      {super.key, this.entryType = EntryType.note, this.returnToHome = true});
  final EntryType entryType;
  final bool returnToHome;

  @override
  State<AddScreen> createState() => _AddScreenState();
}

enum EntryType { note, task }

class _AddScreenState extends State<AddScreen> {
  String text = "";
  List<Tag> _taskTags = [];
  List<Tag> _noteTags = [];
  Set<int> selectedTaskTagsIds = {};
  Set<int> selectedNoteTagsIds = {};
  EntryType entryType = EntryType.note;
  List<Place> places = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Note noteDraft = Note(
    text: "",
    datetime: DateTime.now().millisecondsSinceEpoch,
  );

  Task taskDraft = Task(
    text: "",
    date: DateFormat('yyyyMMdd').format(DateTime.now()),
  );

  get canAdd => text.isNotEmpty;

  Future<void> fetchAndSetLatLng() async {
    Position? position = await determinePositionWithSnackBar(context, mounted);
    if (position != null && mounted) {
      setState(() {
        noteDraft.lat = position.latitude;
        noteDraft.lng = position.longitude;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (mounted) {
      fetchAndSetLatLng();
    }
    fetchNoteTags();
    fetchTaskTags();
    fetchPlaces();
  }

  void fetchTaskTags() async {
    List<Tag> tags = await _databaseHelper.taskTags;
    setState(() {
      _taskTags = tags;
    });
  }

  void fetchNoteTags() async {
    List<Tag> tags = await _databaseHelper.noteTags;
    setState(() {
      _noteTags = tags;
    });
  }

  void fetchPlaces() async {
    List<Place> places = await _databaseHelper.getPlaces();
    setState(() {
      this.places = places;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.add)),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Spacer(),
          Row(
            children: [
              InputChip(
                avatar: Icon(MdiIcons.calendarMonth),
                label: Text("21/12/2022"),
                onDeleted: () {},
              ),
              const SizedBox(width: 8),
              InputChip(
                avatar: Icon(MdiIcons.clock),
                label: Text("12:00"),
                onDeleted: () {},
              ),
              const SizedBox(width: 8),
              InputChip(
                avatar: Icon(MdiIcons.mapMarker),
                label: Text("Home"),
                onDeleted: () {},
              ),
            ],
          )
        ]),
      )),
      persistentFooterAlignment: AlignmentDirectional.centerStart,
      persistentFooterButtons: [
        Row(
          children: [
            Row(
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.calendar_month)),
                IconButton(onPressed: () {}, icon: Icon(MdiIcons.clockOutline)),
                IconButton(
                    onPressed: () {}, icon: Icon(MdiIcons.mapMarkerOutline)),
                IconButton(onPressed: () {}, icon: Icon(MdiIcons.counter)),
                IconButton(
                    onPressed: () {}, icon: Icon(MdiIcons.tagMultipleOutline)),
              ],
            ),
            Spacer(),
            Row(
              children: [
                FilledButton.icon(onPressed: () {}, label: Text("Save")),
              ],
            ),
          ],
        )
      ],
      floatingActionButton: canAdd
          ? FloatingActionButton(
              onPressed: () async {
                DatabaseHelper dh = DatabaseHelper();
                if (entryType == EntryType.note) {
                  int newNoteId = await dh.insertNote(noteDraft);
                  if (newNoteId != -1) {
                    dh.updateNoteTags(newNoteId, selectedNoteTagsIds);
                  }
                } else if (entryType == EntryType.task) {
                  int newTaskId = await dh.insertTask(taskDraft);
                  if (newTaskId != -1) {
                    dh.updateTaskTags(newTaskId, selectedTaskTagsIds);
                  }
                }
                if (context.mounted) {
                  if (widget.returnToHome) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Icon(Icons.check),
            )
          : null,
    );
  }
}
