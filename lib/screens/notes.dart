import 'package:flutter/material.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/note.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/screens/add.dart';
import 'package:maximum/widgets/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  NotesScreenState createState() => NotesScreenState();
}

class NotesScreenState extends State<NotesScreen> {
  List<Note>? notes;
  List<Place>? places;
  Set<int> selectedPlacesIds = {}; // Uses or logic for filtering
  bool useOrLogicForSelectedTags = false;
  Set<int> selectedTagsIds = {};

  DatabaseHelper db = DatabaseHelper();
  void fetchNotes() async {
    List<Note> notes = await db.notes;
    setState(() {
      this.notes = notes;
    });
  }

  void fetchPlaces() async {
    List<Place> places = await db.getPlaces();
    setState(() {
      this.places = places;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchNotes();
    fetchPlaces();
  }

  List<Note>? filterNotes(List<Note>? notes) {
    if (notes == null) {
      return null;
    }
    return notes;
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    notes = filterNotes(notes);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) {
            return const AddScreen();
          }));
          fetchNotes();
        },
      ),
      body: Column(children: [
        Row(
          children: [],
        ),
        notes == null
            ? const Center(child: CircularProgressIndicator())
            : notes!.isEmpty
                ? const Text('No notes')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: notes!.length,
                    itemBuilder: (context, index) {
                      return NoteWidget(note: notes![index]);
                    },
                  )
      ]),
      backgroundColor: colorScheme.surfaceContainerLowest,
    );
  }
}
