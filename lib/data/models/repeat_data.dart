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
