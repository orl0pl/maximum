import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:installed_apps/app_info.dart';

class AppsWidget extends StatefulWidget {
  const AppsWidget(
      {super.key,
      required this.textTheme,
      required this.inputValue,
      required this.apps,
      required this.isLoading});

  final TextTheme textTheme;

  final String inputValue;

  final List<AppInfo> apps;

  final bool isLoading;

  @override
  State<AppsWidget> createState() => _AppsWidgetState();
}

class _AppsWidgetState extends State<AppsWidget> {
  @override
  Widget build(BuildContext context) {
    List<AppInfo> apps = widget.apps;
    bool isLoading = widget.isLoading;

    final fuse = Fuzzy(apps.map((e) => e.name).toList());
    final matches = fuse.search(widget.inputValue);
    final appMatches = widget.inputValue == ""
        ? apps
        : matches.where((match) => match.score < 0.99).map((match) {
            return apps.firstWhere((app) => app.name == match.item);
          }).toList();

    apps = appMatches;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Apps", style: widget.textTheme.titleLarge),
        Flexible(
          flex: 1,
          child: isLoading
              ? const CircularProgressIndicator()
              : ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(apps[index].name),
                      subtitle: Text(apps[index].packageName),
                      onTap: () {
                        // Add functionality if needed
                      },
                    );
                  },
                ),
        )
      ],
    );
  }
}
