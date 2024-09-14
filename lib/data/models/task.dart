import 'package:maximum/data/database_helper.dart';
import 'place.dart';

enum TaskTimeType {
  unset,
  asap,
  date,
  dateAndTime,
  dateDeadline,
  dateAndTimeDeadline
}

class Task {
  int? taskId;
  String text;
  String? date;
  String? time;
  int isAsap =
      0; // when date is set this represents date and time as a deadline
  int targetValue = 1;
  String? exclusions; // list of DDMMYYYY for days to exclude
  String? repeatType; // DAILY, DAY_OF_WEEK
  String? repeatData;
  int? placeId;
  int active = 1;

  Task({
    this.taskId,
    required this.text,
    this.date,
    this.time,
    this.isAsap = 0,
    this.targetValue = 1,
    this.exclusions,
    this.repeatType,
    this.repeatData,
    this.placeId,
    this.active = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'text': text,
      'date': date,
      'time': time,
      'isAsap': isAsap,
      'targetValue': targetValue,
      'exclusions': exclusions,
      'repeatType': repeatType,
      'repeatData': repeatData,
      'placeId': placeId,
      'active': active,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      taskId: map['taskId'],
      text: map['text'],
      date: map['date'],
      time: map['time'],
      isAsap: map['isAsap'],
      targetValue: map['targetValue'],
      exclusions: map['exclusions'],
      repeatType: map['repeatType'],
      repeatData: map['repeatData'],
      placeId: map['placeId'],
      active: map['active'],
    );
  }

  bool get asap => isAsap == 1;

  DateTime? get datetime {
    if (date == null) {
      return null;
    } else {
      if (date!.length != 8) {
        return null;
      }
      if (time != null) {
        return DateTime(
          int.parse(date!.substring(0, 4)),
          int.parse(date!.substring(4, 6)),
          int.parse(date!.substring(6, 8)),
          int.parse(time!.substring(0, 2)),
          int.parse(time!.substring(2, 4)),
        );
      } else {
        return DateTime(
          int.parse(date!.substring(0, 4)),
          int.parse(date!.substring(4, 6)),
          int.parse(date!.substring(6, 8)),
        );
      }
    }
  }

  get taskTimeType {
    if (date == null && time == null) {
      if (asap) {
        return TaskTimeType.asap;
      } else {
        return TaskTimeType.unset;
      }
    }

    if (time == null) {
      if (asap) {
        return TaskTimeType.dateDeadline;
      } else {
        return TaskTimeType.date;
      }
    }

    if (asap) {
      return TaskTimeType.dateAndTimeDeadline;
    } else {
      return TaskTimeType.dateAndTime;
    }
  }

  bool occursOn(DateTime date) {
    if (taskTimeType != TaskTimeType.dateAndTime ||
        taskTimeType != TaskTimeType.date) {
      return false;
    } else {
      return false;
    }
  }
}

enum RepeatType { daily, dayOfWeek }

class RepeatData {
  int repeatInterval = 1;
  List<int> repeatDays = [];
}

// DELETEME
// class Task {
//   final int? id;
//   final String text;
//   final String? date;
//   final String? time;
//   final bool
//       isAsap; // when date is set this represents date and time as a deadline
//   final int targetValue;
//   final List<String>? exclusions;
//   final RepeatType? repeatType;
//   final String? repeatData;
//   final bool active;

//   Task({
//     this.id,
//     required this.text,
//     this.date,
//     this.time,
//     this.isAsap = false,
//     this.targetValue = 1,
//     this.exclusions,
//     this.repeatType,
//     this.repeatData,
//     this.active = true,
//   });

//   static Task fromRaw(Task raw) {
//     DatabaseHelper dbHelper = DatabaseHelper();
//     if (raw.placeId != null) {
//       dbHelper.getPlace(raw.placeId!).then((place) => taskPlace = place);
//     }
//     return Task(
//       id: raw.taskId,
//       text: raw.text,
//       date: raw.date,
//       time: raw.time,
//       isAsap: raw.isAsap == 1,
//       targetValue: raw.targetValue,
//       exclusions: raw.exclusions?.split(',').map((e) => e.trim()).toList(),
//       repeatType:
//           raw.repeatType == 'DAILY' ? RepeatType.daily : RepeatType.dayOfWeek,
//       repeatData: raw.repeatData,
//       active: raw.active == 1,
//     );
//   }
// }
