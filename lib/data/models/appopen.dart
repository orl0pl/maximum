enum AppOpenOpenedVia { appList, search }

int getWeekQuarter(DateTime date) {
  DateTime lastMonday =
      date.subtract(Duration(days: (date.weekday - 1 + 7) % 7 + 7));
  return (date.difference(lastMonday).inMinutes / 15).floor();
}

class AppOpen {
  final DateTime datetime;
  final String packageName;
  final int weekQuarter; // floor(minutes_since_monday_midnight / 15)
  final AppOpenOpenedVia openedVia;

  AppOpen({
    required this.datetime,
    required this.packageName,
    required this.weekQuarter,
    required this.openedVia,
  });

  factory AppOpen.fromMap(Map<String, dynamic> map) {
    return AppOpen(
      datetime: DateTime.fromMillisecondsSinceEpoch(map['datetime'] as int),
      packageName: map['packageName'] as String,
      weekQuarter: map['weekQuarter'] as int,
      openedVia: AppOpenOpenedVia.values[map['openedVia'] as int],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'datetime': datetime.millisecondsSinceEpoch,
      'packageName': packageName,
      'weekQuarter': weekQuarter,
      'openedVia': openedVia.index,
    };
  }
}
