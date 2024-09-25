import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/task.dart';
import 'package:maximum/data/models/task_status.dart';
import 'package:maximum/screens/edit_task.dart';
import 'package:maximum/screens/task_info.dart';
import 'package:maximum/utils/relative_date.dart';
import 'package:maximum/widgets/info_chip.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String formatTaskRepeat(Task task, AppLocalizations l) {
  if (task.repeat == null) {
    return "";
  }
  if (task.repeat!.repeatType == RepeatType.daily) {
    return "${l.pick_repeat_dialog_each_text} ${task.repeat!.repeatData} ${l.pick_repeat_dialog_select_daily(task.repeat!.repeatInterval as num)}";
  }
  if (task.repeat!.repeatType == RepeatType.dayOfWeek) {
    String days = task.repeat!.repeatData
        .split("")
        .map((e) => DateFormat.EEEE().dateSymbols.WEEKDAYS[int.parse(e)])
        .join(", ");
    return "${l.pick_repeat_dialog_each_x_days} $days";
  }

  return "";
}

class TaskItem extends StatelessWidget {
  final Task task;

  final Function refresh;

  final bool clickable;

  const TaskItem(
      {super.key,
      required this.task,
      required this.refresh,
      this.clickable = false});

  String getSubtitleText(AppLocalizations l) {
    if (task.repeat != null) {
      return formatTaskRepeat(task, l);
    }
    if (task.isDateSet) {
      return formatTaskDateAndTime(task, l);
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: InkWell(
          onTap: clickable
              ? () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return TaskInfoScreen(taskId: task.taskId ?? -1);
                    },
                  ));
                }
              : null,
          onLongPress: clickable
              ? () async {
                  TaskEditResult? edited =
                      await Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return EditTaskScreen(
                        task: task,
                      );
                    },
                  ));
                  if (edited == TaskEditResult.edited) refresh();
                  if (edited == TaskEditResult.deleted) refresh();
                }
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FutureBuilder(
                    future: task.completed,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Checkbox(
                          value: snapshot.data,
                          onChanged: checkCheckbox,
                        );
                      } else {
                        return Container(); // or a loading indicator
                      }
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.text,
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  InfoChip(
                      subtitle: getSubtitleText(l),
                      variant: task.isDue || task.asap || task.deadline
                          ? ChipVariant.primary
                          : task.datetime!.isBefore(
                                  DateTime.now().add(const Duration(days: 7)))
                              ? ChipVariant.secondary
                              : ChipVariant.outline),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkCheckbox(bool? value) async {
    DatabaseHelper dh = DatabaseHelper();
    if (task.targetValue == 1 && task.taskId != null) {
      dh.insertTaskStatus(TaskStatus(
          taskId: task.taskId!,
          datetime: DateTime.now().millisecondsSinceEpoch,
          value: value == true ? 1 : 0));
    } else if (task.taskId != null) {
      dh.insertTaskStatus(TaskStatus(
          taskId: task.taskId!,
          datetime: DateTime.now().millisecondsSinceEpoch,
          value:
              await task.getRecentProgressValue() + (value == true ? 1 : 0)));
    }
    refresh();
  }
}
