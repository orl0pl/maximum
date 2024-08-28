import 'package:maximum/database/database_helper.dart';

class Task {
  int? id;
  int completed;
  String title;
  String attachments;
  String? time;
  String date;
  int isDeadline;
  String? repeatType;
  int? repeatInterval;
  String? repeatDays;
  String? endType;
  String? endOn;
  String? exclude;
  int? placeId;

  Task({
    this.id,
    this.completed = 0,
    required this.title,
    this.attachments = '',

    /// HHMM
    this.time,

    /// YYYYMMDD or ASAP or empty for no date
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
      'target_progress': 0,
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

  // int? progressOnDate(DateTime date) {
  //   late TaskProgress? taskProgressForDay;
  //   DatabaseHelper().database.then((db) {

  //   })

  // }

  bool isAsap() {
    return date == 'ASAP';
  }

  bool isPlanned() {
    return date.isNotEmpty;
  }

  DateTime? convertDatetime() {
    if (date.length != 8) {
      return null;
    }
    if (time != null) {
      return DateTime(
        int.parse(date.substring(0, 4)),
        int.parse(date.substring(4, 6)),
        int.parse(date.substring(6, 8)),
        int.parse(time!.substring(0, 2)),
        int.parse(time!.substring(2, 4)),
      );
    } else {
      return DateTime(
        int.parse(date.substring(0, 4)),
        int.parse(date.substring(4, 6)),
        int.parse(date.substring(6, 8)),
      );
    }
  }
}

class TaskProgress {}
