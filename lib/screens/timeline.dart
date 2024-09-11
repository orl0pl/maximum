import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maximum/database/database_helper.dart';
import 'package:maximum/main.dart';
import 'package:maximum/models/note.dart';
import 'package:intl/intl.dart';
import 'package:maximum/models/task.dart';
import 'package:maximum/screens/add.dart';
import 'package:maximum/utils/location.dart';
import 'package:maximum/utils/relative_date.dart';
import 'package:maximum/widgets/task_item.dart';
import 'package:sqflite/sqflite.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({Key? key}) : super(key: key);
  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  bool archiveMode = false;
  late DatabaseHelper _databaseHelper;
  List<Task> _tasks = [];
  List<Task> get dueTasks =>
      _tasks.where((task) => task.isDue && !task.isToday).toList();
  List<Task> get todayTasksBeforeNow => _tasks
      .where((task) =>
          task.isToday &&
          DateTime.now().isBefore(
              task.datetime ?? DateTime.fromMillisecondsSinceEpoch(0)))
      .toList();

  List<Task> get todayTasksAfterNow => _tasks
      .where((task) =>
          task.isToday &&
          DateTime.now()
              .isAfter(task.datetime ?? DateTime.fromMillisecondsSinceEpoch(0)))
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
  }

  void fetchTasks() async {
    List<Task> tasks = await _databaseHelper.tasks;
    tasks.sort((a, b) => a.datetime!.compareTo(b.datetime!));
    if (!archiveMode) {
      tasks = tasks.where((task) => task.completed == 0).toList();
    }
    setState(() {
      _tasks = tasks;
    });
  }

  void refresh() {
    fetchTasks();
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
            icon: Icon(archiveMode ? Icons.archive : Icons.archive_outlined),
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
        child: SingleChildScrollView(
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
                if (todayTasksBeforeNow.isNotEmpty) ...[
                  Text(l.today, style: textTheme.labelLarge),
                  for (Task task in todayTasksBeforeNow)
                    TaskItem(task: task, refresh: refresh, clickable: true),
                ],
                NowText(theme: theme, l: l, textTheme: textTheme),
                for (Task task in todayTasksAfterNow)
                  TaskItem(task: task, refresh: refresh, clickable: true),
                if (tomorrowTasks.isNotEmpty) ...[
                  Text(l.tommorow, style: textTheme.labelLarge),
                  for (Task task in tomorrowTasks)
                    TaskItem(task: task, refresh: refresh),
                ],
                if (taskInNextSevenDays.isNotEmpty) ...[
                  Text(l.this_week, style: textTheme.labelLarge),
                  for (Task task in taskInNextSevenDays)
                    TaskItem(task: task, refresh: refresh, clickable: true),
                ],
                if (futureTasks.isNotEmpty) ...[
                  Text(l.in_future, style: textTheme.labelLarge),
                  for (Task task in futureTasks)
                    TaskItem(task: task, refresh: refresh, clickable: true),
                ]
              ],
            ),
          ),
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
    return Container(
      height: 20,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
        color: theme.colorScheme.primary,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
        child: Text(l.now,
            style: textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onPrimary)),
      ),
    );
  }
}
