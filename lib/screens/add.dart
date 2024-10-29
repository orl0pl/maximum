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
import 'package:maximum/utils/enums.dart';
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
        child: Column(children: [
          TextField(
            autofocus: true,
            onChanged: (value) {
              setState(() {
                text = value.trim();
                noteDraft.text = value.trim();
                taskDraft.text = value.trim();
              });
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: l.content_to_add),
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entryType == EntryType.note) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: _noteTags
                              .map((tag) => Row(
                                    children: [
                                      (FilterChip(
                                          label: TagLabel(tag: tag),
                                          onSelected: (value) {
                                            setState(() {
                                              if (value) {
                                                selectedNoteTagsIds
                                                    .add(tag.tagId ?? -1);
                                              } else {
                                                selectedNoteTagsIds
                                                    .remove(tag.tagId ?? -1);
                                              }
                                            });
                                          },
                                          selected: selectedNoteTagsIds
                                              .contains(tag.tagId))),
                                      const SizedBox(width: 8),
                                    ],
                                  ))
                              .toList() +
                          [
                            Row(
                              children: [
                                FilterChip(
                                  label: Text(l.add_tag),
                                  avatar: const Icon(Icons.add),
                                  onSelected: (value) async {
                                    Tag? newTag = await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            const AddOrEditTagDialog());
                                    if (newTag != null) {
                                      DatabaseHelper().insertNoteTag(newTag);
                                      fetchNoteTags();
                                    }
                                  },
                                ),
                              ],
                            )
                          ]),
                ),
              ],
              if (entryType == EntryType.task) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: places
                            .map((place) => Row(
                                  children: [
                                    FilterChip(
                                        label: Text(place.name),
                                        selected:
                                            place.placeId == taskDraft.placeId,
                                        onSelected: (value) {
                                          setState(() {
                                            if (!value) {
                                              taskDraft.placeId = null;
                                            } else {
                                              taskDraft.placeId = place.placeId;
                                            }
                                          });
                                        }),
                                    SizedBox(width: 8),
                                  ],
                                ))
                            .toList() +
                        [
                          Row(
                            children: [
                              FilterChip(
                                  label: Text(l.add_place),
                                  avatar: Icon(MdiIcons.mapMarkerPlus),
                                  onSelected: (value) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AddOrEditPlaceScreen()));
                                    setState(() {});
                                  })
                            ],
                          )
                        ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: _taskTags
                              .map((tag) => Row(
                                    children: [
                                      (FilterChip(
                                          label: Row(
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: HSLColor.fromAHSL(
                                                          1,
                                                          int.tryParse(
                                                                      tag.color)
                                                                  ?.toDouble() ??
                                                              0,
                                                          1,
                                                          0.5)
                                                      .toColor(),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(tag.name)
                                            ],
                                          ),
                                          onSelected: (value) {
                                            setState(() {
                                              if (value) {
                                                selectedTaskTagsIds
                                                    .add(tag.tagId ?? -1);
                                              } else {
                                                selectedTaskTagsIds
                                                    .remove(tag.tagId ?? -1);
                                              }
                                            });
                                          },
                                          selected: selectedTaskTagsIds
                                              .contains(tag.tagId))),
                                      const SizedBox(width: 8),
                                    ],
                                  ))
                              .toList() +
                          [
                            Row(
                              children: [
                                FilterChip(
                                  label: Text(l.add_tag),
                                  avatar: const Icon(Icons.add),
                                  onSelected: (value) async {
                                    Tag? newTag = await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            const AddOrEditTagDialog());
                                    if (newTag != null) {
                                      DatabaseHelper().insertTaskTag(newTag);
                                      fetchTaskTags();
                                    }
                                  },
                                ),
                              ],
                            )
                          ]),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FilterChip(
                        avatar: !taskDraft.isDateSet
                            ? Icon(Icons.calendar_month)
                            : null,
                        label: taskDraft.isDateSet
                            ? Text(formatDate(taskDraft.datetime!, l))
                            : Text(l.pick_date),
                        selected: taskDraft.isDateSet,
                        onSelected: (bool value) async {
                          if (value) {
                            final selectedDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1970),
                              lastDate: DateTime(2100),
                              initialDate: taskDraft.datetime ?? DateTime.now(),
                            );
                            if (selectedDate != null && mounted) {
                              setState(() {
                                taskDraft.date =
                                    DateFormat('yyyyMMdd').format(selectedDate);
                              });
                            }
                          } else {
                            setState(() {
                              taskDraft.date = '';
                              taskDraft.time = null;
                            });
                          }
                        },
                      ),
                      SizedBox(width: 8),
                      taskDraft.isDateSet
                          ? FilterChip(
                              label: taskDraft.time != null
                                  ? Text(DateFormat.Hm().format(
                                      taskDraft.datetime ?? DateTime.now()))
                                  : Text(l.pick_time),
                              selected: taskDraft.isTimeSet,
                              onSelected: (bool value) async {
                                if (value) {
                                  final selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now());
                                  if (selectedTime != null && mounted) {
                                    setState(() {
                                      taskDraft.time = DateFormat("HHmm")
                                          .format(DateTime(
                                              2000,
                                              1,
                                              1,
                                              selectedTime.hour,
                                              selectedTime.minute));
                                    });
                                  }
                                } else {
                                  if (mounted) {
                                    setState(() {
                                      taskDraft.time = null;
                                    });
                                  }
                                }
                              },
                            )
                          : SizedBox(),
                      SizedBox(width: taskDraft.isDateSet ? 8 : 0),
                      FilterChip(
                        label: taskDraft.datetime != null
                            ? Text(l.deadline)
                            : Text(l.asap),
                        selected: taskDraft.isAsap == 1,
                        onSelected: (value) {
                          setState(() {
                            taskDraft.isAsap = value ? 1 : 0;
                          });
                        },
                      ),
                      SizedBox(width: 8),
                      FilterChip(
                        label: Text(l.repeat),
                        avatar: taskDraft.repeat != null
                            ? Icon(Icons.repeat)
                            : Icon(MdiIcons.repeatOff),
                        showCheckmark: false,
                        selected: taskDraft.repeat != null,
                        onSelected: (value) async {
                          RepeatData? newRepeat = await showDialog(
                              context: context,
                              builder: (context) =>
                                  PickRepeatDialog(taskDraft: taskDraft));
                          if (mounted) {
                            setState(() {
                              taskDraft = taskDraft.replaceRepeat(newRepeat);
                            });
                          }
                        },
                      ),
                      SizedBox(width: 8),
                      FilterChip(
                        label: taskDraft.targetValue == 1
                            ? Text(l.steps_count)
                            : Text(l.steps(taskDraft.targetValue)),
                        avatar: Icon(MdiIcons.counter),
                        showCheckmark: false,
                        selected: taskDraft.targetValue != 1,
                        onSelected: (value) async {
                          int? newValue = await showDialog(
                              context: context,
                              builder: (context) =>
                                  PickTargetValueDialog(taskDraft: taskDraft));
                          if (newValue != null && mounted) {
                            setState(() {
                              taskDraft.targetValue = newValue;
                            });
                          }
                        },
                      )
                    ],
                  ),
                ),
              ],
              Divider(
                thickness: 1,
              ),
              Row(
                children: [
                  FilterChip(
                      label: Text(l.note),
                      selected: entryType == EntryType.note,
                      onSelected: (bool selected) {
                        setState(() {
                          entryType = EntryType.note;
                        });
                      }),
                  SizedBox(width: 8),
                  FilterChip(
                      label: Text(l.task),
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
