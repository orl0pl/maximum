import 'package:flutter/material.dart';

class Weather extends StatelessWidget {
  const Weather({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(children: [
      Row(
        children: [
          const Icon(Icons.sunny),
          const SizedBox(width: 4),
          Text('23°', style: textTheme.titleLarge)
        ],
      ),
      Text('13° w nocy', style: textTheme.titleSmall),
    ]);
  }
}
