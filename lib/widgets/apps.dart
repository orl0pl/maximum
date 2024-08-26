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
    List<AppInfo> allapps = widget.apps;
    bool isLoading = widget.isLoading;

    final fuse = Fuzzy(allapps.map((e) => e.name.toLowerCase()).toList());
    final matches = fuse.search(widget.inputValue.toLowerCase());
    final appMatches = widget.inputValue == ""
        ? allapps
        : matches.where((match) => match.score < 0.50).map((match) {
            return allapps
                .firstWhere((app) => app.name.toLowerCase() == match.item);
          }).toList();

    List<AppInfo> apps = appMatches;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: widget.inputValue != ""
              ? Text(
                  "Best match:",
                  style: widget.textTheme.titleSmall,
                )
              : Text(
                  "All apps",
                  style: widget.textTheme.titleSmall,
                ),
        ),
        Flexible(
          flex: 1,
          child: isLoading
              ? const CircularProgressIndicator()
              : apps.isEmpty
                  ? const Center(
                      child: Text("No apps found"),
                    )
                  : ListView.builder(
                      itemCount: apps.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          tileColor: index == 0 && widget.inputValue != ""
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          leading: apps[index].icon != null
                              ? Image.memory(
                                  apps[index].icon!,
                                  width: 40,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.error);
                                  },
                                )
                              : null,
                          trailing: index == 0 && widget.inputValue != ""
                              ? const Icon(Icons.chevron_right)
                              : null,
                          title: Text(apps[index].name),
                          // subtitle: Text(
                          //     "Match: ${(1 - matches[index].score) * 100}%"),
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
