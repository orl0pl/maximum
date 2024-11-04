import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:maximum/data/models/repeat_data.dart';
import 'package:maximum/data/models/task.dart';

getFormatedRepeat(String repeatType, int repeatInterval, String repeatDays,
    AppLocalizations l) {
  if (repeatType == "DAILY") {
    return "${l.pick_repeat_dialog_each_text} $repeatInterval ${l.days_num_plural(repeatInterval)}";
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
    AppLocalizations l = AppLocalizations.of(context);
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
                        if (mounted) {
                          setState(() {
                            repeatData = null;
                          });
                        }
                      }),
                  const SizedBox(width: 8),
                  FilterChip(
                      label: Text(l.pick_repeat_dialog_each_x_days),
                      selected: repeatData?.repeatType == RepeatType.daily,
                      onSelected: (value) {
                        if (mounted) {
                          setState(() {
                            repeatData = RepeatData(
                                repeatType: RepeatType.daily, repeatData: "1");
                          });
                        }
                      }),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(l.pick_repeat_dialog_weekdays),
                    selected: repeatData?.repeatType == RepeatType.dayOfWeek,
                    onSelected: (value) {
                      if (mounted) {
                        setState(() {
                          repeatData = RepeatData(
                              repeatType: RepeatType.dayOfWeek,
                              repeatData: "0000000");
                        });
                      }
                    },
                  )
                ],
              ),
            ),
            if (repeatData != null) ...[
              const Divider(),
              if (repeatData!.repeatType == RepeatType.daily) ...[
                TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: repeatData!.repeatInterval.toString(),
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        final int? interval = int.tryParse(value);
                        if (interval != null && interval > 0) {
                          repeatData!.repeatInterval = interval;
                        }
                      });
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    final int? interval = int.tryParse(value ?? "");
                    if (interval == null || interval <= 0) {
                      return l.pick_repeat_dialog_error_interval;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      label: Text(
                          l.days_num_plural(repeatData?.repeatInterval ?? 1))),
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
                          if (mounted) {
                            setState(() {
                              repeatData!.setWeekday(index, selected);
                            });
                          }
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
