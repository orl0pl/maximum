import 'package:flutter/material.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddOrEditTagDialog extends StatefulWidget {
  const AddOrEditTagDialog({super.key, this.tag});

  final Tag? tag;

  @override
  AddOrEditTagDialogState createState() => AddOrEditTagDialogState();
}

class AddOrEditTagDialogState extends State<AddOrEditTagDialog> {
  String _name = "";
  int _hue = 0;

  @override
  void initState() {
    super.initState();
    if (widget.tag != null) {
      _name = widget.tag!.name;
      _hue = int.tryParse(widget.tag!.color) ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    ThemeData theme = Theme.of(context).copyWith();
    TextTheme textTheme = theme.textTheme;
    return AlertDialog(
      title: Text(widget.tag == null ? l.add_tag : l.edit_tag),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(labelText: l.tag_name),
            onChanged: (value) => _name = value,
            controller: TextEditingController(text: _name),
          ),
          const SizedBox(height: 16),
          Text(l.color, style: textTheme.labelSmall),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
                activeTrackColor: theme.colorScheme.primary,
                inactiveTrackColor: theme.colorScheme.primaryContainer,
                trackShape: CustomTrackShape()),
            child: Slider(
                value: _hue.toDouble(),
                min: 0,
                max: 360,
                inactiveColor:
                    HSLColor.fromAHSL(1, _hue.toDouble(), 0.5, 0.3).toColor(),
                activeColor:
                    HSLColor.fromAHSL(1, _hue.toDouble(), 1, 0.5).toColor(),
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      _hue = value.toInt();
                    });
                  }
                }),
          )
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context, null);
            },
            child: Text(l.cancel)),
        TextButton(
            onPressed: () {
              if (widget.tag == null) {
                Navigator.pop(
                    context, Tag(name: _name, color: _hue.toString()));
              } else {
                Navigator.pop(
                    context,
                    Tag(
                        tagId: widget.tag!.tagId,
                        name: _name,
                        color: _hue.toString()));
              }
            },
            child: Text(l.save))
      ],
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double? trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
