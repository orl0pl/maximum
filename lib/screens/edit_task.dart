// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:maximum/data/models/task.dart';
import 'package:intl/intl.dart';
import 'package:maximum/screens/add_place.dart';
import 'package:maximum/utils/relative_date.dart';
import 'package:maximum/widgets/alert_dialogs/pick_repeat.dart';
import 'package:maximum/widgets/alert_dialogs/tag_edit.dart';

enum TaskEditResult { edited, deleted }

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key, required this.task});

  final Task task;

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late Task taskDraft = widget.task;

  List<Tag> _taskTags = [];
  Set<int> selectedTaskTagsIds = {};
  List<Place> places = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    fetchTags();
    fetchPlaces();
    _databaseHelper.getTagsForTask(taskDraft.taskId ?? -1).then((value) {
      setState(() {
        selectedTaskTagsIds = value.map((tag) => tag.tagId!).toSet();
      });
    });
  }

  void fetchTags() async {
    List<Tag> tags = await _databaseHelper.taskTags;
    setState(() {
      _taskTags = tags;
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
    AppLocalizations l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.edit_task), actions: [
        IconButton(
          icon: Icon(Icons.delete_forever_outlined),
          onPressed: () async {
            bool succes = await DatabaseHelper().deleteTask(taskDraft.taskId!);
            if (succes && context.mounted) {
              Navigator.of(context).pop(TaskEditResult.deleted);
            }
          },
        )
      ]),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextFormField(
            autofocus: true,
            initialValue: taskDraft.text,
            onChanged: (value) {
              setState(() {
                taskDraft.text = value.trim();
              });
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: l.content_to_add),
          ),
          Spacer(),
          Text(taskDraft.toMap().toString()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
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
                                  Navigator.of(context).push(MaterialPageRoute(
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
                                    InkWell(
                                      onLongPress: () async {
                                        Tag? newTag = await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                AddOrEditTagDialog(tag: tag));
                                        if (newTag != null) {
                                          await _databaseHelper
                                              .updateTaskTag(newTag);
                                          fetchTags();
                                        }
                                      },
                                      child: (FilterChip(
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
                                    ),
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
                                    fetchTags();
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
                                    taskDraft.time = DateFormat("HHmm").format(
                                        DateTime(2000, 1, 1, selectedTime.hour,
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
                  ],
                ),
              ),
              SizedBox(height: 64),
            ],
          )
        ]),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          DatabaseHelper dh = DatabaseHelper();
          dh.updateTask(taskDraft);
          dh.updateTaskTags(taskDraft.taskId ?? -1, selectedTaskTagsIds);
          if (mounted) {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop(TaskEditResult.edited);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

getFormatedRepeat(String repeatType, int repeatInterval, String repeatDays,
    AppLocalizations? l) {
  if (repeatType == "DAILY") {
    return "${l?.pick_repeat_dialog_each_text} $repeatInterval ${l?.pick_repeat_dialog_select_daily(repeatInterval)}";
  } else if (repeatType == "WEEKLY") {
    return "${l?.pick_repeat_dialog_each_text} $repeatInterval ${repeatDays.split(',').map(
      (e) {
        return DateFormat.EEEE().dateSymbols.WEEKDAYS[int.parse(e)];
      },
    ).join(', ')}";
  }
  return "";
}
