import 'package:flutter/material.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/task_status.dart';

enum TaskTimeType {
  unset,
  asap,
  date,
  dateAndTime,
  dateDeadline,
  dateAndTimeDeadline
}

enum RepeatType { daily, dayOfWeek }

class RepeatData {
  RepeatType repeatType;
  String repeatData;

  RepeatData({required this.repeatType, required this.repeatData});

  @override
  String toString() {
    return repeatData;
  }

  static RepeatType repeatTypeFromString(String str) {
    switch (str) {
      case "DAILY":
        return RepeatType.daily;
      case "DAY_OF_WEEK":
        return RepeatType.dayOfWeek;
      default:
        throw Exception("Unknown repeat type: $str");
    }
  }

  static String repeatTypeToString(RepeatType type) {
    switch (type) {
      case RepeatType.daily:
        return "DAILY";
      case RepeatType.dayOfWeek:
        return "DAY_OF_WEEK";
      default:
        throw Exception("Unknown repeat type: $type");
    }
  }

  static RepeatData fromString(String str, String type) {
    return RepeatData(repeatType: repeatTypeFromString(type), repeatData: str);
  }

  int? get repeatInterval {
    if (repeatType == RepeatType.daily) {
      return int.tryParse(repeatData);
    }
    return null;
  }

  bool? get monday => repeatData[0] == '1' ? true : false;
  bool? get tuesday => repeatData[1] == '1' ? true : false;
  bool? get wednesday => repeatData[2] == '1' ? true : false;
  bool? get thursday => repeatData[3] == '1' ? true : false;
  bool? get friday => repeatData[4] == '1' ? true : false;
  bool? get saturday => repeatData[5] == '1' ? true : false;
  bool? get sunday => repeatData[6] == '1' ? true : false;

  List<bool> get weekdays {
    return [
      monday ?? false,
      tuesday ?? false,
      wednesday ?? false,
      thursday ?? false,
      friday ?? false,
      saturday ?? false,
      sunday ?? false
    ];
  }

  set repeatInterval(int? interval) {
    if (repeatType == RepeatType.daily) {
      repeatData = interval.toString();
    } else {}
  }

  set monday(bool? value) {
    setWeekday(0, value);
  }

  set tuesday(bool? value) {
    setWeekday(1, value);
  }

  set wednesday(bool? value) {
    setWeekday(2, value);
  }

  set thursday(bool? value) {
    setWeekday(3, value);
  }

  set friday(bool? value) {
    setWeekday(4, value);
  }

  set saturday(bool? value) {
    setWeekday(5, value);
  }

  set sunday(bool? value) {
    setWeekday(6, value);
  }

  set weekdays(List<bool> weekdays) {
    repeatData = "";
    for (int i = 0; i < weekdays.length; i++) {
      repeatData += weekdays[i] ? "1" : "0";
    }
  }

  bool? getWeekday(int index) {
    if (repeatType == RepeatType.dayOfWeek) {
      return weekdays[index];
    } else {
      return null;
    }
  }

  void setWeekday(int index, bool? value) {
    if (repeatType == RepeatType.dayOfWeek && value != null) {
      repeatData = repeatData.replaceRange(index, index + 1, value ? "1" : "0");
    } else {}
  }
}

class Task {
  int? taskId;
  String text;
  String? date; // DateFormat('yyyyMMdd')
  String? time; // DateFormat('HHmm')
  int isAsap =
      0; // when date is set this represents date and time as a deadline
  int targetValue = 1;
  String? exclusions; // list of DDMMYYYY for days to exclude
  String? repeatType; // DAILY, DAY_OF_WEEK
  String? repeatData;
  /*
  repeatData is in format:
  for DAILY:
  days interval number
  eg. "2" - every 2 days

  for DAY_OF_WEEK:
  bitmak of days of week
  eg. "0110110" - tuesday, wednesday, friday, saturday
  
  */
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

  bool get asap {
    if (datetime == null) {
      return isAsap == 1;
    } else {
      return false;
    }
  }

  bool get deadline {
    if (datetime == null) {
      return false;
    } else {
      return isAsap == 1;
    }
  }

  RepeatData? get repeat {
    if (repeatType == null || repeatData == null) {
      return null;
    } else {
      return RepeatData.fromString(repeatData!, repeatType!);
    }
  }

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

  TaskTimeType get taskTimeType {
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
    if ((taskTimeType != TaskTimeType.dateAndTime &&
            taskTimeType != TaskTimeType.date) ||
        datetime == null) {
      return false;
    } else {
      if (repeat == null) {
        return DateUtils.isSameDay(datetime!, date);
      } else if (repeat?.repeatType == RepeatType.daily) {
        final difference = date.difference(datetime!).inDays;
        return (difference % (repeat?.repeatInterval ?? 0)) == 0;
      } else if (repeat?.repeatType == RepeatType.dayOfWeek) {
        return repeat?.weekdays[date.weekday - 1] == true;
      } else {
        return false;
      }
    }
  }

  DateTime? nextRepetitionAfter(DateTime setDate) {
    if (repeat == null) {
      return null;
    }

    if (repeat?.repeatType == RepeatType.daily) {
      DateTime tempDate =
          datetime!.add(Duration(days: repeat?.repeatInterval ?? 0));
      while (tempDate.isBefore(setDate)) {
        tempDate = tempDate.add(Duration(days: repeat?.repeatInterval ?? 0));
      }
      return tempDate;
    }

    if (repeat?.repeatType == RepeatType.dayOfWeek) {
      DateTime tempDate = datetime!;
      while (repeat?.weekdays[tempDate.weekday - 1] != true) {
        tempDate = tempDate.add(const Duration(days: 1));
      }
      while (tempDate.isBefore(setDate)) {
        tempDate = tempDate.add(const Duration(days: 7));
      }
      return tempDate;
    }

    return null;
  }

  DateTime? lastRepetitionBefore(DateTime setDate) {
    if (repeat == null) {
      return null;
    }

    if (repeat?.repeatType == RepeatType.daily) {
      DateTime tempDate =
          datetime!.subtract(Duration(days: repeat?.repeatInterval ?? 0));
      while (tempDate.isAfter(setDate)) {
        tempDate =
            tempDate.subtract(Duration(days: repeat?.repeatInterval ?? 0));
      }
      return tempDate;
    }

    if (repeat?.repeatType == RepeatType.dayOfWeek) {
      DateTime tempDate = datetime!;
      while (repeat?.weekdays[tempDate.weekday - 1] != true) {
        tempDate = tempDate.subtract(const Duration(days: 1));
      }
      while (tempDate.isAfter(setDate)) {
        tempDate = tempDate.subtract(const Duration(days: 7));
      }
      return tempDate;
    }

    return null;
  }

  bool get isToday {
    if (date == null) {
      return false;
    } else {
      return occursOn(DateTime.now());
    }
  }

  bool get isTomorrow {
    if (date == null) {
      return false;
    } else {
      return occursOn(DateTime.now().add(const Duration(days: 1)));
    }
  }

  bool get isInNextSevenDays {
    for (int i = 0; i < 7; i++) {
      if (occursOn(DateTime.now().add(Duration(days: i)))) {
        return true;
      } else {
        continue;
      }
    }
    return false;
  }

  bool get isInFuture {
    return !isDue && !isToday && !isTomorrow && !isInNextSevenDays;
  }

  Future<int> getRecentProgressValue() async {
    return await getProgressOnDatetime(DateTime.now());
  }

  Future<int> getProgressOnDatetime(DateTime date) async {
    final statuses = await DatabaseHelper().getTaskStatuses(taskId ?? -1);
    if (statuses.isEmpty) {
      return 0;
    }

    if (repeat != null) {
      return statuses
              .where((TaskStatus status) {
                DateTime? repetitionBefore = lastRepetitionBefore(date);
                if (repetitionBefore == null) {
                  return false;
                }
                DateTime taskStatusDatetime =
                    DateTime.fromMillisecondsSinceEpoch(status.datetime);
                if (taskStatusDatetime.isAfter(repetitionBefore) &&
                    repetitionBefore.isBefore(date)) {
                  return true;
                } else {
                  return false;
                }
              })
              .firstOrNull
              ?.value ??
          0;
    }

    return statuses.last.value;
  }

  Future<bool> get completed async {
    final value = await getRecentProgressValue();
    return value >= targetValue;
  }

  bool get showInStart => isDue || isToday;

  bool get isDateSet => datetime != null;

  bool get isTimeSet => time != null;

  bool get isDue {
    if (datetime == null) {
      return false;
    } else if (repeat != null) {
      return false;
    } else if (taskTimeType == TaskTimeType.date) {
      if (datetime!.isBefore(DateTime.now()) &&
          !DateUtils.isSameDay(datetime!, DateTime.now())) {
        return true;
      } else {
        return false;
      }
    } else if (taskTimeType == TaskTimeType.dateAndTime) {
      if (datetime!.isBefore(DateTime.now())) {
        return true;
      } else {
        return false;
      }
    } else if (taskTimeType == TaskTimeType.dateDeadline) {
      if (datetime!.isBefore(DateTime.now()) ||
          DateUtils.isSameDay(datetime!, DateTime.now())) {
        return true;
      } else {
        return false;
      }
    } else if (taskTimeType == TaskTimeType.dateAndTimeDeadline) {
      if (datetime!.isBefore(DateTime.now())) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Task replaceRepeat(RepeatData? newRepeat) {
    if (newRepeat == null) {
      repeatType = null;
      repeatData = null;
    } else {
      repeatType = RepeatData.repeatTypeToString(newRepeat.repeatType);
      repeatData = newRepeat.repeatData;
    }

    return this;
  }
}
