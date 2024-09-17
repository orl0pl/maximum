// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/note.dart';
import 'package:intl/intl.dart';
import 'package:maximum/data/models/task.dart';
import 'package:maximum/utils/location.dart';
import 'package:maximum/utils/relative_date.dart';

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
    // print(position);
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
    AppLocalizations l = AppLocalizations.of(context)!;

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
          Text(entryType == EntryType.task
              ? taskDraft.toMap().toString()
              : noteDraft.toMap().toString()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              entryType == EntryType.task
                  ? SingleChildScrollView(
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
                                  initialDate:
                                      taskDraft.datetime ?? DateTime.now(),
                                );
                                if (selectedDate != null && mounted) {
                                  setState(() {
                                    taskDraft.date = DateFormat('yyyyMMdd')
                                        .format(selectedDate);
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
                                  taskDraft =
                                      taskDraft.replaceRepeat(newRepeat);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  : Container(),
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
                  dh.insertNote(noteDraft);
                } else if (entryType == EntryType.task) {
                  dh.insertTask(taskDraft);
                }
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              child: const Icon(Icons.check),
            )
          : null,
    );
  }
}

getFormatedRepeat(String repeatType, int repeatInterval, String repeatDays,
    AppLocalizations l) {
  if (repeatType == "DAILY") {
    return "${l.pick_repeat_dialog_each_text} $repeatInterval ${l.pick_repeat_dialog_select_daily(repeatInterval)}";
  } else if (repeatType == "WEEKLY") {
    return "${l.pick_repeat_dialog_each_text} $repeatInterval ${repeatDays.split(',').map(
      (e) {
        return DateFormat.EEEE().dateSymbols.WEEKDAYS[int.parse(e)];
      },
    )}";
  }
  return "";
}

class PickRepeatDialog extends StatefulWidget {
  const PickRepeatDialog({required this.taskDraft, super.key});

  final Task taskDraft;

  @override
  PickRepeatDialogState createState() => PickRepeatDialogState();
}

class PickRepeatDialogState extends State<PickRepeatDialog> {
  RepeatData? repeatData;

  @override
  void initState() {
    super.initState();
    repeatData = widget.taskDraft.repeat;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.pick_repeat_dialog_title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                      label: Text(l.off),
                      selected: repeatData == null,
                      onSelected: (value) {
                        setState(() {
                          repeatData = null;
                        });
                      }),
                  SizedBox(width: 8),
                  FilterChip(
                      label: Text(l.pick_repeat_dialog_each_x_days),
                      selected: repeatData?.repeatType == RepeatType.daily,
                      onSelected: (value) {
                        setState(() {
                          repeatData = RepeatData(
                              repeatType: RepeatType.daily, repeatData: "1");
                        });
                      }),
                  SizedBox(width: 8),
                  FilterChip(
                    label: Text(l.pick_repeat_dialog_weekdays),
                    selected: repeatData?.repeatType == RepeatType.dayOfWeek,
                    onSelected: (value) {
                      setState(() {
                        repeatData = RepeatData(
                            repeatType: RepeatType.dayOfWeek,
                            repeatData: "0000000");
                      });
                    },
                  )
                ],
              ),
            ),
            if (repeatData != null) ...[
              Divider(),
              if (repeatData!.repeatType == RepeatType.daily) ...[
                TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: repeatData!.repeatInterval.toString(),
                  onChanged: (value) {
                    setState(() {
                      final int? interval = int.tryParse(value);
                      if (interval != null && interval > 0) {
                        repeatData!.repeatInterval = interval;
                      }
                    });
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    final int? interval = int.tryParse(value ?? "");
                    if (interval == null || interval <= 0) {
                      return "l.pick_repeat_dialog_error_interval";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text(l.pick_repeat_dialog_select_daily(
                          repeatData?.repeatInterval ?? 1))),
                )
              ],
              if (repeatData!.repeatType == RepeatType.dayOfWeek) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: List.generate(7, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label:
                            Text(DateFormat.EEEE().dateSymbols.WEEKDAYS[index]),
                        selected: repeatData!.weekdays[index],
                        onSelected: (bool selected) {
                          setState(() {
                            repeatData!.setWeekday(index, selected);
                          });
                        },
                      ),
                    );
                  }, growable: false)),
                )
              ]
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(repeatData);
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}
