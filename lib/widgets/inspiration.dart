import 'package:flutter/material.dart';

class Inspiration extends StatelessWidget {
  const Inspiration({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '„Tutaj może być postawiony cytat, powitanie, cel długoterminowy, które zmienia się co jakiś czas.”',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '– designer aplikacji',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}
