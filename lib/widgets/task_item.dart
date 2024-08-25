import 'package:flutter/material.dart';
import 'package:maximum/widgets/info_chip.dart';

class TaskItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const TaskItem({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Checkbox(value: false, onChanged: (value) {}),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              InfoChip(
                  subtitle: subtitle,
                  textTheme: textTheme,
                  variant: ChipVariant.secondary)
            ],
          )
        ],
      ),
    );
  }
}
