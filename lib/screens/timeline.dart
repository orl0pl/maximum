import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:maximum/data/models/task.dart';
import 'package:maximum/screens/add.dart';
import 'package:maximum/widgets/alert_dialogs/tag_edit.dart';
import 'package:maximum/widgets/task_item.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});
  @override
  TimelineScreenState createState() => TimelineScreenState();
}

class TimelineScreenState extends State<TimelineScreen> {
  bool archiveMode = false;
  late DatabaseHelper _databaseHelper;
  List<Task> _tasks = [];
  List<Tag> _tags = [];
  Set<int> selectedTagsIds = {};
  List<Task> get dueTasks =>
      _tasks.where((task) => task.isDue && !task.isToday).toList();
  List<Task> get todayTasksBeforeNow => _tasks
      .where((task) =>
          task.isToday &&
          DateTime.now()
              .isAfter(task.datetime ?? DateTime.fromMillisecondsSinceEpoch(0)))
      .toList();

  List<Task> get todayTasksAfterNow => _tasks
      .where((task) =>
          task.isToday &&
          DateTime.now().isBefore(
              task.datetime ?? DateTime.fromMillisecondsSinceEpoch(0)))
      .toList();

  List<Task> get tomorrowTasks =>
      _tasks.where((task) => task.isTomorrow).toList();

  List<Task> get taskInNextSevenDays => _tasks
      .where((task) =>
          task.isInNextSevenDays &&
          DateTime.now().isBefore(
              task.datetime ?? DateTime.fromMillisecondsSinceEpoch(0)))
      .toList();

  List<Task> get futureTasks =>
      _tasks.where((task) => task.isInFuture).toList();

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    fetchTasks();
    fetchTags();
  }

  void fetchTasks() async {
    List<Task> tasks =
        await _databaseHelper.getTasksByTags(selectedTagsIds.toList());
    tasks.sort((a, b) => a.datetime!.compareTo(b.datetime!));
    if (!archiveMode) {
      tasks = (await Future.wait(tasks.map((task) async {
        bool completed = await task.completed;
        return completed ? null : task;
      })))
          .where((task) => task != null)
          .toList()
          .cast<Task>();
    }

    setState(() {
      _tasks = tasks;
    });
  }

  void fetchTags() async {
    List<Tag> tags = await _databaseHelper.taskTags;
    setState(() {
      _tags = tags;
    });
  }

  void refresh() {
    fetchTasks();
  }

  TaskItem commonTaskItem(Task task) {
    return TaskItem(
      task: task,
      refresh: refresh,
      clickable: true,
      shouldSlide: archiveMode == false,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context)!;
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.timeline),
        actions: [
          IconButton.filledTonal(
            icon: Icon(archiveMode ? Icons.history : Icons.history),
            isSelected: archiveMode,
            onPressed: () {
              setState(() {
                archiveMode = !archiveMode;
                refresh();
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const AddScreen()));
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                    children: _tags
                            .map((tag) => Row(
                                  children: [
                                    InkWell(
                                      onLongPress: () async {
                                        Tag? newTag = await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                AddOrEditTagDialog(tag: tag));
                                        if (newTag != null) {
                                          await _databaseHelper
                                              .updateTaskTag(newTag);
                                          fetchTags();
                                        }
                                      },
                                      child: (FilterChip(
                                          label: Row(
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: HSLColor.fromAHSL(
                                                          1,
                                                          int.tryParse(
                                                                      tag.color)
                                                                  ?.toDouble() ??
                                                              0,
                                                          1,
                                                          0.5)
                                                      .toColor(),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(tag.name)
                                            ],
                                          ),
                                          onSelected: (value) {
                                            setState(() {
                                              if (value) {
                                                selectedTagsIds
                                                    .add(tag.tagId ?? -1);
                                              } else {
                                                selectedTagsIds
                                                    .remove(tag.tagId ?? -1);
                                              }
                                            });
                                            refresh();
                                          },
                                          selected: selectedTagsIds
                                              .contains(tag.tagId))),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ))
                            .toList() +
                        [
                          Row(
                            children: [
                              FilterChip(
                                label: Text(l.add_tag),
                                avatar: const Icon(Icons.add),
                                onSelected: (value) async {
                                  Tag? newTag = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const AddOrEditTagDialog());
                                  if (newTag != null) {
                                    DatabaseHelper().insertTaskTag(newTag);
                                    fetchTags();
                                  }
                                },
                              ),
                            ],
                          )
                        ])),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dueTasks.isNotEmpty) ...[
                      Text(l.due_tasks, style: textTheme.labelLarge),
                      for (Task task in dueTasks)
                        TaskItem(
                          task: task,
                          refresh: refresh,
                          clickable: true,
                        ),
                    ],
                    if (todayTasksAfterNow.isNotEmpty ||
                        todayTasksBeforeNow.isNotEmpty) ...[
                      Text(l.today, style: textTheme.labelLarge),
                    ],
                    if (todayTasksBeforeNow.isNotEmpty) ...[
                      for (Task task in todayTasksBeforeNow)
                        commonTaskItem(task),
                    ],
                    NowText(theme: theme, l: l, textTheme: textTheme),
                    for (Task task in todayTasksAfterNow) commonTaskItem(task),
                    if (tomorrowTasks.isNotEmpty) ...[
                      Text(l.tommorow, style: textTheme.labelLarge),
                      for (Task task in tomorrowTasks) commonTaskItem(task),
                    ],
                    if (taskInNextSevenDays.isNotEmpty) ...[
                      Text(l.this_week, style: textTheme.labelLarge),
                      for (Task task in taskInNextSevenDays)
                        commonTaskItem(task),
                    ],
                    if (futureTasks.isNotEmpty) ...[
                      Text(l.in_future, style: textTheme.labelLarge),
                      for (Task task in futureTasks) commonTaskItem(task),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NowText extends StatelessWidget {
  const NowText({
    super.key,
    required this.theme,
    required this.l,
    required this.textTheme,
  });

  final ThemeData theme;
  final AppLocalizations l;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: theme.colorScheme.tertiary,
            ),
            width: 12,
          ),
          Expanded(
            child: Container(
              height: 2,
              color: theme.colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}