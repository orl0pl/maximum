import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

class PinnedApp extends StatelessWidget {
  const PinnedApp({
    super.key,
    required this.app,
  });

  final ApplicationWithIcon app;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        app.openApp();
      },
      child: Image.memory(
        app.icon,
        width: 48,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error);
        },
      ),
    );
  }
}
