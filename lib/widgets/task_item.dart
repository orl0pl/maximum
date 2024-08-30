import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maximum/database/database_helper.dart';
import 'package:maximum/models/task.dart';
import 'package:maximum/utils/relative_date.dart';
import 'package:maximum/widgets/info_chip.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations? l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Checkbox(
                  value: task.completed == 1,
                  onChanged: (value) {
                    var newTask = task;
                    newTask.completed = value == true ? 1 : 0;
                    DatabaseHelper().updateTask(newTask);
                  }),
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
                  subtitle: task.isDateSet ? formatDate(task.datetime!, l) : '',
                  textTheme: textTheme,
                  variant:
                      task.datetime?.isBefore(DateTime.now()) ?? task.isAsap
                          ? ChipVariant.primary
                          : ChipVariant.secondary),
            ],
          )
        ],
      ),
    );
  }
}
