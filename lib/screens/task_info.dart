import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:intl/intl.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:maximum/data/models/task.dart';
import 'package:maximum/data/models/task_status.dart';
import 'package:maximum/screens/edit_task.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maximum/widgets/add_screen/task.dart';
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
  errorNotFound,
  errorUnknown,
}

class _TaskInfoScreenState extends State<TaskInfoScreen> {
  ScrollController descriptionFieldScrollController = ScrollController();
  FocusNode descriptionFieldFocusNode = FocusNode();
  bool descriptionExpanded = false;
  String text = "";
  String description = "";
  Task? task;
  Place? taskPlace;
  List<String>? attachments;
  List<Place>? places;
  List<Tag>? tags;
  Set<int>? selectedTagsIds;
  List<TaskStatus>? statuses;
  TaskInfoScreenLoadingState _state = TaskInfoScreenLoadingState.loading;
  final DatabaseHelper _dh = DatabaseHelper();
  @override
  void initState() {
    super.initState();
    _dh.getTask(widget.taskId).then((value) {
      if (mounted) {
        setState(() {
          if (value != null) {
            task = value;
            description = value.text.split("\n").length > 1
                ? value.text.split("\n")[1]
                : "";
            text = value.text.split("\n")[0];
            _state = TaskInfoScreenLoadingState.loaded;
          } else {
            _state = TaskInfoScreenLoadingState.errorNotFound;
          }
        });
      }
    });

    _dh.getPlaces().then((value) {
      if (mounted) {
        setState(() {
          places = value;
        });
      }
    });

    _dh.getTaskStatuses(widget.taskId).then((value) {
      if (mounted) {
        setState(() {
          statuses = value;
        });
      }
    });

    _dh.taskTags.then((value) {
      if (mounted) {
        setState(() {
          tags = value;
        });
      }
    });

    _dh.getTagsForTask(widget.taskId).then((value) {
      if (mounted) {
        setState(() {
          selectedTagsIds = Set.from(value.map(
            (e) => e.tagId,
          ));
        });
      }
    });

    _dh.getTaskAttachments(widget.taskId).then((value) {
      if (mounted) {
        setState(() {
          attachments = value;
        });
      }
    });
  }

  bool get loading {
    return selectedTagsIds == null ||
        task == null ||
        tags == null ||
        places == null ||
        statuses == null ||
        attachments == null;
  }

  void handleTextChange(String value) {
    if (mounted) {
      setState(() {
        text = value;
      });
    }
  }

  void handleDescriptionChange(String value) {
    if (mounted) {
      setState(() {
        description = value;
      });
    }
  }

  void saveText() {
    if (mounted) {
      setState(() {
        task?.text = '$text\n$description'.trim();
      });
      _dh.updateTask(task!);
    }
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
                onPressed: () {},
                icon: const Icon(Icons.delete_forever_outlined))
          ],
        ),
        persistentFooterButtons: [
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  // TODO
                },
                label: Text(l.progress_title),
                icon: const Icon(Icons.timeline),
              ),
              Spacer(),
              if (task != null)
                FutureBuilder(
                    future: task?.getRecentProgressValue(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && task != null) {
                        if (task!.targetValue == 1 && snapshot.data == 1) {
                          return TextButton(
                              onPressed: () {
                                DatabaseHelper().insertTaskStatus(TaskStatus(
                                    taskId: task!.taskId!,
                                    datetime:
                                        DateTime.now().millisecondsSinceEpoch,
                                    value: 0));
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              child: Text(l.mark_as_not_done));
                        } else if (task!.targetValue == 1 &&
                            snapshot.data == 0) {
                          return FilledButton(
                              onPressed: () {
                                DatabaseHelper().insertTaskStatus(TaskStatus(
                                    taskId: task!.taskId!,
                                    datetime:
                                        DateTime.now().millisecondsSinceEpoch,
                                    value: 1));
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              child: Text(l.mark_as_done));
                        } else if (task!.targetValue > 1) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    DatabaseHelper().insertTaskStatus(
                                        TaskStatus(
                                            taskId: task!.taskId!,
                                            datetime: DateTime.now()
                                                .millisecondsSinceEpoch,
                                            value: snapshot.data! - 1));

                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                  icon: const Icon(Icons.remove)),
                              Text('${snapshot.data} / ${task!.targetValue}'),
                              IconButton(
                                  onPressed: () {
                                    DatabaseHelper().insertTaskStatus(
                                        TaskStatus(
                                            taskId: task!.taskId!,
                                            datetime: DateTime.now()
                                                .millisecondsSinceEpoch,
                                            value: snapshot.data! + 1));
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                  icon: const Icon(Icons.add)),
                            ],
                          );
                        }
                      }
                      return Container();
                    })
            ],
          )
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!descriptionExpanded) const Spacer(),
            Flexible(
              flex: descriptionExpanded ? 1 : 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: descriptionExpanded ? null : 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: text,
                      decoration: InputDecoration(
                        hintText: l.content_to_add,
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        handleTextChange(value);
                      },
                      style: Theme.of(context).textTheme.headlineSmall,
                      maxLines: 1,
                    ),
                    Expanded(
                      child: TextFormField(
                        scrollController: descriptionFieldScrollController,
                        maxLines: null,
                        initialValue: description,
                        focusNode: descriptionFieldFocusNode,
                        expands: true,
                        onTapOutside: (event) {
                          descriptionFieldFocusNode.unfocus();
                        },
                        decoration: InputDecoration(
                          hintText: l.add_details,
                          border: InputBorder.none,
                          suffixIcon: IconButton.filled(
                              icon: Icon(MdiIcons.arrowExpandAll),
                              isSelected: descriptionExpanded,
                              onPressed: () {
                                if (mounted) {
                                  setState(() {
                                    descriptionExpanded = !descriptionExpanded;
                                  });
                                }
                              }),
                        ),
                        onChanged: handleDescriptionChange,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (!loading)
              if (!descriptionExpanded)
                TaskAdding(
                  updateDataForTask: updateDataForTask,
                  updateTagsForTask: updateTagsForTask,
                  updateAttachments: updateAttachments,
                  selectedTagsIds: selectedTagsIds ?? {},
                  tags: tags,
                  places: places ?? [],
                  taskDraft: task!,
                  attachmentsCanOpen: true,
                  attachments: attachments ?? [],
                )
              else
                const SizedBox.shrink()
            else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    } else if (TaskInfoScreenLoadingState.errorNotFound == _state) {
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

  void updateDataForTask(Task updatedTask) {
    _dh.updateTask(updatedTask);
    setState(() {
      task = updatedTask;
    });
  }

  void updateAttachments(List<String> updatedAttachments) {
    _dh.updateTaskAttachments(task!.taskId!, updatedAttachments);
    setState(() {
      attachments = updatedAttachments;
    });
  }

  void updateTagsForTask(Set<int> updatedTags) {
    _dh.updateTaskTags(task!.taskId!, updatedTags);
    setState(() {
      selectedTagsIds = updatedTags;
    });
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
