class Tag {
  final int? tagId;
  final String color;
  final String name;

  Tag({this.tagId, required this.color, required this.name});
}

class TaskTag extends Tag {
  TaskTag({required super.tagId, required super.color, required super.name});
}

class NoteTag extends Tag {
  NoteTag({required super.tagId, required super.color, required super.name});
}

class TaskTagTask {
  final int taskId;
  final int tagId;

  TaskTagTask({required this.taskId, required this.tagId});
}

class NoteTagNote {
  final int noteId;
  final int tagId;

  NoteTagNote({required this.noteId, required this.tagId});
}
