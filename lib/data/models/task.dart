import 'package:flutter/material.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/repeat_data.dart';
import 'package:maximum/data/models/task_status.dart';

const int defaultRankTune1 = 1000000;
const int defaultRankTune2 = 100;

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

  /// Calculates the base rank score for the task. The higher the score, the
  /// higher the task should be ranked in the timeline.
  ///
  /// The score is based on the following rules:
  ///
  /// 1. If the task is ASAP, the score is [rankTimeToDeadlineMultiplier].
  /// 2. If the task has a deadline or is due, the score is
  ///    [rankTimeToDeadlineMultiplier] divided by the number of minutes until
  ///    the deadline, rounded up to the nearest integer.
  /// 3. If the task is today and has a time set, the score is
  ///    [rankTodayTimeSetMultiplier] divided by the number of minutes until the
  ///    time, rounded up to the nearest integer.
  /// 4. If the task is today and does not have a time set, the score is
  ///    [rankTodayTimeSetMultiplier] divided by 24, rounded down to the nearest
  ///    integer.
  /// 5. If the task is tomorrow and has a time set, the score is
  ///    [rankTodayTimeSetMultiplier] divided by the number of minutes until the
  ///    time, divided by 3, rounded up to the nearest integer.
  /// 6. If the task is tomorrow and does not have a time set, the score is
  ///    [rankTodayTimeSetMultiplier] divided by 24, divided by 3, rounded down to
  ///    the nearest integer.
  /// 7. Otherwise, the score is 1.
  int getRankScoreBase(
      int rankTimeToDeadlineMultiplier, int rankTodayTimeSetMultiplier) {
    if (asap) {
      return rankTimeToDeadlineMultiplier * 100000;
    }
    int diffrence = DateTime.now().difference(datetime!).inMinutes;
    if (deadline || isDue) {
      if (diffrence == 0) {
        return rankTimeToDeadlineMultiplier;
      }
      return (rankTimeToDeadlineMultiplier * diffrence / 60).ceil();
    }

    if (isToday) {
      if (isTimeSet) {
        return (rankTodayTimeSetMultiplier / diffrence).ceil();
      } else {
        return (rankTodayTimeSetMultiplier / 24).floor();
      }
    } else if (isTomorrow) {
      if (isTimeSet) {
        return (rankTodayTimeSetMultiplier / (diffrence * 3)).ceil();
      } else {
        return (rankTodayTimeSetMultiplier / (24 * 3)).floor();
      }
    }

    return 1;
  }

  int getRankScore(bool placeMatching, rankTimeToDeadlineMultiplier,
      rankTodayTimeSetMultiplier) {
    if (placeMatching) {
      return getRankScoreBase(
              rankTimeToDeadlineMultiplier, rankTodayTimeSetMultiplier) *
          3;
    } else {
      return getRankScoreBase(
          rankTimeToDeadlineMultiplier, rankTodayTimeSetMultiplier);
    }
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

  TimeOfDay? get timeOfDay {
    if (time == null) {
      return null;
    } else {
      return TimeOfDay(
        hour: int.parse(time!.substring(0, 2)),
        minute: int.parse(time!.substring(2, 4)),
      );
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
          setDate; //.subtract(Duration(days: repeat?.repeatInterval ?? 0));
      if (occursOn(setDate)) {
        return setDate.copyWith(
            hour: timeOfDay?.hour ?? 0,
            minute: timeOfDay?.minute ?? 0,
            second: 0,
            millisecond: 0,
            microsecond: 0);
      }

      while (tempDate.isAfter(setDate)) {
        tempDate =
            tempDate; //.subtract(Duration(days: repeat?.repeatInterval ?? 0));
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
      int value = statuses
              .where((TaskStatus status) {
                DateTime? repetitionBefore = lastRepetitionBefore(date);
                DateTime? repetitionAfter = nextRepetitionAfter(date);
                if (repetitionBefore == null) {
                  return false;
                }

                if (repetitionAfter == null) {
                  return false;
                }
                DateTime taskStatusDatetime =
                    DateTime.fromMillisecondsSinceEpoch(status.datetime);
                if (taskStatusDatetime.isAfter(repetitionBefore) &&
                    repetitionBefore.isBefore(date) &&
                    taskStatusDatetime.isBefore(repetitionAfter)) {
                  return true;
                } else {
                  return false;
                }
              })
              .firstOrNull
              ?.value ??
          0;

      return value;
    }

    return statuses.firstOrNull?.value ?? 0;
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
