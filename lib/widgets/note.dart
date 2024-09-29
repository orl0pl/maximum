import 'package:flutter/material.dart';
import 'package:maximum/data/models/note.dart';

class NoteWidget extends StatelessWidget {
  const NoteWidget({super.key, required this.note});
  final Note note;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: colorScheme.surfaceContainer),
      child: Column(
        children: [Text(note.text)],
      ),
    );
  }
}
