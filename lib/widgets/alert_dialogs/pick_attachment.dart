import 'dart:io';

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
import 'package:maximum/utils/enums.dart';
import 'package:maximum/utils/relative_date.dart';
import 'package:maximum/widgets/alert_dialogs/pick_repeat.dart';
import 'package:maximum/widgets/alert_dialogs/pick_steps_count.dart';
import 'package:maximum/widgets/common/tag_label.dart';

class PickAttachmentDialog extends StatefulWidget {
  const PickAttachmentDialog({Key? key}) : super(key: key);

  @override
  State<PickAttachmentDialog> createState() => _PickAttachmentDialogState();
}

class _PickAttachmentDialogState extends State<PickAttachmentDialog> {
  String attachment = "";

  get canSave => attachment.isNotEmpty;

  pickAttachment() async {
    XFile? file = await ImagePicker().pickMedia();
    if (file == null) return;

    if (mounted) {
      setState(() => attachment = "media:${file.path}");
    }
  }

  changeAttachment() async {
    XFile? file = await ImagePicker().pickMedia();
    if (file == null) return;

    if (mounted) {
      setState(() => attachment = "media:${file.path}");
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.pick_attachment),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (attachment.isEmpty) Text(l.attachment_not_picked),
          if (attachment.startsWith("media:"))
            Image.file(
              File(attachment.substring("media:".length)),
              width: double.maxFinite,
              fit: BoxFit.cover,
            ),
          if (!canSave)
            FilledButton(
                onPressed: pickAttachment, child: Text(l.pick_attachment))
          else
            TextButton(
                onPressed: changeAttachment, child: Text(l.change_attachment)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: canSave
              ? () {
                  Navigator.of(context).pop(attachment);
                }
              : null,
          child: Text(l.save),
        ),
      ],
    );
  }
}
