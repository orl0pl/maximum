import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:installed_apps/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO: fix out of memory error using native LauncherApps

List<AppInfo>? getAppsFromCache(SharedPreferences prefs) {
  return null; // prevent out of memory error
  List<String>? appsFromCache = prefs.getStringList('apps');
  try {
    if (appsFromCache != null) {
      Iterable<Map> parsedApps = appsFromCache.map((string) {
        return Map<String, dynamic>.from(jsonDecode(string));
      });

      return parsedApps
          .map((app) => {
                'name': app['name']?.toString() ?? 'n/a',
                'icon': Uint8List.fromList(app['icon']?.cast<int>() ?? <int>[]),
                'package_name': app['package_name'] ?? 'n/a',
                'version_name': app['versionName'] ?? 'n/a',
                'version_code': app['versionCode'] ?? 1,
                'built_with': app['builtWith'].toString().toLowerCase(),
                'installed_timestamp': app['installedTimestamp']?.toInt() ?? 0,
              })
          .map((map) => AppInfo.create(map))
          .toList();
    } else {
      return null;
    }
  } on Error catch (e) {
    if (kDebugMode) {
      print("Failed to parse apps from cache: $e\n${e.stackTrace}");
    }

    return null;
  }
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
