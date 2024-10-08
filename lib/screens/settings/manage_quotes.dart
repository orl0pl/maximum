import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageQuotesScreen extends StatefulWidget {
  const ManageQuotesScreen({super.key});

  @override
  State<ManageQuotesScreen> createState() => _ManageQuotesScreenState();
}

class _ManageQuotesScreenState extends State<ManageQuotesScreen> {
  SharedPreferences? prefs;
  bool? dywlQuotesEnabled;

  @override
  void initState() {
    super.initState();
    fetchPrefs();
  }

  void fetchPrefs() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      dywlQuotesEnabled = prefs?.getBool('dywlQuotesEnabled') ?? false;
    });
  }

  void savePrefs() async {
    prefs?.setBool('dywlQuotesEnabled', dywlQuotesEnabled ?? false);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
          title: Text(l.manage_quotes),
        ),
        body: ListView(children: [
          SwitchListTile(
              title: Text(l.api_enabled("dywl/quotes")),
              value: dywlQuotesEnabled ?? false,
              onChanged: (value) {
                setState(() {
                  dywlQuotesEnabled = value;
                });
                savePrefs();
              }),
        ]));
  }
}
