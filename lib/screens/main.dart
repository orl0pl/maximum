import 'package:android_package_manager/android_package_manager.dart';
import 'package:app_launcher/app_launcher.dart';

import 'package:flutter/material.dart';
import 'package:maximum/screens/error.dart';
import 'package:maximum/screens/notes.dart';
import 'package:maximum/screens/timeline.dart';
import 'package:maximum/widgets/main_screen/bottom.dart';
import 'package:maximum/widgets/subscreens/apps.dart';
import 'package:maximum/widgets/subscreens/start.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

enum ActiveScreen { start, apps }

class _MainScreenState extends State<MainScreen> {
  GlobalKey<AppsWidgetState> appsKey = GlobalKey<AppsWidgetState>();
  GlobalKey<StartWidgetState> startKey = GlobalKey<StartWidgetState>();
  GlobalKey<BottomState> bottomKey = GlobalKey<BottomState>();
  ActiveScreen activeScreen = ActiveScreen.start;
  String text = "";
  List<ApplicationInfo> _apps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApps();
  }

  Future<void> _fetchApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      var packageManager = AndroidPackageManager();
      List<ApplicationInfo>? apps =
          await packageManager.getInstalledApplications(
              flags: ApplicationInfoFlags(
                  {PMFlag.getMetaData, PMFlag.matchDefaultOnly}));
      if (mounted) {
        apps = apps!
            .where((app) =>
                app.name != null && app.icon != null && app.packageName != null)
            .toList();
        List<ApplicationInfo> filteredApps =
            await Future.wait(apps.map((app) async {
          return (await AppLauncher.hasApp(
                      androidApplicationId: app.packageName!)) ==
                  true
              ? app
              : null;
        })).then((values) => values
                .where((element) => element != null)
                .toList()
                .cast<ApplicationInfo>());
        if (mounted) {
          setState(() {
            _apps = filteredApps;
            _isLoading = false;
          });
        }
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
        appsKey.currentState?.sortAndSearchElements(text);
      });
    }
  }

  void setInput(String newInput) {
    if (mounted) {
      setState(() {
        text = newInput;
        appsKey.currentState?.sortAndSearchElements(newInput);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (ActiveScreen.apps == activeScreen) {
          setActiveScreen(ActiveScreen.start);
          bottomKey.currentState?.clearInput();
        }
      },
      child: Scaffold(
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
                            if (activeScreen == ActiveScreen.start) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  maintainState: false,
                                  builder: (context) => const NotesScreen()));
                            }
                          } else if (details.velocity.pixelsPerSecond.dx >
                              1000) {}
                        }
                      },
                      onVerticalDragEnd: (details) {
                        if (details.velocity.pixelsPerSecond.dx.abs() < 1000) {
                          if (details.velocity.pixelsPerSecond.dy < -1000) {
                            setActiveScreen(ActiveScreen.apps);
                          } else if (details.velocity.pixelsPerSecond.dy >
                              1000) {
                            if (activeScreen == ActiveScreen.start) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  maintainState: false,
                                  builder: (context) =>
                                      const TimelineScreen()));
                            } else {
                              setActiveScreen(ActiveScreen.start);
                            }
                          }
                        }
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
                                key: startKey,
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
              InkWell(
                  child: const SizedBox(height: 16),
                  onTap: () {
                    _fetchApps();
                  }),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Bottom(
                  key: bottomKey,
                  appsKey: appsKey,
                  activeScreen: activeScreen,
                  setActiveScreen: setActiveScreen,
                  setInput: setInput,
                  afterFABPressed: () {
                    if (mounted) {
                      setState(() {
                        startKey.currentState?.fetchTasks();
                      });
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
