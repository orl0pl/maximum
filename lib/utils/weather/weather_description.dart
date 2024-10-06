import 'package:maximum/utils/weather/temperature.dart';
import 'package:open_meteo/open_meteo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // temperature at night or coming day

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

  whenRainWillEnd = hourlyPrecipitationEntries
      .take(24)
      .where((entry) {
        return entry.value < 50;
      })
      .firstOrNull
      ?.key;

  whenSnowWillEnd = whenRainWillEnd; // probably

  willRainToday = hourlyRainEntries.take(24).where((entry) {
    return entry.value > 0;
  }).isNotEmpty;

  willSnowToday = hourlySnowfallEntries.take(24).where((entry) {
    return entry.value > 0;
  }).isNotEmpty;

  willShowerToday = hourlyShowersEntries.take(24).where((entry) {
    return entry.value > 0;
  }).isNotEmpty;

  willThunderstormBeToday = hourlyWeatherCodeEntries.take(24).where((entry) {
    return entry.value > 94; // 95, 96, 99 is thunderstorm
  }).isNotEmpty;

  highUvIndexToday = (response.dailyData[WeatherDaily.uv_index_max]?.values
              .entries.first.value ??
          -1) >
      5;

  whenRainWillStart = hourlyRainEntries
      .take(24)
      .where((entry) {
        return entry.value > 0;
      })
      .firstOrNull
      ?.key;

  whenSnowWillStart = hourlySnowfallEntries
      .take(24)
      .where((entry) {
        return entry.value > 0;
      })
      .firstOrNull
      ?.key;

  whenShowerWillStart = hourlyShowersEntries
      .take(24)
      .where((entry) {
        return entry.value > 0;
      })
      .firstOrNull
      ?.key;

  whenThunderstormWillStart = hourlyWeatherCodeEntries
      .take(24)
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
      return l
          .rain_will_end(whenRainWillEnd.difference(DateTime.now()).inHours);
    }
  }
  if (isSnowingNow) {
    if (whenSnowWillEnd != null) {
      return l
          .snow_will_end(whenSnowWillEnd.difference(DateTime.now()).inHours);
    }
  }

  if (willRainToday) {
    if (whenRainWillStart != null) {
      return l.rain_will_start(
          whenRainWillStart.difference(DateTime.now()).inHours);
    }
  }

  if (willSnowToday) {
    if (whenSnowWillStart != null) {
      return l.snow_will_start(
          whenSnowWillStart.difference(DateTime.now()).inHours);
    }
  }

  if (willShowerToday) {
    if (whenShowerWillStart != null) {
      return l.shower_will_start(
          whenShowerWillStart.difference(DateTime.now()).inHours);
    }
  }

  if (willThunderstormBeToday) {
    if (whenThunderstormWillStart != null) {
      return l.thunderstorm_will_start(
          whenThunderstormWillStart.difference(DateTime.now()).inHours);
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

  return "n/a";
}
