import 'package:flutter/material.dart';
import 'package:maximum/data/models/tags.dart';

class TagLabel extends StatelessWidget {
  const TagLabel({super.key, required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HSLColor.fromAHSL(
                    1, int.tryParse(tag.color)?.toDouble() ?? 0, 1, 0.5)
                .toColor(),
          ),
        ),
        const SizedBox(width: 8),
        Text(tag.name)
      ],
    );
  }
}
