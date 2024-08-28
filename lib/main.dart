// ignore_for_file: depend_on_referenced_packages

import 'package:android_intent_plus/android_intent.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:maximum/screens/add.dart';
import 'package:maximum/widgets/apps.dart';
import 'package:maximum/widgets/start.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';

Future<void> main() async {
  runApp(const MyApp());
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

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();

    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
          title: 'Localizations Sample App',
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
            colorScheme: lightDynamic,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkDynamic?.copyWith(
                  brightness: Brightness.dark,
                ) ??
                ColorScheme.fromSwatch(primarySwatch: Colors.amber)
                    .copyWith(brightness: Brightness.dark),
          ));
    });
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

enum ActiveScreen { start, apps }

class _MainScreenState extends State<MainScreen> {
  GlobalKey<AppsWidgetState> appsKey = GlobalKey<AppsWidgetState>();
  ActiveScreen activeScreen = ActiveScreen.start;
  String text = "";
  List<AppInfo> _apps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApps();
  }

  Future<void> _fetchApps() async {
    try {
      List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
      if (mounted) {
        setState(() {
          _apps = apps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void setActiveScreen(ActiveScreen newActiveScreen) {
    if (mounted) {
      setState(() {
        activeScreen = newActiveScreen;
      });
    }
  }

  void setInput(String newInput) {
    if (mounted) {
      setState(() {
        text = newInput;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (ActiveScreen.apps == activeScreen) {
          setActiveScreen(ActiveScreen.start);
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLowest,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                  fit: FlexFit.loose,
                  child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragEnd: (details) {
                        if (details.velocity.pixelsPerSecond.dy.abs() < 1000) {
                          if (details.velocity.pixelsPerSecond.dx < -1000) {
                            setActiveScreen(ActiveScreen.apps);
                          } else if (details.velocity.pixelsPerSecond.dx >
                              1000) {
                            setActiveScreen(ActiveScreen.start);
                          }
                        }
                        // print(
                        //     "horizontal x: ${details.velocity.pixelsPerSecond.dx} y: ${details.velocity.pixelsPerSecond.dy}");
                      },
                      onVerticalDragEnd: (details) {
                        if (details.velocity.pixelsPerSecond.dx.abs() < 1000) {
                          if (details.velocity.pixelsPerSecond.dy < -1000) {
                            setActiveScreen(ActiveScreen.apps);
                          } else if (details.velocity.pixelsPerSecond.dy >
                              1000) {
                            setActiveScreen(ActiveScreen.start);
                          }
                        }
                        // print(
                        //     "vertical x: ${details.velocity.pixelsPerSecond.dx} y: ${details.velocity.pixelsPerSecond.dy}");
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation.drive(
                              Tween<double>(
                                begin: 0,
                                end: 1,
                              ).chain(
                                CurveTween(curve: Curves.easeIn),
                              ),
                            ),
                            child: child,
                          );
                        },
                        child: activeScreen == ActiveScreen.start
                            ? StartWidget(
                                textTheme: textTheme,
                              )
                            : AppsWidget(
                                key: appsKey,
                                textTheme: textTheme,
                                inputValue: text,
                                apps: _apps,
                                isLoading: _isLoading,
                              ),
                      ))),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Bottom(
                  appsKey: appsKey,
                  activeScreen: activeScreen,
                  setActiveScreen: setActiveScreen,
                  setInput: setInput,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Bottom extends StatelessWidget {
  const Bottom({
    super.key,
    required this.activeScreen,
    required this.setActiveScreen,
    required this.setInput,
    required this.appsKey,
  });

  final ActiveScreen activeScreen;
  final void Function(ActiveScreen) setActiveScreen;
  final void Function(String) setInput;

  final GlobalKey<AppsWidgetState> appsKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.phone),
                    onPressed: () {
                      launchUrl(Uri.parse('tel:'));
                    },
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.message),
                    onPressed: () {
                      launchUrl(Uri.parse('sms:'));
                    },
                  ),
                  IconButton.filledTonal(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () {
                        const intent = AndroidIntent(
                          action: 'android.media.action.STILL_IMAGE_CAMERA',
                        );

                        intent.launchChooser("Select an app");
                      }),
                  IconButton.filledTonal(
                      icon: const Icon(Icons.location_on),
                      onPressed: () {
                        const intent = AndroidIntent(
                          action: 'android.intent.action.VIEW',
                          package: 'com.google.android.apps.maps',
                        );
                        intent.launch();
                      }),
                ],
              ),
            ),
            Flexible(
              flex: 25,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AddScreen()));

                  setActiveScreen(ActiveScreen.start);
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        SearchBar(
            hintText: "Szukaj w aplikacjach i nie tylko",
            autoFocus: activeScreen == ActiveScreen.apps,
            onChanged: (value) {
              setInput(value);
            },
            onTap: () {
              if (activeScreen != ActiveScreen.apps) {
                setActiveScreen(ActiveScreen.apps);
              }
            },
            onSubmitted: (value) {
              if (activeScreen == ActiveScreen.apps) {
                appsKey.currentState?.openTopMatch();
              }
            },
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {},
            ),
            trailing: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
            ]),
      ],
    );
  }
}
