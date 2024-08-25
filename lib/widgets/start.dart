import 'package:flutter/material.dart';
import 'package:maximum/widgets/important_event.dart';
import 'package:maximum/widgets/inspiration.dart';
import 'package:maximum/widgets/task_item.dart';
import 'package:maximum/widgets/top.dart';

class StartWidget extends StatelessWidget {
  const StartWidget({
    super.key,
    required this.textTheme,
  });

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Top(),
        const SizedBox(height: 32),
        Text(
          'Oś czasu',
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ImportantEvent(textTheme: textTheme),
        const SizedBox(height: 16),
        const TaskItem(title: 'Obejrzyj mecz', subtitle: 'za minutę'),
        const TaskItem(title: 'Pij wodę', subtitle: '6 / 8'),
        const Spacer(),
        const Inspiration(),
      ],
    );
  }
}
