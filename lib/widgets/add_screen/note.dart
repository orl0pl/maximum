import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/data/models/repeat_data.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:maximum/data/models/task.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:maximum/screens/settings/manage_tags.dart';
import 'package:maximum/utils/attachments.dart';
import 'package:maximum/utils/enums.dart';
import 'package:maximum/utils/relative_date.dart';
import 'package:maximum/widgets/alert_dialogs/pick_attachment.dart';
import 'package:maximum/widgets/alert_dialogs/pick_repeat.dart';
import 'package:maximum/widgets/alert_dialogs/pick_steps_count.dart';
import 'package:maximum/widgets/common/tag_label.dart';

class NoteAdding extends StatefulWidget {
  final void Function(Set<int>) updateTagsForNote;

  final void Function(List<String>) updateAttachments;

  final List<String> attachments;

  final List<Tag>? tags;

  final Set<int> selectedTagsIds;

  final dynamic noteDraft;

  const NoteAdding(
      {super.key,
      required this.updateTagsForNote,
      required this.selectedTagsIds,
      required this.tags,
      required this.updateAttachments,
      required this.attachments,
      required this.noteDraft});

  @override
  State<NoteAdding> createState() => _NoteAddingState();
}

class _NoteAddingState extends State<NoteAdding> {
  Future<bool> addAttachment() async {
    var result = await showDialog(
        context: context, builder: (context) => PickAttachmentDialog());

    if (result != null) {
      var tempAttachments = widget.attachments;
      tempAttachments?.add(result);
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
                      widget.updateTagsForNote(newSet);
                    },
                    // onDeleted: () {},
                  ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ManageTagsScreen(
                        typeOfTags: EntryType.note,
                      );
                    }));
                  },
                  icon: const Icon(Icons.edit),
                  label: Text(l.manage_note_tags))
            ],
          ),
        ),
        SmalllabelWithIcon(l: l, icon: MdiIcons.more, label: l.more),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...widget.attachments.asMap().entries.map((entry) {
                var attachment = entry.value;
                XFile? file;
                if (attachment.startsWith("media:")) {
                  file = XFile(attachment.split(":")[1]);
                }
                return Row(children: [
                  SizedBox(width: 8),
                  InputChip(
                    label: Text(attachment.split(':')[0] == 'media'
                        ? getLocalizedAttachmentType(file!.path, l)
                        : attachment),
                    avatar: Icon(getAttachmentTypeIconFromPath(file!.path)),
                    showCheckmark: false,
                    onDeleted: () {
                      removeAttachment(entry.key);
                    },
                  )
                ]);
              }),
              if (widget.attachments.isNotEmpty) const SizedBox(width: 8),
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
