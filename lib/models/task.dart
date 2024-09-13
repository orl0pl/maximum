import 'package:flutter/material.dart';
import 'package:maximum/database/database_helper.dart';

class Task {
  int? id;
  int completed;
  int targetProgress;
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
    this.targetProgress = 0,
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
      targetProgress: map['target_progress'],
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

  List<TaskProgress> get taskProgressList {
    List<TaskProgress> taskProgressList = [];
    DatabaseHelper().database.then((db) async {
      db.query('TaskProgress', where: 'task_id = ?', whereArgs: [id]).then(
          (value) {
        taskProgressList = value.map((e) => TaskProgress.fromMap(e)).toList();
      });
    });

    return taskProgressList;
  }

  int getProgressOnDate(DateTime wantedDate) {
    final progressList = taskProgressList;

    if (progressList.isNotEmpty) {
      progressList.where((x) => DateUtils.isSameDay(x.datetime, wantedDate));
    }
    return 0;
  }

  bool get isAsap {
    return date == 'ASAP';
  }

  bool get isDateSet {
    return date.isNotEmpty && date != 'ASAP';
  }

  bool get isTimeSet {
    return time != null && date != 'ASAP' && date != '';
  }

  bool get isSomeday {
    return date == '' && time == null;
  }

  DateTime? get datetime {
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

  bool get isDue {
    return isDateSet &&
        datetime!.isBefore(DateTime.now()) &&
        !DateUtils.isSameDay(DateTime.now(), datetime!);
  }

  bool get isToday {
    return DateUtils.isSameDay(DateTime.now(), datetime!);
  }

  bool get isTomorrow {
    return DateUtils.isSameDay(
        DateTime.now().add(const Duration(days: 1)), datetime);
  }

  bool get isInNextSevenDays {
    return !isDue &&
        !isToday &&
        !isTomorrow &&
        datetime!.isBefore(DateTime.now().add(const Duration(days: 7)));
  }

  bool get isInFuture {
    return datetime!.isAfter(DateTime.now().add(const Duration(days: 7)));
  }
}
/*
 CREATE TABLE IF NOT EXISTS TaskProgress (
        task_id INTEGER NOT NULL REFERENCES Task(id),
        date TEXT NOT NULL,
        current_progress INT DEFAULT 0,
        PRIMARY KEY (task_id, date)
*/

class TaskProgress {
  int taskId;
  String date;

  int currentProgress = 0;

  TaskProgress(
      {required this.taskId, required this.date, this.currentProgress = 0});

  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'date': date,
      'current_progress': currentProgress,
    };
  }

  static TaskProgress fromMap(Map<String, dynamic> map) {
    return TaskProgress(
      taskId: map['task_id'],
      date: map['date'],
      currentProgress: map['current_progress'],
    );
  }

  DateTime get datetime {
    return DateTime(
      int.parse(date.substring(0, 4)),
      int.parse(date.substring(4, 6)),
      int.parse(date.substring(6, 8)),
    );
  }
}
