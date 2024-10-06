import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

// Code 	Description
// 0 	Clear sky
// 1, 2, 3 	Mainly clear, partly cloudy, and overcast
// 45, 48 	Fog and depositing rime fog
// 51, 53, 55 	Drizzle: Light, moderate, and dense intensity
// 56, 57 	Freezing Drizzle: Light and dense intensity
// 61, 63, 65 	Rain: Slight, moderate and heavy intensity
// 66, 67 	Freezing Rain: Light and heavy intensity
// 71, 73, 75 	Snow fall: Slight, moderate, and heavy intensity
// 77 	Snow grains
// 80, 81, 82 	Rain showers: Slight, moderate, and violent
// 85, 86 	Snow showers slight and heavy
// 95 	Thunderstorm: Slight or moderate
// 96, 99 	Thunderstorm with slight and heavy hail

IconData codeToIcon(int code) {
  switch (code) {
    case 0:
      return MdiIcons.weatherSunny;
    case 1:
      return MdiIcons.weatherPartlyCloudy;
    case 2:
      return MdiIcons.weatherCloudy;
    case 3:
      return MdiIcons.cloud;
    case 45:
      return MdiIcons.weatherFog;
    case 48:
      return MdiIcons.snowflakeMelt;
    case 51:
      return MdiIcons.weatherRainy;
    case 53:
      return MdiIcons.weatherRainy;
    case 55:
      return MdiIcons.weatherRainy;
    case 56:
      return MdiIcons.weatherSnowy;
    case 57:
      return MdiIcons.weatherSnowy;
    case 61:
      return MdiIcons.weatherRainy;
    case 63:
      return MdiIcons.weatherPouring;
    case 65:
      return MdiIcons.weatherPouring;
    case 66:
      return MdiIcons.weatherSnowyRainy;
    case 67:
      return MdiIcons.weatherSnowyRainy;
    case 71:
      return MdiIcons.weatherSnowy;
    case 73:
      return MdiIcons.weatherSnowy;
    case 75:
      return MdiIcons.weatherSnowyHeavy;
    case 77:
      return MdiIcons.weatherSnowy;
    case 80:
      return MdiIcons.weatherRainy;
    case 81:
      return MdiIcons.weatherRainy;
    case 82:
      return MdiIcons.weatherPouring;
    case 85:
      return MdiIcons.weatherSnowy;
    case 86:
      return MdiIcons.weatherSnowyHeavy;
    case 95:
      return MdiIcons.weatherLightning;
    case 96:
      return MdiIcons.weatherHail;
    default:
      return MdiIcons.helpCircleOutline;
  }
}
