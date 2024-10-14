import 'package:flutter/material.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/tags.dart';
import 'package:maximum/screens/add.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maximum/widgets/alert_dialogs/tag_edit.dart';

class ManageTagsScreen extends StatefulWidget {
  final EntryType typeOfTags;
  const ManageTagsScreen({super.key, required this.typeOfTags});

  @override
  State<ManageTagsScreen> createState() => _ManageTagsScreenState();
}

class _ManageTagsScreenState extends State<ManageTagsScreen> {
  final DatabaseHelper _dh = DatabaseHelper();
  List<Tag>? tags;

  @override
  void initState() {
    super.initState();
    fetchTags();
  }

  void fetchTags() {
    if (widget.typeOfTags == EntryType.task) {
      _dh.taskTags.then((value) => setState(() {
            tags = value;
          }));
    } else {
      _dh.noteTags.then((value) => setState(() {
            tags = value;
          }));
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.typeOfTags == EntryType.task
              ? l.manage_task_tags
              : l.manage_note_tags),
        ),
        body: tags == null
            ? const Center(child: CircularProgressIndicator())
            : tags!.isEmpty
                ? Center(child: Text(l.no_tags))
                : ListView.builder(
                    itemBuilder: (itemBuilder, index) {
                      return ListTile(
                        title: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: HSLColor.fromAHSL(
                                        1,
                                        int.tryParse(tags![index].color)
                                                ?.toDouble() ??
                                            0,
                                        1,
                                        0.5)
                                    .toColor(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(tags![index].name),
                          ],
                        ),
                        trailing: IconButton(
                            onPressed: () async {
                              Tag? newTag = await showDialog(
                                  context: context,
                                  builder: (context) =>
                                      AddOrEditTagDialog(tag: tags![index]));

                              if (newTag != null) {
                                if (widget.typeOfTags == EntryType.task) {
                                  DatabaseHelper().insertTaskTag(newTag);
                                } else {
                                  DatabaseHelper().insertNoteTag(newTag);
                                }
                                fetchTags();
                              }
                            },
                            icon: const Icon(Icons.edit)),
                      );
                    },
                    itemCount: tags!.length,
                  ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            var newTag = await showDialog(
                context: context,
                builder: (context) {
                  return const AddOrEditTagDialog();
                });
            if (newTag != null) {
              if (widget.typeOfTags == EntryType.task) {
                DatabaseHelper().insertTaskTag(newTag);
              } else {
                DatabaseHelper().insertNoteTag(newTag);
              }
              fetchTags();
            }
          },
        ));
  }
}
