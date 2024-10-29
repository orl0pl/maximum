import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maximum/screens/add.dart';
import 'package:maximum/screens/settings/apperance.dart';
import 'package:maximum/screens/settings/data.dart';
import 'package:maximum/screens/settings/manage_places.dart';
import 'package:maximum/screens/settings/manage_quotes.dart';
import 'package:maximum/screens/settings/manage_tags.dart';
import 'package:maximum/screens/settings/pinned_apps.dart';
import 'package:maximum/screens/settings/preferences.dart';
import 'package:maximum/utils/enums.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> showAboutDialog() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Maximum Launcher"),
            content: Text("""
Maximum Launcher v${packageInfo.version}
${packageInfo.packageName}
              """),
            actions: [
              IconButton(
                onPressed: () {
                  launchUrl(
                    Uri.parse("https://github.com/orl0pl/maximum"),
                  );
                },
                // ignore: deprecated_member_use
                icon: const Icon(MdiIcons.github),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context).ok),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l.manage_places),
            leading: const Icon(MdiIcons.mapMarkerMultipleOutline),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const ManagePlacesScreen();
              }));
            },
          ),
          ListTile(
            title: Text(l.manage_task_tags),
            leading: const Icon(MdiIcons.textSearchVariant),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const ManageTagsScreen(
                  typeOfTags: EntryType.task,
                );
              }));
            },
          ),
          ListTile(
            title: Text(l.manage_note_tags),
            leading: const Icon(MdiIcons.noteSearchOutline),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const ManageTagsScreen(
                  typeOfTags: EntryType.note,
                );
              }));
            },
          ),
          ListTile(
            title: Text(l.manage_quotes),
            leading: const Icon(MdiIcons.formatQuoteOpenOutline),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const ManageQuotesScreen();
              }));
            },
          ),
          ListTile(
              title: Text(l.pinned_apps),
              leading: const Icon(MdiIcons.pinOutline),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const PinnedAppsScreen();
                }));
              }),
          ListTile(
              title: Text(l.preferences),
              leading: const Icon(Icons.tune),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const PreferencesScreen();
                }));
              }),
          ListTile(
              title: Text(l.apperance),
              leading: const Icon(Icons.palette_outlined),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const ApperanceScreen();
                }));
              }),
          ListTile(
            title: Text(l.data),
            leading: const Icon(MdiIcons.databaseOutline),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const DataScreen();
              }));
            },
          ),
          const Divider(),
          ListTile(
            title: Text(l.about),
            leading: const Icon(Icons.info_outline),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog();
            },
          ),
          const Divider(),
          ListTile(
            title: Text(l.license),
            leading: const Icon(MdiIcons.license),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showLicensePage(context: context, applicationName: "Maximum");
            },
          ),
          const Divider(),
          ListTile(
            title: Text(l.debug),
            leading: const Icon(MdiIcons.debugStepOver),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Not implemented yet"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
