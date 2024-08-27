class Task {
  final int? id;
  final int completed;
  final String title;
  final String attachments;
  final String? time;
  final String date;
  final int isDeadline;
  final String? repeatType;
  final int? repeatInterval;
  final String? repeatDays;
  final String? endType;
  final String? endOn;
  final String? exclude;
  final int? placeId;

  Task({
    this.id,
    this.completed = 0,
    required this.title,
    this.attachments = '',

    /// HHMM
    this.time,

    /// YYYYMMDD
    required this.date,
    this.isDeadline = 0,
    this.repeatType,
    this.repeatInterval,
    this.repeatDays,
    this.endType,
    this.endOn,
    this.exclude,
    this.placeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'completed': completed,
      'title': title,
      'attachments': attachments,
      'time': time,
      'date': date,
      'is_deadline': isDeadline,
      'repeat_type': repeatType,
      'repeat_interval': repeatInterval,
      'repeat_days': repeatDays,
      'end_type': endType,
      'end_on': endOn,
      'exclude': exclude,
      'place_id': placeId,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      completed: map['completed'],
      title: map['title'],
      attachments: map['attachments'],
      time: map['time'],
      date: map['date'],
      isDeadline: map['is_deadline'],
      repeatType: map['repeat_type'],
      repeatInterval: map['repeat_interval'],
      repeatDays: map['repeat_days'],
      endType: map['end_type'],
      endOn: map['end_on'],
      exclude: map['exclude'],
      placeId: map['place_id'],
    );
  }
}
