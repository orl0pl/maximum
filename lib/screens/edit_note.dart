import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:maximum/data/models/note.dart';
import 'package:maximum/widgets/alert_dialogs/tag_edit.dart';
import 'package:maximum/widgets/tag_label.dart';

enum NoteEditResult { edited, deleted }

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({super.key, required this.note});

  final Note note;

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late Note noteDraft = widget.note;

  List<Tag> _noteTags = [];
  Set<int> selectedNoteTagsIds = {};
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    fetchTags();
    _databaseHelper.getTagsForNote(noteDraft.noteId ?? -1).then((value) {
      setState(() {
        selectedNoteTagsIds = value.map((tag) => tag.tagId!).toSet();
      });
    });
  }

  void fetchTags() async {
    List<Tag> tags = await _databaseHelper.noteTags;
    setState(() {
      _noteTags = tags;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.edit_note), actions: [
        IconButton(
          icon: const Icon(Icons.delete_forever_outlined),
          onPressed: () async {
            bool succes = await DatabaseHelper().deleteNote(noteDraft.noteId!);
            if (succes && context.mounted) {
              Navigator.of(context).pop(NoteEditResult.deleted);
            }
          },
        )
      ]),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextFormField(
            autofocus: true,
            initialValue: noteDraft.text,
            onChanged: (value) {
              setState(() {
                noteDraft.text = value.trim();
              });
            },
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l.content_to_add),
          ),
          const Spacer(),
          Text(noteDraft.toMap().toString()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: _noteTags
                            .map((tag) => Row(
                                  children: [
                                    InkWell(
                                      onLongPress: () async {
                                        Tag? newTag = await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                AddOrEditTagDialog(tag: tag));
                                        if (newTag != null) {
                                          await _databaseHelper
                                              .updateNoteTag(newTag);
                                          fetchTags();
                                        }
                                      },
                                      child: (FilterChip(
                                          label: TagLabel(tag: tag),
                                          onSelected: (value) {
                                            setState(() {
                                              if (value) {
                                                selectedNoteTagsIds
                                                    .add(tag.tagId ?? -1);
                                              } else {
                                                selectedNoteTagsIds
                                                    .remove(tag.tagId ?? -1);
                                              }
                                            });
                                          },
                                          selected: selectedNoteTagsIds
                                              .contains(tag.tagId))),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ))
                            .toList() +
                        [
                          Row(
                            children: [
                              FilterChip(
                                label: Text(l.add_tag),
                                avatar: const Icon(Icons.add),
                                onSelected: (value) async {
                                  Tag? newTag = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const AddOrEditTagDialog());
                                  if (newTag != null) {
                                    DatabaseHelper().insertNoteTag(newTag);
                                    fetchTags();
                                  }
                                },
                              ),
                            ],
                          )
                        ]),
              ),
              const SizedBox(height: 64),
            ],
          )
        ]),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          DatabaseHelper dh = DatabaseHelper();
          dh.updateNote(noteDraft);
          dh.updateNoteTags(noteDraft.noteId ?? -1, selectedNoteTagsIds);
          if (mounted) {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop(NoteEditResult.edited);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
