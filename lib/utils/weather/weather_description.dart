import 'package:maximum/utils/weather/temperature.dart';
import 'package:open_meteo/open_meteo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isInOneDay(MapEntry<DateTime, num> entry) {
  return entry.key.isAfter(DateTime.now()) &&
      entry.key.isBefore(DateTime.now().add(const Duration(days: 1)));
}

String getDescription(AppLocalizations l, ApiResponse<WeatherApi> response,
    SharedPreferences prefs) {
  // shown first
  late bool isRainingNow;
  late DateTime? whenRainWillEnd;
  late bool isSnowingNow;
  late DateTime? whenSnowWillEnd;

  // shown if above is false
  late bool willRainToday;
  late DateTime? whenRainWillStart;
  late bool willSnowToday;
  late DateTime? whenSnowWillStart;
  late bool willShowerToday;
  late DateTime? whenShowerWillStart;
  late bool willThunderstormBeToday;
  late DateTime? whenThunderstormWillStart;
  late bool highUvIndexToday;

  // shown if above is false
  late bool willRainTomorrow;
  late bool willSnowTomorrow;
  late bool highUvIndexTomorrow;
  late bool higherTemperatureTomorrow;
  late bool lowerTemperatureTomorrow;

  // shown if above is false

  // set values

  isRainingNow = (response.currentData[WeatherCurrent.rain]?.value ?? -1) > 0 ||
      (response.currentData[WeatherCurrent.showers]?.value ?? -1) > 0;
  isSnowingNow =
      (response.currentData[WeatherCurrent.snowfall]?.value ?? -1) > 0;

  final hourlyPrecipitationEntries = response
      .hourlyData[WeatherHourly.precipitation_probability]!.values.entries;

  final hourlyRainEntries =
      response.hourlyData[WeatherHourly.rain]!.values.entries;

  final hourlySnowfallEntries =
      response.hourlyData[WeatherHourly.snowfall]!.values.entries;

  final hourlyShowersEntries =
      response.hourlyData[WeatherHourly.showers]!.values.entries;

  final hourlyWeatherCodeEntries =
      response.hourlyData[WeatherHourly.weather_code]!.values.entries;

  // after restarting the app from the settings, some values are null for no reason

  final minutelyRainEntries = response.minutely15Data[WeatherMinutely15.rain]
      ?.values.entries; // it gives null for no reason sometimes

  final minutelySnowfallEntries =
      response.minutely15Data[WeatherMinutely15.snowfall]!.values.entries;

  whenRainWillEnd = minutelyRainEntries
      ?.where((entry) {
        return entry.value == 0;
      })
      .firstOrNull
      ?.key;

  whenSnowWillEnd = minutelySnowfallEntries
      .where((entry) {
        return entry.value == 0;
      })
      .firstOrNull
      ?.key;

  willRainToday = minutelyRainEntries?.where((entry) {
        return entry.value > 0;
      }).isNotEmpty ??
      hourlyPrecipitationEntries.where((entry) {
        return entry.value > 0;
      }).isNotEmpty;

  willSnowToday = minutelySnowfallEntries?.where((entry) {
        return entry.value > 0;
      }).isNotEmpty ??
      willRainToday;

  willShowerToday = minutelyRainEntries?.where((entry) {
        return entry.value > 0;
      }).isNotEmpty ??
      willRainToday;

  willThunderstormBeToday =
      hourlyWeatherCodeEntries.where(isInOneDay).where((entry) {
    return entry.value > 94; // 95, 96, 99 is thunderstorm
  }).isNotEmpty;

  highUvIndexToday = (response.dailyData[WeatherDaily.uv_index_max]?.values
              .entries.first.value ??
          -1) >
      5;

  whenRainWillStart = hourlyRainEntries
      .where((entry) {
        return entry.value > 0;
      })
      .firstOrNull
      ?.key;

  whenSnowWillStart = hourlySnowfallEntries
      .where((entry) {
        return entry.value > 0;
      })
      .firstOrNull
      ?.key;

  whenShowerWillStart = hourlyShowersEntries
      .where((entry) {
        return entry.value > 0;
      })
      .firstOrNull
      ?.key;

  whenThunderstormWillStart = hourlyWeatherCodeEntries
      .where((entry) {
        return entry.value > 94; // 95, 96, 99 is thunderstorm
      })
      .firstOrNull
      ?.key;

  final num todayMaxTemperature = response
      .dailyData[WeatherDaily.temperature_2m_max]!.values.entries
      .toList()[0]
      .value;

  final num tomorrowMaxTemperature = response
      .dailyData[WeatherDaily.temperature_2m_max]!.values.entries
      .toList()[1]
      .value;

  final num temperatureDifference =
      (todayMaxTemperature) - (tomorrowMaxTemperature);

  higherTemperatureTomorrow = temperatureDifference < -1;

  lowerTemperatureTomorrow = temperatureDifference > 1;

  highUvIndexTomorrow = (response
          .dailyData[WeatherDaily.uv_index_max]!.values.entries
          .toList()[1]
          .value) >
      5;

  willRainTomorrow = response.dailyData[WeatherDaily.rain_sum]!.values.entries
          .toList()[1]
          .value >
      0;
  willSnowTomorrow = response
          .dailyData[WeatherDaily.snowfall_sum]!.values.entries
          .toList()[1]
          .value >
      0;
  if (isRainingNow) {
    if (whenRainWillEnd != null) {
      return l.rain_will_end(
          l.hours_num(whenRainWillEnd.difference(DateTime.now()).inHours));
    }
  }
  if (isSnowingNow) {
    if (whenSnowWillEnd != null) {
      return l.snow_will_end(
          l.hours_num(whenSnowWillEnd.difference(DateTime.now()).inHours));
    }
  }

  if (willRainToday) {
    if (whenRainWillStart != null) {
      return l.rain_will_start(
          l.hours_num(whenRainWillStart.difference(DateTime.now()).inHours));
    }
  }

  if (willSnowToday) {
    if (whenSnowWillStart != null) {
      return l.snow_will_start(
          l.hours_num(whenSnowWillStart.difference(DateTime.now()).inHours));
    }
  }

  if (willShowerToday) {
    if (whenShowerWillStart != null) {
      return l.shower_will_start(
          l.hours_num(whenShowerWillStart.difference(DateTime.now()).inHours));
    }
  }

  if (willThunderstormBeToday) {
    if (whenThunderstormWillStart != null) {
      return l.thunderstorm_will_start(l.hours_num(
          whenThunderstormWillStart.difference(DateTime.now()).inHours));
    }
  }

  if (highUvIndexToday) {
    return l.high_uv_index_today;
  }

  if (willRainTomorrow) {
    return l.rain_tomorrow;
  } else if (willSnowTomorrow) {
    return l.snow_tomorrow;
  }

  if (higherTemperatureTomorrow) {
    return l.higher_temperature_tomorrow(formatTemperature(
        temperatureDifference.abs().toDouble(),
        prefs.getString('temperatureUnit') ?? "C"));
  } else if (lowerTemperatureTomorrow) {
    return l.lower_temperature_tomorrow(formatTemperature(
        temperatureDifference.abs().toDouble(),
        prefs.getString('temperatureUnit') ?? "C"));
  }

  if (highUvIndexTomorrow) {
    return l.high_uv_index_tomorrow;
  }

  return l.apparent_temperature(formatTemperature(
      response.currentData[WeatherCurrent.apparent_temperature]!.value,
      prefs.getString('temperatureUnit') ?? "C"));
}
