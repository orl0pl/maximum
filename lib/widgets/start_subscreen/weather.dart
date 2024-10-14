import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maximum/screens/settings/generic_pick_app.dart';
import 'package:maximum/utils/location.dart';
import 'package:maximum/utils/weather/code_to_icon.dart';
import 'package:maximum/utils/weather/temperature.dart';
import 'package:maximum/utils/weather/weather_description.dart';
import 'package:open_meteo/open_meteo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Weather extends StatefulWidget {
  const Weather({
    super.key,
  });

  @override
  State<Weather> createState() => _WeatherState();
}

WindspeedUnit getWindSpeedUnit(String unit) {
  switch (unit) {
    case 'm/s':
      return WindspeedUnit.ms;
    case 'mph':
      return WindspeedUnit.mph;
    case 'kn':
      return WindspeedUnit.kn;
    case 'kmh':
      return WindspeedUnit.kmh;
    default:
      return WindspeedUnit.ms;
  }
}

enum WeatherLoadingState { loading, done, noLocation, noInternet }

class _WeatherState extends State<Weather> {
  String temperature = '';
  String description = '';
  IconData icon = MdiIcons.helpCircleOutline;
  WeatherLoadingState loadingState = WeatherLoadingState.loading;

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  void getWeather() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String temperatureUnit = prefs.getString('temperatureUnit') ?? 'C';
    String windSpeedUnit = prefs.getString('windSpeedUnit') ?? 'm/s';
    String precipitationUnit = prefs.getString('precipitationUnit') ?? 'mm';
    WeatherApi api = WeatherApi(
      temperatureUnit: temperatureUnit == 'C'
          ? TemperatureUnit.celsius
          : TemperatureUnit.fahrenheit,
      windspeedUnit: getWindSpeedUnit(windSpeedUnit),
      precipitationUnit: precipitationUnit == 'mm'
          ? PrecipitationUnit.mm
          : PrecipitationUnit.inch,
    );

    if (!mounted) return;

    Position? currentPosition = await determinePositionWithSnackBar(
      context,
      mounted,
    );
    final latitude = currentPosition?.latitude;
    final longitude = currentPosition?.longitude;

    if (latitude == null || longitude == null) {
      setState(() {
        loadingState = WeatherLoadingState.noLocation;
      });
      return;
    }

    try {
      // TODO: use experimental minutely_15
      final ApiResponse<WeatherApi> response = await api.request(
          latitude: latitude,
          longitude: longitude,
          current: {
            WeatherCurrent.rain,
            WeatherCurrent.snowfall,
            WeatherCurrent.temperature_2m,
            WeatherCurrent.showers,
            WeatherCurrent.weather_code,
          },
          forecastMinutely15: 96,
          daily: {
            WeatherDaily.temperature_2m_min,
            WeatherDaily.temperature_2m_max,
            WeatherDaily.weather_code,
            WeatherDaily.precipitation_probability_max,
            WeatherDaily.uv_index_max,
            WeatherDaily.rain_sum,
            WeatherDaily.snowfall_sum,
          },
          hourly: {
            WeatherHourly.temperature_2m,
            WeatherHourly.weather_code,
            WeatherHourly.precipitation_probability,
            WeatherHourly.snowfall,
            WeatherHourly.rain,
            WeatherHourly.showers,
            WeatherHourly.uv_index,
          });

      if (!mounted) return;
      setState(() {
        description =
            getDescription(AppLocalizations.of(context), response, prefs);
        temperature =
            response.currentData[WeatherCurrent.temperature_2m]?.value != null
                ? formatTemperature(
                    response.currentData[WeatherCurrent.temperature_2m]!.value,
                    prefs.getString('temperatureUnit') ?? 'C')
                : '??';
        icon = codeToIcon(
            response.currentData[WeatherCurrent.weather_code]?.value.toInt() ??
                0);

        loadingState = WeatherLoadingState.done;
      });
    } on SocketException {
      setState(() {
        loadingState = WeatherLoadingState.noInternet;
      });
    }
  }

  void openWeatherApp() async {
    var prefs = await SharedPreferences.getInstance();
    String? weatherAppPackageName = prefs.getString('weatherApp');

    if (weatherAppPackageName != null) {
      DeviceApps.openApp(weatherAppPackageName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).no_weather_app_set),
          action: SnackBarAction(
            label: AppLocalizations.of(context).set_weather_app,
            onPressed: () async {
              var app = await launchAppPicker(context, weatherAppPackageName,
                  AppLocalizations.of(context).set_weather_app);

              if (app != null) {
                prefs.setString('weatherApp', app);
              }
            },
          ),
        ),
      );
    }
  }

  bool get isLoading {
    return loadingState == WeatherLoadingState.loading;
  }

  bool get locationError {
    return loadingState == WeatherLoadingState.noLocation;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    TextTheme textTheme = Theme.of(context).textTheme;
    return InkWell(
      onLongPress: getWeather,
      onTap: openWeatherApp,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(
          children: [
            isLoading
                ? const Icon(MdiIcons.helpCircleOutline)
                : locationError
                    ? const Icon(MdiIcons.alertCircleOutline)
                    : Icon(icon),
            const SizedBox(width: 4),
            Text(isLoading ? "???" : temperature, style: textTheme.titleLarge)
          ],
        ),
        Text(
            isLoading
                ? l.loading
                : locationError
                    ? l.unknown_location
                    : description,
            style: textTheme.titleSmall),
      ]),
    );
  }
}
