import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/note.dart';
import 'package:intl/intl.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:maximum/data/models/task.dart';
import 'package:maximum/utils/location.dart';
import 'package:maximum/widgets/add_screen/task.dart';

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
  List<Tag>? _taskTags;
  List<Tag>? _noteTags;
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

  void updateDataForTask(Task task) {
    setState(() {
      taskDraft = task;
    });
  }

  void updateTagsForTask(Set<int> tags) {
    setState(() {
      selectedTaskTagsIds = tags;
    });
  }

  void updatePlaceForTask(int? place) {
    setState(() {
      taskDraft.placeId = place;
    });
  }

  void submit() async {
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
    if (mounted) {
      if (widget.returnToHome) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  bool get canSubmit => false; //text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.add)),
      body: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: l.content_to_add,
              border: InputBorder.none,
            ),
            onChanged: (value) {
              setState(() {
                text = value.trim();
                noteDraft.text = value.trim();
                taskDraft.text = value.trim();
              });
            },
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        if (entryType == EntryType.task)
          TaskAdding(
            updateDataForTask: updateDataForTask,
            updateTagsForTask: updateTagsForTask,
            selectedTagsIds: selectedTaskTagsIds,
            taskDraft: taskDraft,
            places: places,
            tags: _taskTags,
          ),
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              SegmentedButton(
                  showSelectedIcon: false,
                  multiSelectionEnabled: false,
                  segments: const [
                    ButtonSegment(
                        value: EntryType.note,
                        icon: Icon(MdiIcons.noteOutline)),
                    ButtonSegment(
                        value: EntryType.task,
                        icon: Icon(MdiIcons.checkboxMarkedCircleOutline)),
                  ],
                  selected: {entryType},
                  onSelectionChanged: (value) {
                    setState(() {
                      entryType = value.last;
                    });
                  }),
              const Spacer(),
              FilledButton.icon(
                  onPressed: canSubmit ? submit : null, label: Text(l.save)),
            ],
          ),
        ),
      ])),
    );
  }
}
