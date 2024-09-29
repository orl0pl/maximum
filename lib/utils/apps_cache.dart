import 'dart:convert';
import 'dart:typed_data';

import 'package:installed_apps/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<AppInfo>? getAppsFromCache(SharedPreferences prefs) {
  List<String>? appsFromCache = prefs.getStringList('apps');
  try {
    if (appsFromCache != null) {
      Iterable<Map> parsedApps = appsFromCache.map((string) {
        return Map<String, dynamic>.from(jsonDecode(string));
      });

      parsedApps = parsedApps.map((app) => {
            'name': app['name'],
            'icon': Uint8List.fromList(app['icon'].cast<int>()),
            'packageName': app['packageName'],
            'versionName': app['versionName'],
            'versionCode': app['versionCode'],
            'builtWith': app['builtWith'],
            'installedTimestamp': app['installedTimestamp'],
          });

      return parsedApps.map((map) => AppInfo.create(map)).toList();
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Map mapAppInfo(AppInfo appInfo) {
  return {
    'name': appInfo.name,
    'icon': appInfo.icon,
    'packageName': appInfo.packageName,
    'versionName': appInfo.versionName,
    'versionCode': appInfo.versionCode,
    'builtWith': appInfo.builtWith.index,
    'installedTimestamp': appInfo.installedTimestamp,
  };
}

void saveAppsToCache(SharedPreferences prefs, List<AppInfo> apps) {
  List<String> encodedApps = apps.map((app) {
    return jsonEncode(mapAppInfo(app));
  }).toList();

  prefs.setStringList('apps', encodedApps);
}
