@Deprecated('Do not use. This will be implemented when #1 is done.')
class NoteAttachment {
  int? attachmentId;
  int noteId;
  String data;
  NoteAttachment({this.attachmentId, required this.noteId, required this.data});

  Map<String, dynamic> toMap() {
    return {
      'attachmentId': attachmentId,
      'noteId': noteId,
      'data': data,
    };
  }

  static NoteAttachment fromMap(Map<String, dynamic> map) {
    return NoteAttachment(
      attachmentId: map['attachmentId'],
      noteId: map['noteId'],
      data: map['data'],
    );
  }
}

class TaskAttachment {
  int? attachmentId;
  int taskId;
  String data;
  TaskAttachment({this.attachmentId, required this.taskId, required this.data});

  Map<String, dynamic> toMap() {
    return {
      'attachmentId': attachmentId,
      'taskId': taskId,
      'data': data,
    };
  }

  static TaskAttachment fromMap(Map<String, dynamic> map) {
    return TaskAttachment(
      attachmentId: map['attachmentId'],
      taskId: map['taskId'],
      data: map['data'],
    );
  }
}
