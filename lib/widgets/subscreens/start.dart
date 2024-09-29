import 'package:flutter/material.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/task.dart';
import 'package:maximum/screens/timeline.dart';
import 'package:maximum/widgets/task_item.dart';
import 'package:maximum/widgets/start_subscreen/top.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  void fetchTasks() {
    DatabaseHelper().tasks.then((tasks) async {
      List<Task> filteredTasks = (await Future.wait(tasks.map((task) async {
        bool completed = (await task.completed) && (task.showInStart);
        return completed ? null : task;
      })))
          .where((task) => task != null)
          .toList()
          .cast<Task>();
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Top(),
          const SizedBox(height: 32),
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const TimelineScreen(),
                  maintainState: false));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l?.timeline ?? '',
                  style: widget.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                // ImportantEvent(textTheme: widget.textTheme),
                // const SizedBox(height: 16),
                Column(
                  children: allTasks.map((Task task) {
                    return TaskItem(
                      task: task,
                      refresh: () {
                        fetchTasks();
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
