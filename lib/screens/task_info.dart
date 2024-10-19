import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:maximum/data/models/task.dart';
import 'package:maximum/data/models/task_status.dart';
import 'package:maximum/screens/edit_task.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maximum/widgets/common/info_chip.dart';
import 'package:maximum/widgets/common/tag_label.dart';

class TaskInfoScreen extends StatefulWidget {
  final int taskId;

  const TaskInfoScreen({super.key, required this.taskId});
  @override
  // ignore: library_private_types_in_public_api
  _TaskInfoScreenState createState() => _TaskInfoScreenState();
}

enum TaskInfoScreenLoadingState {
  loading,
  loaded,
  // ignore: constant_identifier_names
  error_not_found,
  // ignore: constant_identifier_names
  error_unknown,
}

class _TaskInfoScreenState extends State<TaskInfoScreen> {
  Task? task;
  Place? taskPlace;
  List<Tag>? taskTags;
  List<TaskStatus>? statuses;
  TaskInfoScreenLoadingState _state = TaskInfoScreenLoadingState.loading;
  final DatabaseHelper _dh = DatabaseHelper();
  @override
  void initState() {
    super.initState();
    _dh
        .getTask(widget.taskId)
        .then((value) => setState(() {
              if (value != null) {
                task = value;
                _state = TaskInfoScreenLoadingState.loaded;
              } else {
                _state = TaskInfoScreenLoadingState.error_not_found;
              }
            }))
        .then((_) {
      _dh.getPlace(task?.placeId ?? -1).then((value) => setState(() {
            if (value != null) {
              taskPlace = value;
            }
          }));

      _dh.getTaskStatuses(widget.taskId).then((value) => setState(() {
            statuses = value;
          }));

      _dh.getTagsForTask(widget.taskId).then((value) => setState(() {
            taskTags = value;
          }));
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    TextTheme textTheme = Theme.of(context).textTheme;
    Map<String, List<TaskStatus>> daysForStatuses = {};
    statuses?.forEach((status) {
      String date = DateFormat.yMMMMEEEEd().format(status.dt);
      if (!daysForStatuses.containsKey(date)) {
        daysForStatuses[date] = [];
      }
      daysForStatuses[date]?.add(status);
    });
    if (TaskInfoScreenLoadingState.loaded == _state && task != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l.task_details),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditTaskScreen(
                                task: task!,
                              )));
                },
                icon: const Icon(Icons.edit))
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task!.text, style: textTheme.headlineLarge),
                  const SizedBox(height: 16),
                  Text(l.tags, style: textTheme.labelMedium),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (taskTags == null)
                          Text(l.loading)
                        else if (taskTags!.isEmpty)
                          Text(l.no_tags)
                        else
                          for (Tag tag in taskTags!) ...[TagLabel(tag: tag)],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (task!.isDateSet) ...[
                    Text(
                      task?.repeat == null
                          ? task!.deadline
                              ? l.deadline
                              : l.date
                          : l.repeat_start_date,
                      style: textTheme.labelMedium,
                    ),
                    Text(DateFormat.yMMMMEEEEd().format(task!.datetime!),
                        style: textTheme.bodyLarge),
                  ],
                  if (task!.isTimeSet) ...[
                    const SizedBox(height: 16),
                    Text(l.hour, style: textTheme.labelMedium),
                    Text(DateFormat.jm().format(task!.datetime!),
                        style: textTheme.bodyLarge),
                  ],
                  if (task!.placeId != null) ...[
                    const SizedBox(height: 16),
                    Text(l.place_name, style: textTheme.labelMedium),
                    Text(taskPlace?.name ?? "Loading...",
                        style: textTheme.bodyLarge),
                  ],
                  const Divider(),
                  Text(
                    l.progress_title,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (statuses == null) const CircularProgressIndicator(),
                  if (statuses != null) ...[
                    ...daysForStatuses.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: textTheme.labelLarge,
                          ),
                          ...entry.value.map((status) {
                            return TaskStatusItem(
                              status: status,
                              task: task!,
                            );
                          }),
                        ],
                      );
                    })
                  ]
                ],
              )),
        ),
      );
    } else if (TaskInfoScreenLoadingState.error_not_found == _state) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l.task_not_found),
        ),
        body: const SingleChildScrollView(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(l.loading),
        ),
        body: const SingleChildScrollView(),
      );
    }
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
