// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
            children: [
              // entryType == EntryType.task
              //     ? SingleChildScrollView(
              //         scrollDirection: Axis.horizontal,
              //         child: Row(children: [
              //           ActionChip(
              //             avatar: Icon(Icons.repeat_on),
              //             label: Text(getFormatedRepeat(
              //                 taskDraft.repeatType ?? "",
              //                 taskDraft.repeatInterval ?? 0,
              //                 taskDraft.repeatDays ?? "",
              //                 l)),
              //             onPressed: () async {
              //               var result = await showDialog(
              //                   context: context,
              //                   builder: (context) => PickRepeatDialog(
              //                         taskDraft: taskDraft,
              //                       ));
              //               if (result != null && mounted) {
              //                 setState(() {
              //                   taskDraft.repeatDays = result[2];
              //                   taskDraft.repeatInterval = result[1];
              //                   taskDraft.repeatType = result[0];
              //                 });
              //               }
              //             },
              //           ),
              //           SizedBox(width: 8),
              //         ]))
              //     : SizedBox(),
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
                        ],
                      ),
                    )
                  : Container(),
              SizedBox(height: 16),
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
      floatingActionButton: FloatingActionButton(
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
      ),
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

// TODO: make proper implementation and add it again
// class PickRepeatDialog extends StatefulWidget {
//   const PickRepeatDialog({required this.taskDraft, super.key});

//   final Task taskDraft;

//   @override
//   PickRepeatDialogState createState() => PickRepeatDialogState();
// }

// class PickRepeatDialogState extends State<PickRepeatDialog> {
//   late String repeatType = widget.taskDraft.repeatType;
//   late int repeatInterval = widget.taskDraft.repeatInterval ?? 1;
//   late String repeatDays = widget.taskDraft.repeatDays ?? "";

//   @override
//   Widget build(BuildContext context) {
//     AppLocalizations? l = AppLocalizations.of(context);
//     return AlertDialog(
//       title: Text(l.pick_repeat_dialog_title),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(l.pick_repeat_dialog_each_text),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(
//                   width: 40,
//                   child: TextFormField(
//                     onChanged: (value) {
//                       setState(() {
//                         repeatInterval = int.parse(value.isEmpty ? "0" : value);
//                       });
//                     },
//                     keyboardType: TextInputType.number,
//                     initialValue: (1).toString(),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 DropdownMenu(
//                   key: ValueKey(repeatInterval), // force redraw when changed
//                   dropdownMenuEntries: [
//                     DropdownMenuEntry(
//                         value: "DAILY",
//                         label: l.pick_repeat_dialog_select_daily(
//                                 repeatInterval) ??
//                             "l.daily"),
//                     DropdownMenuEntry(
//                         value: "WEEKLY",
//                         label: l.pick_repeat_dialog_select_weekly(
//                                 repeatInterval) ??
//                             "l.weekly"),
//                     // TODO: Handle month and year repeats in the future
//                     // DropdownMenuEntry(
//                     //     value: "MONTHLY_DAY",
//                     //     label: l.pick_repeat_dialog_select_monthly(
//                     //             repeatInterval) ??
//                     //         "l.monthly_day"),
//                     // DropdownMenuEntry(
//                     //     value: "YEARLY",
//                     //     label: l.pick_repeat_dialog_select_yearly(
//                     //             repeatInterval) ??
//                     //         "l.yearly"),
//                   ],
//                   initialSelection: repeatType,
//                   onSelected: (value) {
//                     setState(() {
//                       repeatType = value;
//                     });
//                     if (repeatType == "WEEKLY") {
//                       setState(() {
//                         repeatDays = "${DateTime.now().weekday}";
//                       });
//                     }
//                   },
//                 )
//               ],
//             ),
//             repeatType == "WEEKLY"
//                 ? Column(
//                     children: [
//                       Column(
//                         children: List.generate(
//                             7,
//                             (index) => Row(
//                                   children: [
//                                     Checkbox(
//                                       value: repeatDays
//                                           .split(",")
//                                           .contains(index.toString()),
//                                       onChanged: (value) {
//                                         List<String> repeatDaysList =
//                                             repeatDays.split(",");
//                                         if (value ?? false) {
//                                           repeatDaysList.add(index.toString());
//                                         } else {
//                                           repeatDaysList
//                                               .remove(index.toString());
//                                         }
//                                         repeatDaysList
//                                             .removeWhere((e) => (e.isEmpty));
//                                         setState(() {
//                                           repeatDays = repeatDaysList.join(",");
//                                         });
//                                       },
//                                     ),
//                                     Text(DateFormat.EEEE()
//                                         .dateSymbols
//                                         .WEEKDAYS[index])
//                                   ],
//                                 )),
//                       ),
//                     ],
//                   )
//                 : repeatDays == "MONTHLY_DAY"
//                     ? Column(children: const [])
//                     : SizedBox()
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           child: Text('Cancel'),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         TextButton(
//           child: Text('OK'),
//           onPressed: repeatType == "WEEKLY" && repeatDays.split(",").isEmpty
//               ? null
//               : () {
//                   Navigator.of(context)
//                       .pop([repeatType, repeatInterval, repeatDays]);
//                 },
//         ),
//       ],
//     );
//   }
// }
