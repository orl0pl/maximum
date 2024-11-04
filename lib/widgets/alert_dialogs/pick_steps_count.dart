import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:maximum/data/models/task.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PickTargetValueDialog extends StatefulWidget {
  final Task taskDraft;
  const PickTargetValueDialog({super.key, required this.taskDraft});
  @override
  PickTargetValueDialogState createState() => PickTargetValueDialogState();
}

class PickTargetValueDialogState extends State<PickTargetValueDialog> {
  int? _targetValue;
  @override
  void initState() {
    super.initState();
    _targetValue = widget.taskDraft.targetValue;
  }

  get canSubmit {
    if (_targetValue == null) return false;
    if (_targetValue == 1) return true;
    if (_targetValue! > 1) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    return AlertDialog(
      icon: const Icon(MdiIcons.counter),
      title: Text(l.pick_steps_count),
      content: TextFormField(
        initialValue: _targetValue.toString(),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          if (mounted) {
            setState(() {
              _targetValue = int.tryParse(value);
            });
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: canSubmit
              ? () {
                  Navigator.of(context).pop(_targetValue);
                }
              : null,
          child: Text(l.save),
        ),
      ],
    );
  }
}
