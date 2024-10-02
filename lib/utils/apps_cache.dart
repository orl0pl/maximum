import 'dart:convert';
import 'dart:typed_data';

import 'package:installed_apps/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<AppInfo>? getAppsFromCache(SharedPreferences prefs) {
  List<String>? appsFromCache = prefs.getStringList('apps');
  // try {
  if (appsFromCache != null) {
    Iterable<Map> parsedApps = appsFromCache.map((string) {
      return Map<String, dynamic>.from(jsonDecode(string));
    });

    return parsedApps
        .map((app) => {
              'name': app['name']?.toLowerCase() ?? 'n/a',
              'icon': Uint8List.fromList(app['icon']?.cast<int>() ?? <int>[]) ??
                  Uint8List(0),
              'package_name': app['package_name']?.toLowerCase() ?? 'n/a',
              'version_name': app['versionName']?.toLowerCase() ?? 'n/a',
              'version_code': app['versionCode']?.toInt() ?? 1,
              'built_with': app['builtWith'].toString().toLowerCase(),
              'installed_timestamp': app['installedTimestamp']?.toInt() ?? 0,
            })
        .map((map) => AppInfo.create(map))
        .toList();
  } else {
    return null;
  }
  // }
  //  on Error catch (e) {
  //   print("Failed to parse apps from cache: $e\n${e.stackTrace}");

  //   return null;
  // }
}

Map mapAppInfo(AppInfo appInfo) {
  return {
    'name': appInfo.name,
    'icon': appInfo.icon!,
    'package_name': appInfo.packageName,
    'version_name': appInfo.versionName,
    'version_code': appInfo.versionCode,
    'built_with': "N/A",
    'installed_timestamp': appInfo.installedTimestamp,
  };
}

void saveAppsToCache(SharedPreferences prefs, List<AppInfo> apps) {
  List<String> encodedApps = apps.map((app) {
    return jsonEncode(mapAppInfo(app));
  }).toList();

  prefs.setStringList('apps', encodedApps);

  return;
}
