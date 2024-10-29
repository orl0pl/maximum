import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:maximum/data/models/task.dart';
import 'package:maximum/screens/add.dart';
import 'package:maximum/utils/enums.dart';
import 'package:maximum/widgets/common/tag_label.dart';
import 'package:maximum/widgets/common/task_item.dart';

enum TimeLineListViewEntryType { task, label, nowIndicator }

class TimelineListViewEntry {
  final int? taskIndex;
  final String? label;
  final TimeLineListViewEntryType type;

  TimelineListViewEntry(this.type, {this.taskIndex, this.label});
}

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});
  @override
  TimelineScreenState createState() => TimelineScreenState();
}

class TimelineScreenState extends State<TimelineScreen> {
  bool tasksLoaded = false;
  bool archiveMode = false;
  late DatabaseHelper _databaseHelper;
  List<Task> _tasks = [];
  List<Tag> _tags = [];
  List<Place> _places = [];
  Set<int> selectedTagsIds = {};
  Set<int> selectedPlacesIds = {};
  List<TimelineListViewEntry> listViewEntries = [];
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
    fetchPlaces();
  }

  void fetchTasks() async {
    setState(() {
      tasksLoaded = false;
    });
    List<Task> tasks =
        await _databaseHelper.getTasksByTags(selectedTagsIds.toList());
    tasks.sort((a, b) =>
        a.isDateSet && b.isDateSet ? a.datetime!.compareTo(b.datetime!) : 0);
    tasks = tasks
        .where(
          (task) =>
              selectedPlacesIds.isEmpty ||
              selectedPlacesIds.contains(task.placeId),
        )
        .toList();

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
      tasksLoaded = true;
    });

    fetchListViewEntries();
  }

  void fetchTags() async {
    List<Tag> tags = await _databaseHelper.taskTags;
    setState(() {
      _tags = tags;
    });
  }

  void fetchPlaces() async {
    List<Place> places = await _databaseHelper.getPlaces();
    setState(() {
      _places = places;
    });
  }

  void refresh() {
    fetchTasks();
    fetchListViewEntries();
  }

  void fetchListViewEntries() {
    List<TimelineListViewEntry> tempListViewEntries = [];

    if (dueTasks.isNotEmpty) {
      tempListViewEntries.add(TimelineListViewEntry(
          TimeLineListViewEntryType.label,
          label: AppLocalizations.of(context).due_tasks));
      tempListViewEntries.addAll(dueTasks.map((task) => TimelineListViewEntry(
          TimeLineListViewEntryType.task,
          taskIndex: _tasks.indexOf(task))));
    }

    if (todayTasksBeforeNow.isNotEmpty) {
      tempListViewEntries.add(TimelineListViewEntry(
          TimeLineListViewEntryType.label,
          label: AppLocalizations.of(context).today));
      tempListViewEntries.addAll(todayTasksBeforeNow.map((task) =>
          TimelineListViewEntry(TimeLineListViewEntryType.task,
              taskIndex: _tasks.indexOf(task))));
    }

    tempListViewEntries
        .add(TimelineListViewEntry(TimeLineListViewEntryType.nowIndicator));

    if (todayTasksAfterNow.isNotEmpty) {
      tempListViewEntries.add(TimelineListViewEntry(
          TimeLineListViewEntryType.label,
          label: AppLocalizations.of(context).tomorrow));
      tempListViewEntries.addAll(todayTasksAfterNow.map((task) =>
          TimelineListViewEntry(TimeLineListViewEntryType.task,
              taskIndex: _tasks.indexOf(task))));
    }

    if (tomorrowTasks.isNotEmpty) {
      tempListViewEntries.add(TimelineListViewEntry(
          TimeLineListViewEntryType.label,
          label: AppLocalizations.of(context).tomorrow));
      tempListViewEntries.addAll(tomorrowTasks.map((task) =>
          TimelineListViewEntry(TimeLineListViewEntryType.task,
              taskIndex: _tasks.indexOf(task))));
    }

    if (taskInNextSevenDays.isNotEmpty) {
      tempListViewEntries.add(TimelineListViewEntry(
          TimeLineListViewEntryType.label,
          label: AppLocalizations.of(context).this_week));
      tempListViewEntries.addAll(taskInNextSevenDays.map((task) =>
          TimelineListViewEntry(TimeLineListViewEntryType.task,
              taskIndex: _tasks.indexOf(task))));
    }

    if (futureTasks.isNotEmpty) {
      tempListViewEntries.add(TimelineListViewEntry(
          TimeLineListViewEntryType.label,
          label: AppLocalizations.of(context).in_future));
      tempListViewEntries.addAll(futureTasks.map((task) =>
          TimelineListViewEntry(TimeLineListViewEntryType.task,
              taskIndex: _tasks.indexOf(task))));
    }

    setState(() {
      listViewEntries = tempListViewEntries;
    });
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
    AppLocalizations l = AppLocalizations.of(context);
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.timeline),
        actions: [
          IconButton(
            icon: Icon(archiveMode
                ? MdiIcons.checkboxMarkedOutline
                : MdiIcons.checkboxBlankOutline),
            isSelected: archiveMode,
            onPressed: () {
              setState(() {
                archiveMode = !archiveMode;
              });
              refresh();
            },
          ),
          IconButton(
            icon: const Icon(MdiIcons.refresh),
            onPressed: refresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const AddScreen(
                    returnToHome: false,
                    entryType: EntryType.task,
                  )));
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: IntrinsicHeight(
                    child: Row(children: [
                      ..._tags.map((tag) => Row(
                            children: [
                              (FilterChip(
                                  label: TagLabel(tag: tag),
                                  onSelected: (value) {
                                    setState(() {
                                      if (value) {
                                        selectedTagsIds.add(tag.tagId ?? -1);
                                      } else {
                                        selectedTagsIds.remove(tag.tagId ?? -1);
                                      }
                                    });
                                    refresh();
                                  },
                                  selected:
                                      selectedTagsIds.contains(tag.tagId))),
                              const SizedBox(width: 8),
                            ],
                          )),
                      const VerticalDivider(),
                      const SizedBox(width: 8),
                      ..._places.map((place) => Row(
                            children: [
                              (FilterChip(
                                  label: Text(place.name),
                                  onSelected: (value) {
                                    setState(() {
                                      if (value) {
                                        selectedPlacesIds
                                            .add(place.placeId ?? -1);
                                      } else {
                                        selectedPlacesIds
                                            .remove(place.placeId ?? -1);
                                      }
                                    });
                                    refresh();
                                  },
                                  selected: selectedPlacesIds
                                      .contains(place.placeId))),
                              const SizedBox(width: 8),
                            ],
                          )),
                    ]),
                  )),
            ),
            Expanded(
              child: tasksLoaded
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: listViewEntries.length,
                      itemBuilder: (context, index) {
                        var item = listViewEntries[index];

                        if (item.type == TimeLineListViewEntryType.label) {
                          return Text(
                              item.label != null ? item.label! : "Report issue",
                              style: textTheme.labelLarge);
                        }
                        if (item.type ==
                            TimeLineListViewEntryType.nowIndicator) {
                          return NowText(
                              theme: theme, l: l, textTheme: textTheme);
                        }
                        if (item.type == TimeLineListViewEntryType.task) {
                          return item.taskIndex != null
                              ? commonTaskItem(_tasks[item.taskIndex!])
                              : const Text("Null index (report issue)");
                        }
                        return const SizedBox();
                      },
                    )
                  : const Center(child: CircularProgressIndicator()),
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: theme.colorScheme.tertiary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            child: Text(l.now,
                style: textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onTertiary)),
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
