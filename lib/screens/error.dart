import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.error, required this.stackTrace});

  final Object error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: Builder(builder: (context) {
        return Scaffold(
          body: SafeArea(
            child: Expanded(
              child: Center(
                child: Column(
                  children: [
                    Icon(MdiIcons.alertOctagon,
                        size: 64, color: Theme.of(context).colorScheme.error),
                    Text(
                      'Fatal Error',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Error:",
                                style: Theme.of(context).textTheme.labelLarge),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.error)),
                              child: Text(
                                error.toString(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text("Stacktrace:",
                                style: Theme.of(context).textTheme.labelLarge),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.error)),
                              child: Text(
                                stackTrace.toString(),
                              ),
                            ),
                          ],
                        )),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: '$error\n\n$stackTrace'));
                          },
                          label: const Text("Copy"),
                          icon: const Icon(MdiIcons.contentCopy),
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            exit(0);
                          },
                          label: const Text("Exit"),
                          icon: const Icon(MdiIcons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 64),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
