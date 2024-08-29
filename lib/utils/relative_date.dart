import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String formatDate(DateTime date, AppLocalizations? l) {
  DateTime today = DateTime.now();
  DateTime tommorow = today.add(const Duration(days: 1));
  DateTime yesterday = today.subtract(const Duration(days: 1));

  if (DateUtils.isSameDay(date, today)) {
    return l?.today ?? 'today';
  } else if (DateUtils.isSameDay(date, tommorow)) {
    return 'tommorow';
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
