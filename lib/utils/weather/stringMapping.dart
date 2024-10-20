import 'package:open_meteo/open_meteo.dart';

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
