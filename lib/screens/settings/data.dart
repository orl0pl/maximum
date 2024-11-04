import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool> showImportWipeAlertDialog() async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(MdiIcons.deleteForever),
            title: Text(AppLocalizations.of(context).wipe_all_data),
            content: Text(AppLocalizations.of(context)
                .wipe_all_data_while_import_description),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text(AppLocalizations.of(context).wipe_all_data),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
  }

  void exportData() async {
    try {
      var dh = DatabaseHelper();
      var result = await FilePicker.platform.saveFile(
        dialogTitle: AppLocalizations.of(context).export_data,
        allowedExtensions: ['db'],
        fileName:
            'maximum-backup-${DateTime.now().toIso8601String().substring(0, 19)}.db',
        bytes: File(await dh.getDatabasePath()).readAsBytesSync(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).export_data_unknown_error,
            ),
          ),
        );
      }
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void importData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    try {
      if (result != null) {
        var accepted = await showImportWipeAlertDialog();

        if (accepted && result.files.firstOrNull?.path != null) {
          var dh = DatabaseHelper();
          var path = await dh.getDatabasePath();

          await File(result.files.firstOrNull!.path!).copy(path);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).import_data_unknown_error,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).import_data_unknown_error,
            ),
          ),
        );
      }
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void wipeAllData() async {}

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.data),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text(l.export_data),
              // subtitle: Text(l.export_data_description),
              trailing: FilledButton.icon(
                  onPressed: exportData,
                  label: Text(l.export_data),
                  icon: const Icon(Icons.upload)),
            ),
            ListTile(
              title: Text(l.import_data),
              // subtitle: Text(l.import_data_description),
              trailing: FilledButton.tonalIcon(
                  onPressed: importData,
                  label: Text(l.import_data),
                  icon: const Icon(Icons.download)),
            ),
            ListTile(
              title: Text(l.wipe_all_data),

              // subtitle: Text(l.wipe_all_data_description),
              trailing: OutlinedButton.icon(
                  onPressed: null, //wipeAllData,
                  label: Text(l.wipe_all_data),
                  icon: const Icon(Icons.delete_forever)),
            ),
          ],
        ),
      ),
    );
  }
}
