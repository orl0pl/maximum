import 'dart:typed_data';

import 'package:app_launcher/app_launcher.dart';
import 'package:flutter/material.dart';

class PinnedApp extends StatelessWidget {
  const PinnedApp({
    super.key,
    required this.icon,
    required this.packageName,
  });

  final Uint8List icon;
  final String packageName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          AppLauncher.openApp(androidApplicationId: packageName);
        },
        child: Image.memory(
          icon,
          width: 48,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error);
          },
        ));
  }
}
