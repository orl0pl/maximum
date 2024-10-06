// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:maximum/screens/main.dart';

Future<void> main() async {
  if (kDebugMode) {
    runApp(const MyApp());
  } else {
    runZonedGuarded(() {
      runApp(const MyApp());
    }, (error, stackTrace) {
      // ignore: avoid_print
      print(error);
      // ignore: avoid_print
      print(stackTrace);
      runApp(ErrorScreen(
        error: error,
        stackTrace: stackTrace,
      ));
    });
  }
}

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    findSystemLocale().then((locale) => {Intl.systemLocale = locale});
  }

  (ColorScheme light, ColorScheme dark) _generateDynamicColourSchemes(
      ColorScheme lightDynamic, ColorScheme darkDynamic) {
    var lightBase = ColorScheme.fromSeed(seedColor: lightDynamic.primary);
    var darkBase = ColorScheme.fromSeed(
        seedColor: darkDynamic.primary, brightness: Brightness.dark);

    var lightAdditionalColours = _extractAdditionalColours(lightBase);
    var darkAdditionalColours = _extractAdditionalColours(darkBase);

    var lightScheme =
        _insertAdditionalColours(lightBase, lightAdditionalColours);
    var darkScheme = _insertAdditionalColours(darkBase, darkAdditionalColours);

    return (lightScheme.harmonized(), darkScheme.harmonized());
  }

  List<Color> _extractAdditionalColours(ColorScheme scheme) => [
        scheme.surface,
        scheme.surfaceDim,
        scheme.surfaceBright,
        scheme.surfaceContainerLowest,
        scheme.surfaceContainerLow,
        scheme.surfaceContainer,
        scheme.surfaceContainerHigh,
        scheme.surfaceContainerHighest,
      ];

  ColorScheme _insertAdditionalColours(
          ColorScheme scheme, List<Color> additionalColours) =>
      scheme.copyWith(
        surface: additionalColours[0],
        surfaceDim: additionalColours[1],
        surfaceBright: additionalColours[2],
        surfaceContainerLowest: additionalColours[3],
        surfaceContainerLow: additionalColours[4],
        surfaceContainer: additionalColours[5],
        surfaceContainerHigh: additionalColours[6],
        surfaceContainerHighest: additionalColours[7],
      );

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();

    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      ColorScheme lightScheme, darkScheme;

      if (lightDynamic != null && darkDynamic != null) {
        (lightScheme, darkScheme) =
            _generateDynamicColourSchemes(lightDynamic, darkDynamic);
      } else {
        lightScheme = ColorScheme.fromSwatch(
            primarySwatch: Colors.amber, brightness: Brightness.light);
        darkScheme = ColorScheme.fromSwatch(
            primarySwatch: Colors.amber, brightness: Brightness.dark);
      }
      return MaterialApp(
          title: 'Maximum Launcher',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('pl'),
          ],
          home: const MainScreen(),
          themeMode: ThemeMode.system,
          theme: ThemeData(
            colorScheme: lightScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
          ));
    });
  }
}
