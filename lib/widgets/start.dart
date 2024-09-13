import 'package:flutter/material.dart';
import 'package:maximum/database/database_helper.dart';
import 'package:maximum/models/task.dart';
import 'package:maximum/screens/timeline.dart';
import 'package:maximum/widgets/task_item.dart';
import 'package:maximum/widgets/top.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? l = AppLocalizations.of(context);
    DatabaseHelper().tasks.then((tasks) {
      setState(() {
        allTasks = tasks
            .where(
                (task) => task.completed == 0 && (task.isDue || task.isToday))
            .toList();
      });
    });
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
                  builder: (context) => const TimelineScreen()));
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
                        setState(() {});
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
