import 'package:flutter/material.dart';
import 'package:maximum/database/database_helper.dart';
import 'package:maximum/models/task.dart';
import 'package:maximum/widgets/info_chip.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
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
                    DatabaseHelper().database.then((db) {
                      db.update('Task', newTask.toMap(),
                          where: "id = ?", whereArgs: [task.id]);
                    });
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
                  subtitle: task.date,
                  textTheme: textTheme,
                  variant: task.datetime?.isAfter(DateTime.now()) ?? task.isAsap
                      ? ChipVariant.primary
                      : ChipVariant.secondary),
            ],
          )
        ],
      ),
    );
  }
}
