import 'package:flutter/material.dart';

class ImportantEvent extends StatelessWidget {
  const ImportantEvent({
    super.key,
    required this.textTheme,
  });

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '20:30 - 21:00',
                      style: textTheme.labelMedium,
                    ),
                    Text(
                      'Spotkanie',
                      style: textTheme.titleLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 37,
                child: Container(
                  color: Theme.of(context).colorScheme.primary,
                  height: 8,
                ),
              ),
              Flexible(
                flex: 63,
                child: Container(
                  height: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
