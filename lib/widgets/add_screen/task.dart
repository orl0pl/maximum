import 'package:flutter/material.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:maximum/data/models/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/note.dart';
import 'package:intl/intl.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/data/models/repeat_data.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:maximum/data/models/task.dart';
import 'package:maximum/screens/add_place.dart';
import 'package:maximum/utils/location.dart';
import 'package:maximum/utils/relative_date.dart';
import 'package:maximum/widgets/alert_dialogs/pick_repeat.dart';
import 'package:maximum/widgets/alert_dialogs/pick_steps_count.dart';
import 'package:maximum/widgets/alert_dialogs/tag_edit.dart';
import 'package:maximum/widgets/common/tag_label.dart';

class TaskAdding extends StatefulWidget {
  final void Function(Task) updateDataForTask;
  final void Function(Set<int>) updateTagsForTask;
  final void Function(int?) updatePlaceForTask;

  final List<Tag> tags;

  final List<Place> places;

  final Set<int> selectedTagsIds;

  final int? selectedPlaceId;
  const TaskAdding(
      {super.key,
      required this.updateDataForTask,
      required this.updateTagsForTask,
      required this.updatePlaceForTask,
      required this.selectedTagsIds,
      this.selectedPlaceId,
      required this.tags,
      required this.places});

  @override
  State<TaskAdding> createState() => _TaskAddingState();
}

class _TaskAddingState extends State<TaskAdding> {
  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.place,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (Place place in widget.places)
                InputChip(
                  label: Text(place.name),
                  selected: widget.selectedPlaceId == place.placeId,
                  onSelected: (value) {
                    var newId = widget.selectedPlaceId;
                    if (value) {
                      newId = place.placeId;
                    } else {
                      newId = null;
                    }
                    widget.updatePlaceForTask(newId);
                  },
                  // onDeleted: () {},
                ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(MdiIcons.mapMarkerPlusOutline),
                  label: Text(l.manage_places))
            ],
          ),
        ),
        Text(
          l.tags,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (Tag tag in widget.tags)
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
                  onPressed: () {},
                  icon: Icon(Icons.edit),
                  label: Text(l.manage_task_tags))
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          l.time,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Row(
          children: [
            InputChip(
              avatar: Icon(MdiIcons.calendarMonth),
              label: Text("21/12/2022"),
              onDeleted: () {},
            ),
            const SizedBox(width: 8),
            InputChip(
              avatar: Icon(MdiIcons.clock),
              label: Text("12:00"),
              onDeleted: () {},
            ),
            const SizedBox(width: 8),
            InputChip(
              avatar: Icon(MdiIcons.mapMarker),
              label: Text("Home"),
              onDeleted: () {},
            ),
          ],
        ),
        Row(
          children: [
            IconButton(onPressed: () {}, icon: Icon(Icons.calendar_month)),
            IconButton(onPressed: () {}, icon: Icon(MdiIcons.clockOutline)),
            IconButton(onPressed: () {}, icon: Icon(MdiIcons.mapMarkerOutline)),
            IconButton(onPressed: () {}, icon: Icon(MdiIcons.counter)),
            IconButton(
                onPressed: () {}, icon: Icon(MdiIcons.tagMultipleOutline)),
          ],
        ),
      ],
    );
  }
}
