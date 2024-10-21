import 'package:flutter/material.dart';
import 'package:maximum/utils/quotesy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Inspiration extends StatefulWidget {
  const Inspiration({
    super.key,
  });

  @override
  State<Inspiration> createState() => _InspirationState();
}

class _InspirationState extends State<Inspiration> {
  String _quote =
      '„Tutaj być postawiony cytat, powitanie, cel długoterminowy, że zmienia się co jakiś czas.”';
  String _author = '– designer aplikacji';
  bool? dywlQuotesEnabled;

  void fetchPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dywlQuotesEnabled = prefs.getBool('dywlQuotesEnabled');
  }

  void loadDywlQuote() async {
    var quote = await Quotes.random();
    setState(() {
      _quote = "„${quote.text}”";
      _author = "– ${quote.author}";
    });
  }

  @override
  void initState() {
    super.initState();
    loadQuote();
  }

  void loadQuote() async {
    fetchPrefs();
    if (dywlQuotesEnabled == true) {
      loadDywlQuote();
    } else {
      var quote = 'No quotes available';
      var author = 'No quotes available';
      setState(() {
        _quote = quote;
        _author = author;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: loadQuote,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _quote,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _author,
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).colorScheme.tertiary),
            ),
          ),
        ],
      ),
    );
  }
}
