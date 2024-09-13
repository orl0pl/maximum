import 'package:flutter/material.dart';
import 'package:maximum/database/database_helper.dart';
import 'package:maximum/models/task.dart';
import 'package:maximum/screens/edit_task.dart';
import 'package:maximum/screens/timeline.dart';
import 'package:maximum/utils/relative_date.dart';
import 'package:maximum/widgets/info_chip.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  final Function refresh;

  final bool clickable;

  const TaskItem(
      {super.key,
      required this.task,
      required this.refresh,
      this.clickable = false});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations? l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: InkWell(
          onLongPress: () => {
            print(task.datetime),
          },
          onTap: clickable
              ? () async {
                  bool? edited =
                      await Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return EditTaskScreen(
                        task: task,
                      );
                    },
                  ));
                  if (edited == true) refresh();
                }
              : () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const TimelineScreen()));
                },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                      value: task.completed == 1, onChanged: checkCheckbox),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  InfoChip(
                      subtitle:
                          task.isDateSet ? formatTaskDateAndTime(task, l) : '',
                      textTheme: textTheme,
                      variant: task.isDue || task.isAsap
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

  void checkCheckbox(bool? value) {
    var newTask = task;
    newTask.completed = value == true ? 1 : 0;
    DatabaseHelper().updateTask(newTask);
    refresh();
  }
}
