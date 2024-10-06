String formatTemperature(double temperature, String unit, {int? decimals = 0}) {
  if (unit == 'F') {
    return '${temperature.toStringAsFixed(decimals ?? 0)}°F';
  } else {
    return '${temperature.toStringAsFixed(decimals ?? 0)}°C';
  }
}
