import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maximum/data/models/note.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/screens/edit_note.dart';

class NoteWidget extends StatefulWidget {
  const NoteWidget({super.key, required this.note, required this.refresh});
  final Note note;
  final Function refresh;

  @override
  State<NoteWidget> createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  String? placeName;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPlace();
  }

  void fetchPlace() async {
    Place? place = await widget.note.getPlace(saveToDbIfMissing: true);
    if (place != null) {
      setState(() {
        placeName = place.name;
        loading = false;
      });
    } else if (widget.note.lat != null && widget.note.lng != null) {
      Placemark? placemark = (await GeocodingPlatform.instance
              ?.placemarkFromCoordinates(widget.note.lat!, widget.note.lng!))
          ?.firstOrNull;
      setState(() {
        loading = false;
        placeName = placemark?.locality;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surfaceContainer),
      child: InkWell(
        onTap: () async {
          NoteEditResult? result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditNoteScreen(
                note: widget.note,
              ),
            ),
          );
          if (result != null) {
            widget.refresh();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.hour_and_location(DateFormat.Hm().format(widget.note.dt),
                  loading ? l.loading : placeName ?? l.unknown_location),
              style: textTheme.labelMedium,
            ),
            Text(widget.note.text)
          ],
        ),
      ),
    );
  }
}
