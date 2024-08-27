class Place {
  final int? id;
  final String name;
  final double lat;
  final double lng;
  final int precision;

  Place({
    this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.precision = 50,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'precision': precision,
    };
  }

  static Place fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'],
      name: map['name'],
      lat: map['lat'],
      lng: map['lng'],
      precision: map['precision'] ?? 50,
    );
  }
}
