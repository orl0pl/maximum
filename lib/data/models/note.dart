import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/place.dart';

class Note {
  int? noteId;
  String? title;
  String text;
  int datetime;
  double? lat;
  double? lng;
  int? placeId;

  Note({
    this.noteId,
    this.title,
    required this.text,
    required this.datetime,
    this.lat,
    this.lng,
    this.placeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'noteId': noteId,
      'title': title,
      'text': text,
      'datetime': datetime,
      'lat': lat,
      'lng': lng,
      'placeId': placeId,
    };
  }

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      noteId: map['noteId'],
      title: map['title'],
      text: map['text'],
      datetime: map['datetime'],
      lat: map['lat'],
      lng: map['lng'],
      placeId: map['placeId'],
    );
  }

  bool get hasLocation {
    return lat != null && lng != null;
  }

  Future<Place?> getPlace({bool saveToDbIfMissing = false}) async {
    DatabaseHelper db = DatabaseHelper();
    if (placeId != null) {
      return db.getPlace(placeId!);
    } else if (lat == null && lng == null) {
      return null;
    } else {
      List<Place> places = await db.getPlaces();
      if (places.isEmpty) return null;
      Place? closestPlace;
      double closestDistance = double.infinity;
      for (Place p in places) {
        double distance = Geolocator.distanceBetween(lat!, lng!, p.lat, p.lng);
        if (distance < closestDistance && distance < p.maxDistance) {
          closestDistance = distance;
          closestPlace = p;
        }
      }

      if (closestPlace != null && saveToDbIfMissing) {
        Note newNote = Note(
          title: title,
          text: text,
          datetime: datetime,
          lat: lat,
          lng: lng,
          placeId: closestPlace.placeId,
          noteId: noteId,
        );
        db.updateNote(newNote);
      }
      return closestPlace;
    }
  }

  Future<String> getPlaceName() async {
    Place? place = await getPlace();
    if (place != null) {
      return place.name;
    } else if (lat != null && lng != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat!, lng!);
      if (placemarks.isNotEmpty) {
        return placemarks.first.name ?? '';
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  String get titleOrText {
    return title ?? text;
  }

  get dt {
    return DateTime.fromMillisecondsSinceEpoch(datetime);
  }
}
