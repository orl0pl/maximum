import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:intl/intl.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/data/models/repeat_data.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:maximum/data/models/task.dart';
import 'package:maximum/data/models/task_status.dart';
import 'package:maximum/screens/edit_task.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maximum/screens/task_info.dart';
import 'package:maximum/widgets/add_screen/task.dart';
import 'package:maximum/widgets/common/info_chip.dart';
import 'package:maximum/widgets/common/tag_label.dart';

class TaskProgressScreen extends StatefulWidget {
  final int taskId;

  const TaskProgressScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  State<TaskProgressScreen> createState() => _TaskProgressScreenState();
}

class _TaskProgressScreenState extends State<TaskProgressScreen> {
  Task? task;
  bool loaded = false;
  List<TaskStatus>? taskStatuses;
  Map<DateTime, List<TaskStatus>> taskStatusesByDate = {};

  void fetchTask() async {
    DatabaseHelper dh = DatabaseHelper();
    task = await dh.getTask(widget.taskId);
    taskStatuses = await dh.getTaskStatuses(widget.taskId);
    taskStatuses?.forEach((status) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(status.datetime)
          .copyWith(
              hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
      if (!taskStatusesByDate.containsKey(date)) {
        taskStatusesByDate[date] = [];
      }
      taskStatusesByDate[date]?.add(status);
    });
    setState(() {
      loaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.progress_title),
        ),
        body: loaded
            ? task == null
                ? Center(
                    child: Text(AppLocalizations.of(context)!.task_not_found))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        if (task?.targetValue == 1 && task?.repeat == null) ...[
                          Column(
                              children: taskStatusesByDate.keys.map((date) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DateFormat.yMMMMEEEEd().format(date),
                                    style:
                                        Theme.of(context).textTheme.titleSmall),
                                ...taskStatusesByDate[date]!.map((status) =>
                                    TaskStatusEventItem(
                                        status: status, task: task!))
                              ],
                            );
                          }).toList())
                        ] else if (task?.repeat?.repeatType ==
                                RepeatType.daily &&
                            task?.targetValue == 1) ...[
                          GridView.count(
                            crossAxisCount: 7,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            children: List.generate(
                              max(
                                  0,
                                  (task!.datetime!
                                                  .difference(DateTime.now())
                                                  .inDays *
                                              -1 +
                                          2) ~/
                                      (task?.repeat?.repeatInterval ?? 1)),
                              (index) {
                                DateTime date = task!.datetime!
                                    .copyWith(
                                        hour: 0,
                                        minute: 0,
                                        second: 0,
                                        millisecond: 0,
                                        microsecond: 0)
                                    .add(Duration(
                                        days: index *
                                                (task?.repeat?.repeatInterval ??
                                                    1) +
                                            1));
                                bool done = false;

                                if (taskStatusesByDate.containsKey(date)) {
                                  done =
                                      taskStatusesByDate[date]?.last.value == 1;
                                }
                                return Container(
                                  color: done
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                  margin: EdgeInsets.all(8),
                                  alignment: Alignment.center,
                                  child: Text(
                                      '${taskStatusesByDate[date]?.last.value}', //Text(DateFormat.Md().format(date),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                              color: done
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer)),
                                  // child: Icon(
                                  //   done
                                  //       ? MdiIcons.checkboxMarkedCircleOutline
                                  //       : MdiIcons.circleOutline,
                                  // ),
                                );
                              },
                            ),
                          )
                        ]
                      ],
                    ),
                  )
            : Center(child: CircularProgressIndicator()));
  }
}

class TaskStatusEventItem extends StatelessWidget {
  final TaskStatus status;
  final Task task;
  const TaskStatusEventItem(
      {super.key, required this.status, required this.task});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(DateFormat.jm().format(status.dt),
                style: Theme.of(context).textTheme.bodyLarge),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(status.value == task.targetValue
                  ? MdiIcons.checkboxMarkedCircleOutline
                  : MdiIcons.circleOutline),
            ),
            Text(status.value == task.targetValue
                ? AppLocalizations.of(context).marked_as_done
                : AppLocalizations.of(context).marked_as_not_done)
          ],
        ));
  }
}

class TaskStatusItem extends StatelessWidget {
  final TaskStatus status;
  final Task task;
  const TaskStatusItem({super.key, required this.status, required this.task});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(DateFormat.jm().format(status.dt),
                style: Theme.of(context).textTheme.bodyLarge),
            InfoChip(
              subtitle: "${status.value} / ${task.targetValue}",
              variant: ChipVariant.secondary,
            ),
          ],
        ));
  }
}
