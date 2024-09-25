import 'package:flutter/material.dart';

enum ChipVariant { primary, secondary, outline }

class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.subtitle,
    required this.variant,
  });

  final String subtitle;
  final ChipVariant variant;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: variant == ChipVariant.primary
              ? Theme.of(context).colorScheme.primary
              : variant == ChipVariant.secondary
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : null,
          border: variant == ChipVariant.outline
              ? Border.all(color: Theme.of(context).colorScheme.primary)
              : null),
      child: Row(
        children: [
          Text(
            subtitle,
            style: textTheme.labelMedium?.copyWith(
              color: variant == ChipVariant.primary
                  ? Theme.of(context).colorScheme.onPrimary
                  : variant == ChipVariant.secondary
                      ? Theme.of(context).colorScheme.onSecondaryContainer
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}
