import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maximum/data/models/task.dart';

String formatDate(DateTime date, AppLocalizations? l) {
  DateTime today = DateTime.now();
  DateTime tomorrow = today.add(const Duration(days: 1));
  DateTime yesterday = today.subtract(const Duration(days: 1));

  if (DateUtils.isSameDay(date, today)) {
    return l?.today ?? 'today';
  } else if (DateUtils.isSameDay(date, tomorrow)) {
    return 'tomorrow';
  } else if (DateUtils.isSameDay(date, yesterday)) {
    return 'yesterday';
  } else if (date.isAfter(DateUtils.dateOnly(DateTime.now())) &&
      date.isBefore(
          DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 7)))) {
    return DateFormat.EEEE().format(date);
  } else {
    return DateFormat.yMEd().format(date); // formatuj datę
  }
}

String formatTaskDateAndTime(Task task, AppLocalizations? l) {
  DateTime today = DateTime.now();
  DateTime tomorrow = today.add(const Duration(days: 1));
  DateTime yesterday = today.subtract(const Duration(days: 1));
  DateTime date = task.datetime ?? DateTime.now();

  if (DateUtils.isSameDay(date, today)) {
    if (task.isTimeSet) {
      return DateFormat.jm().format(date);
    }
    return l?.today ?? 'today';
  } else if (DateUtils.isSameDay(date, tomorrow)) {
    if (task.isTimeSet) {
      return '${l?.tomorrow ?? 'tomorrow'} ${DateFormat.jm().format(date)}';
    }
    return l?.tomorrow ?? 'tomorrow';
  } else if (DateUtils.isSameDay(date, yesterday)) {
    if (task.isTimeSet) {
      return '${'yesterday'} ${DateFormat.jm().format(date)}';
    }
    return 'yesterday';
  } else if (date.isAfter(DateUtils.dateOnly(DateTime.now())) &&
      date.isBefore(
          DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 7)))) {
    if (task.isTimeSet) {
      return '${DateFormat.EEEE().format(date)} ${DateFormat.jm().format(date)}';
    }
    return DateFormat.EEEE().format(date);
  } else {
    return DateFormat.yMEd().format(date); // formatuj datę
  }
}
