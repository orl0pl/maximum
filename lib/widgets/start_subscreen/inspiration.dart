import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maximum/utils/quotesy.dart';

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

  void loadDywlQuote() async {
    var quote = await Quotes.random();
    setState(() {
      _quote = "„${quote.text}”";
      _author = "– ${quote.author}";
    });
  }

  void initState() {
    super.initState();
    loadDywlQuote();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: loadDywlQuote,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _quote,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _author,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
