import 'package:latlong2/latlong.dart';

class Place {
  int? placeId;
  String name;
  double lat;
  double lng;
  int maxDistance;

  Place({
    this.placeId,
    required this.name,
    required this.lat,
    required this.lng,
    this.maxDistance = 50,
  });

  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'name': name,
      'lat': lat,
      'lng': lng,
      'maxDistance': maxDistance,
    };
  }

  static Place fromMap(Map<String, dynamic> map) {
    return Place(
      placeId: map['placeId'],
      name: map['name'],
      lat: map['lat'],
      lng: map['lng'],
      maxDistance: map['maxDistance'] ?? 50,
    );
  }

  get latlng => LatLng(lat, lng);
}
