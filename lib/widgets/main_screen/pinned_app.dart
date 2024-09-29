import 'package:app_launcher/app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';

class PinnedApp extends StatelessWidget {
  const PinnedApp({
    super.key,
    required this.app,
  });

  final AppInfo app;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppLauncher.openApp(androidApplicationId: app.packageName);
      },
      child: Image.memory(
        app.icon!,
        width: 48,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error);
        },
      ),
    );
  }
}
