// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:maximum/screens/error.dart';
import 'package:maximum/screens/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? forceEnglish;

  @override
  void initState() {
    super.initState();

    loadPrefs();
  }

  void loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      forceEnglish = prefs.getBool('forceEnglish') ?? false;
    });
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
          locale: forceEnglish == true ? const Locale('en') : null,
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
