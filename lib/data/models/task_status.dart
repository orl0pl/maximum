class TaskStatus {
  int taskId;
  int datetime;
  int value;

  TaskStatus({
    required this.taskId,
    required this.datetime,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'datetime': datetime,
      'value': value,
    };
  }

  static TaskStatus fromMap(Map<String, dynamic> map) {
    return TaskStatus(
      taskId: map['taskId'],
      datetime: map['datetime'],
      value: map['value'],
    );
  }

  DateTime get dt => DateTime.fromMillisecondsSinceEpoch(datetime);
}
