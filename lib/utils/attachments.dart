import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum GeneralAttachmentType {
  image,
  video,
  audio,
  document,
  unknown,
}

GeneralAttachmentType getAttachmentType(String path) {
  if (path.endsWith(".jpg") ||
      path.endsWith(".jpeg") ||
      path.endsWith(".png") ||
      path.endsWith(".gif") ||
      path.endsWith(".webp") ||
      path.endsWith(".bmp") ||
      path.endsWith(".tiff")) {
    return GeneralAttachmentType.image;
  } else if (path.endsWith(".mp4") ||
      path.endsWith(".mov") ||
      path.endsWith(".avi") ||
      path.endsWith(".mkv") ||
      path.endsWith(".webm")) {
    return GeneralAttachmentType.video;
  } else if (path.endsWith(".mp3") ||
      path.endsWith(".wav") ||
      path.endsWith(".ogg") ||
      path.endsWith(".aac") ||
      path.endsWith(".opus") ||
      path.endsWith(".m4a")) {
    return GeneralAttachmentType.audio;
  } else if (path.endsWith(".doc") ||
      path.endsWith(".docx") ||
      path.endsWith(".pdf") ||
      path.endsWith(".txt") ||
      path.endsWith(".rtf") ||
      path.endsWith(".odt") ||
      path.endsWith(".md")) {
    return GeneralAttachmentType.document;
  } else {
    return GeneralAttachmentType.unknown;
  }
}

String getAttachmentTypeString(GeneralAttachmentType type, AppLocalizations l) {
  switch (type) {
    case GeneralAttachmentType.image:
      return l.image;
    case GeneralAttachmentType.video:
      return l.video;
    case GeneralAttachmentType.audio:
      return l.audio;
    case GeneralAttachmentType.document:
      return l.document;
    default:
      return l.other;
  }
}

IconData getAttachmentTypeIcon(GeneralAttachmentType type) {
  switch (type) {
    case GeneralAttachmentType.image:
      return Icons.image;
    case GeneralAttachmentType.video:
      return Icons.video_collection;
    case GeneralAttachmentType.audio:
      return Icons.audiotrack;
    case GeneralAttachmentType.document:
      return Icons.description;
    default:
      return Icons.attach_file;
  }
}

String getLocalizedAttachmentType(String path, AppLocalizations l) {
  return getAttachmentTypeString(getAttachmentType(path), l);
}

IconData getAttachmentTypeIconFromPath(String path) {
  return getAttachmentTypeIcon(getAttachmentType(path));
}
