class Note {
  int? id;
  String text;
  String datetime;
  String attachments;
  double? lat;
  double? lng;
  String tags;

  Note({
    this.id,
    required this.text,

    /// yyyyMMddHHmmss
    required this.datetime,

    /// list of file paths separated by comma
    this.attachments = '',
    this.lat,
    this.lng,

    /// list of tags separated by comma
    this.tags = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'datetime': datetime,
      'attachments': attachments,
      'lat': lat,
      'lng': lng,
      'tags': tags,
    };
  }

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      text: map['text'],
      datetime: map['datetime'],
      attachments: map['attachments'],
      lat: map['lat'],
      lng: map['lng'],
      tags: map['tags'],
    );
  }
}
