// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/task.dart';
import 'package:intl/intl.dart';
import 'package:maximum/screens/add.dart';
import 'package:maximum/utils/relative_date.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key, required this.task});

  final Task task;

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late Task taskDraft = widget.task;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.edit_task)),
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
            children: [
              SizedBox(height: 16),
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
          if (mounted) {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop(true);
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
