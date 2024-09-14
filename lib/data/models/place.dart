class Place {
  int? id;
  String name;
  double lat;
  double lng;
  int maxDistance;

  Place({
    this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.maxDistance = 50,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'maxDistance': maxDistance,
    };
  }

  static Place fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'],
      name: map['name'],
      lat: map['lat'],
      lng: map['lng'],
      maxDistance: map['maxDistance'] ?? 50,
    );
  }
}
