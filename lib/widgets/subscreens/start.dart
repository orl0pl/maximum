import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/task.dart';
import 'package:maximum/screens/timeline.dart';
import 'package:maximum/widgets/common/task_item.dart';
import 'package:maximum/widgets/start_subscreen/inspiration.dart';
import 'package:maximum/widgets/start_subscreen/top.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartWidget extends StatefulWidget {
  const StartWidget({
    super.key,
    required this.textTheme,
  });

  final TextTheme textTheme;

  @override
  State<StartWidget> createState() => _StartWidgetState();
}

class _StartWidgetState extends State<StartWidget> {
  List<Task> allTasks = [];
  Map<int, int> taskRanks = {};
  int? rankTune1;
  int? rankTune2;
  bool? showDebugScores;

  @override
  void initState() {
    super.initState();
    fetchPrefs();
    fetchTasks();
  }

  void fetchPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? rankTune1Memory = prefs.getInt('rankTune1');
    int? rankTune2Memory = prefs.getInt('rankTune2');
    bool? showDebugScoresMemory = prefs.getBool('showDebugScores');
    if (showDebugScoresMemory == null) {
      prefs.setBool('showDebugScores', false);
    }

    if (rankTune1Memory == null) {
      prefs.setInt('rankTune1', defaultRankTune1);
    }
    if (rankTune2Memory == null) {
      prefs.setInt('rankTune2', defaultRankTune2);
    }

    showDebugScores = showDebugScoresMemory ?? false;
    rankTune1 = rankTune1Memory ?? defaultRankTune1;
    rankTune2 = rankTune2Memory ?? defaultRankTune2;
  }

  void fetchTasks() {
    DatabaseHelper().tasks.then((tasks) async {
      List<Task> filteredTasks = (await Future.wait(tasks.map((task) async {
        bool completed = (await task.completed); // && (task.showInStart);
        return completed ? null : task;
      })))
          .where((task) => task != null)
          .toList()
          .cast<Task>();

      for (var task in filteredTasks) {
        taskRanks[task.taskId!] = task.getRankScore(
          false,
          rankTune1 ?? defaultRankTune1,
          rankTune2 ?? defaultRankTune2,
        );
      }

      filteredTasks.sort(
          (a, b) => (taskRanks[b.taskId] ?? 0) - (taskRanks[a.taskId] ?? 0));
      if (mounted) {
        setState(() {
          allTasks = filteredTasks;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Top(),
            const SizedBox(height: 32),
            Expanded(
              flex: 12,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const TimelineScreen(),
                      maintainState: false));
                },
                onDoubleTap: () {
                  fetchTasks();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.timeline,
                      style: widget.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    // TODO: Import events from calendar
                    // ImportantEvent(textTheme: widget.textTheme),
                    // const SizedBox(height: 16),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int? tasksThatFit;
                          try {
                            if (kDebugMode) {
                              print(
                                  "${constraints.maxHeight} ${constraints.minHeight}");
                            }
                            tasksThatFit =
                                ((constraints.maxHeight - 24) / 64).floor();
                          } on UnsupportedError catch (e) {
                            if (kDebugMode) {
                              print(e);
                            }
                            tasksThatFit = 6;
                          }
                          return allTasks.isEmpty
                              ? Center(
                                  child: Text(
                                    l.no_tasks,
                                    style: widget.textTheme.bodySmall,
                                  ),
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...allTasks
                                        .take(
                                            tasksThatFit < 0 ? 0 : tasksThatFit)
                                        .map((Task task) {
                                      return TaskItem(
                                        task: task,
                                        textUnderTaskText:
                                            "Score: ${taskRanks[task.taskId]?.toString()}",
                                        refresh: () {
                                          fetchTasks();
                                        },
                                      );
                                    }),
                                    if (allTasks.length > tasksThatFit) ...[
                                      Icon(MdiIcons.chevronDown,
                                          color: widget
                                              .textTheme.bodySmall!.color),
                                    ]
                                  ],
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            const Inspiration()
          ],
        ),
      ),
    );
  }
}
