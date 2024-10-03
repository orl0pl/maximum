import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/task.dart';
import 'package:maximum/data/models/task_status.dart';
import 'package:maximum/screens/edit_task.dart';
import 'package:maximum/screens/task_info.dart';
import 'package:maximum/utils/relative_date.dart';
import 'package:maximum/widgets/common/info_chip.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String formatTaskRepeat(Task task, AppLocalizations l) {
  if (task.repeat == null) {
    return "";
  }
  if (task.repeat!.repeatType == RepeatType.daily) {
    return "${l.pick_repeat_dialog_each_text} ${task.repeat!.repeatData} ${l.pick_repeat_dialog_select_daily(task.repeat!.repeatInterval as num)}";
  }
  if (task.repeat!.repeatType == RepeatType.dayOfWeek) {
    String days = task.repeat!.repeatData
        .split("")
        .map((e) => DateFormat.EEEE().dateSymbols.WEEKDAYS[int.parse(e)])
        .join(", ");
    return "${l.pick_repeat_dialog_each_x_days} $days";
  }

  return "";
}

class TaskItem extends StatefulWidget {
  final Task task;

  final Function refresh;

  final bool clickable;

  final bool shouldSlide;

  const TaskItem(
      {super.key,
      required this.task,
      required this.refresh,
      this.clickable = false,
      this.shouldSlide = true});

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> with TickerProviderStateMixin {
  late Animation<Offset> _slideOffset = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.0, 0.0),
  ).animate(AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  ));
  late AnimationController _animationController;
  String getSubtitleText(AppLocalizations l) {
    if (widget.task.repeat != null) {
      return formatTaskRepeat(widget.task, l);
    }
    if (widget.task.isDateSet) {
      return formatTaskDateAndTime(widget.task, l);
    }
    return "";
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slideOffset = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(1, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations l = AppLocalizations.of(context)!;
    return SlideTransition(
      position: _slideOffset,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell(
          onTap: widget.clickable
              ? () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return TaskInfoScreen(taskId: widget.task.taskId ?? -1);
                    },
                  ));
                }
              : null,
          onLongPress: widget.clickable
              ? () async {
                  TaskEditResult? edited =
                      await Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return EditTaskScreen(
                        task: widget.task,
                      );
                    },
                  ));
                  if (edited == TaskEditResult.edited) widget.refresh();
                  if (edited == TaskEditResult.deleted) widget.refresh();
                }
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FutureBuilder(
                    future: widget.task.completed,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Checkbox(
                          value: snapshot.data,
                          onChanged: checkCheckbox,
                        );
                      } else {
                        return const SizedBox(
                          width: 48,
                          height: 48,
                        );
                      }
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.text,
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  InfoChip(
                      subtitle: getSubtitleText(l),
                      variant: widget.task.isDue ||
                              widget.task.asap ||
                              widget.task.deadline
                          ? ChipVariant.primary
                          : widget.task.datetime!.isBefore(
                                  DateTime.now().add(const Duration(days: 7)))
                              ? ChipVariant.secondary
                              : ChipVariant.outline),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkCheckbox(bool? value) async {
    DatabaseHelper dh = DatabaseHelper();
    int currentProgress = await widget.task.getRecentProgressValue();
    if (widget.task.targetValue == 1 && widget.task.taskId != null) {
      dh.insertTaskStatus(TaskStatus(
          taskId: widget.task.taskId!,
          datetime: DateTime.now().millisecondsSinceEpoch,
          value: value == true ? 1 : 0));
    } else if (widget.task.taskId != null) {
      dh.insertTaskStatus(TaskStatus(
          taskId: widget.task.taskId!,
          datetime: DateTime.now().millisecondsSinceEpoch,
          value: currentProgress + (value == true ? 1 : 0)));
    }

    if (value == true) {
      if (currentProgress == widget.task.targetValue - 1 &&
          widget.shouldSlide) {
        _animationController.forward().then((_) {
          widget.refresh();
          _animationController.reset();
        });
      } else {
        _animationController.reset();
        widget.refresh();
      }
    } else {
      _animationController.reset();
      widget.refresh();
    }
  }
}
