import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/data/models/repeat_data.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:maximum/data/models/task.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:maximum/screens/settings/manage_places.dart';
import 'package:maximum/screens/settings/manage_tags.dart';
import 'package:maximum/utils/attachments.dart';
import 'package:maximum/utils/enums.dart';
import 'package:maximum/utils/relative_date.dart';
import 'package:maximum/widgets/alert_dialogs/pick_attachment.dart';
import 'package:maximum/widgets/alert_dialogs/pick_repeat.dart';
import 'package:maximum/widgets/alert_dialogs/pick_steps_count.dart';
import 'package:maximum/widgets/common/tag_label.dart';

class TaskAdding extends StatefulWidget {
  final void Function(Task) updateDataForTask;
  final void Function(Set<int>) updateTagsForTask;

  final List<Tag>? tags;

  final List<Place> places;

  final Set<int> selectedTagsIds;

  final List<String> attachments;

  final void Function(List<String>) updateAttachments;

  final bool attachmentsCanOpen;

  const TaskAdding(
      {super.key,
      required this.updateDataForTask,
      required this.updateTagsForTask,
      required this.updateAttachments,
      required this.selectedTagsIds,
      required this.tags,
      required this.places,
      required this.taskDraft,
      this.attachmentsCanOpen = false,
      required this.attachments});

  final Task taskDraft;

  @override
  State<TaskAdding> createState() => _TaskAddingState();
}

class _TaskAddingState extends State<TaskAdding> {
  Future<bool> addAttachment() async {
    var result = await showDialog(
        context: context, builder: (context) => PickAttachmentDialog());

    if (result != null) {
      var tempAttachments = widget.attachments;
      tempAttachments.add(result);
      widget.updateAttachments(tempAttachments);
    }

    return result != null;
  }

  Future<void> removeAttachment(int index) async {
    var tempAttachments = widget.attachments;
    tempAttachments.removeAt(index);
    widget.updateAttachments(tempAttachments);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmalllabelWithIcon(l: l, icon: MdiIcons.mapMarker, label: l.place),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (Place place in widget.places)
                InputChip(
                  label: Text(place.name),
                  selected: widget.taskDraft.placeId == place.placeId,
                  onSelected: (value) {
                    var newId = widget.taskDraft.placeId;
                    if (value) {
                      newId = place.placeId;
                    } else {
                      newId = null;
                    }
                    widget.taskDraft.placeId = newId;
                  },
                  // onDeleted: () {},
                ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ManagePlacesScreen();
                    }));
                  },
                  icon: const Icon(MdiIcons.mapMarkerPlusOutline),
                  label: Text(l.manage_places))
            ],
          ),
        ),
        SmalllabelWithIcon(l: l, icon: MdiIcons.tagMultiple, label: l.tags),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (widget.tags == null)
                Text(l.loading)
              else
                for (Tag tag in widget.tags!)
                  InputChip(
                    label: TagLabel(tag: tag),
                    selected: widget.selectedTagsIds.contains(tag.tagId),
                    onSelected: (value) {
                      var newSet = widget.selectedTagsIds;
                      if (value) {
                        newSet.add(tag.tagId!);
                      } else {
                        newSet.remove(tag.tagId);
                      }
                      widget.updateTagsForTask(newSet);
                    },
                    // onDeleted: () {},
                  ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ManageTagsScreen(
                        typeOfTags: EntryType.task,
                      );
                    }));
                  },
                  icon: const Icon(Icons.edit),
                  label: Text(l.manage_task_tags))
            ],
          ),
        ),
        SmalllabelWithIcon(l: l, icon: MdiIcons.calendarMonth, label: l.time),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                avatar: !widget.taskDraft.isDateSet
                    ? const Icon(Icons.calendar_month)
                    : null,
                label: widget.taskDraft.isDateSet
                    ? Text(formatDate(widget.taskDraft.datetime!, l))
                    : Text(l.pick_date),
                selected: widget.taskDraft.isDateSet,
                onSelected: (bool value) async {
                  if (value) {
                    final selectedDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1970),
                      lastDate: DateTime(2100),
                      initialDate: widget.taskDraft.datetime ?? DateTime.now(),
                    );
                    if (selectedDate != null && mounted) {
                      setState(() {
                        widget.taskDraft.date =
                            DateFormat('yyyyMMdd').format(selectedDate);
                      });
                    }
                  } else if (mounted) {
                    setState(() {
                      widget.taskDraft.date = '';
                      widget.taskDraft.time = null;
                    });
                  }
                  widget.updateDataForTask(widget.taskDraft);
                },
              ),
              const SizedBox(width: 8),
              if (widget.taskDraft.isDateSet) ...[
                FilterChip(
                  label: widget.taskDraft.time != null
                      ? Text(DateFormat.Hm()
                          .format(widget.taskDraft.datetime ?? DateTime.now()))
                      : Text(l.pick_time),
                  selected: widget.taskDraft.isTimeSet,
                  onSelected: (bool value) async {
                    if (value) {
                      final selectedTime = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (selectedTime != null && mounted) {
                        setState(() {
                          widget.taskDraft.time = DateFormat("HHmm").format(
                              DateTime(2000, 1, 1, selectedTime.hour,
                                  selectedTime.minute));
                        });
                      }
                    } else {
                      if (mounted) {
                        setState(() {
                          widget.taskDraft.time = null;
                        });
                      }
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
              FilterChip(
                label: widget.taskDraft.datetime != null
                    ? Text(l.deadline)
                    : Text(l.asap),
                selected: widget.taskDraft.isAsap == 1,
                onSelected: (value) {
                  if (mounted) {
                    setState(() {
                      widget.taskDraft.isAsap = value ? 1 : 0;
                    });
                  }
                },
              ),
              if (widget.taskDraft.isDateSet) ...[
                const SizedBox(width: 8),
                InputChip(
                  label: Text(l.repeat),
                  avatar: widget.taskDraft.repeat != null
                      ? const Icon(Icons.repeat)
                      : const Icon(MdiIcons.repeatOff),
                  showCheckmark: false,
                  selected: widget.taskDraft.repeat != null,
                  onSelected: (value) async {
                    if (context.mounted) {
                      Future.delayed(Duration.zero, () async {
                        RepeatData? newRepeat = await showDialog(
                            // ignore: use_build_context_synchronously
                            context: context,
                            builder: (context) =>
                                PickRepeatDialog(taskDraft: widget.taskDraft));
                        widget.taskDraft.replaceRepeat(newRepeat);
                        widget.updateDataForTask(widget.taskDraft);
                      });
                    }
                    // } else {
                    //   widget.taskDraft.replaceRepeat(null);
                    //   widget.updateDataForTask(widget.taskDraft);
                    // }
                  },
                ),
              ]
            ],
          ),
        ),
        SmalllabelWithIcon(l: l, icon: MdiIcons.more, label: l.more),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: widget.taskDraft.targetValue == 1
                    ? Text(l.steps_count)
                    : Text(l.steps(widget.taskDraft.targetValue)),
                avatar: const Icon(MdiIcons.counter),
                showCheckmark: false,
                selected: widget.taskDraft.targetValue != 1,
                onSelected: (value) async {
                  int? newValue = await showDialog(
                      context: context,
                      builder: (context) =>
                          PickTargetValueDialog(taskDraft: widget.taskDraft));
                  if (newValue != null && mounted) {
                    setState(() {
                      widget.taskDraft.targetValue = newValue;
                    });
                    widget.updateDataForTask(widget.taskDraft);
                  }
                },
              ),
              ...widget.attachments.asMap().entries.map((entry) {
                var attachment = entry.value;
                XFile? file;
                if (attachment.startsWith("media:")) {
                  file = XFile(attachment.split(":")[1]);
                }
                var path = attachment.split(":")[1];
                var type = attachment.split(":")[0];
                return Row(children: [
                  SizedBox(width: 8),
                  InputChip(
                    label: Text(type == 'media'
                        ? getLocalizedAttachmentType(path, l)
                        : attachment),
                    avatar: Icon(getAttachmentTypeIconFromPath(path)),
                    showCheckmark: false,
                    onPressed: widget.attachmentsCanOpen
                        ? () async {
                            if (type == 'media' &&
                                    getAttachmentType(path) ==
                                        GeneralAttachmentType.image ||
                                getAttachmentType(path) ==
                                    GeneralAttachmentType.video) {
                              final intent = AndroidIntent(
                                action: 'android.intent.action.VIEW',
                                data: 'file://$path',
                                type: 'image/*',
                                flags: [
                                  Flag.FLAG_ACTIVITY_NEW_TASK,
                                  Flag.FLAG_GRANT_READ_URI_PERMISSION
                                ],
                              );

                              try {
                                await intent.launch();
                              } catch (e) {
                                print("Error launching gallery: $e");
                              }
                            }
                          }
                        : null,
                    onDeleted: () {
                      removeAttachment(entry.key);
                      widget.updateDataForTask(widget.taskDraft);
                    },
                  )
                ]);
              }),
              const SizedBox(width: 8),
              InputChip(
                  label: Text(l.add_attachment),
                  showCheckmark: false,
                  onPressed: addAttachment,
                  avatar: const Icon(MdiIcons.paperclip)),
            ],
          ),
        )
      ],
    );
  }
}

class SmalllabelWithIcon extends StatelessWidget {
  const SmalllabelWithIcon({
    super.key,
    required this.l,
    required this.icon,
    required this.label,
  });

  final AppLocalizations l;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}
