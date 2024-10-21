import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:intl/intl.dart';
import 'package:maximum/utils/intents.dart';
import 'package:maximum/widgets/start_subscreen/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../weather.dart';

class TopChip extends StatefulWidget {
  const TopChip({
    super.key,
    this.icon,
    this.title,
    this.text,
    this.onTap,
    this.onLongPress,
    this.iconSpinning = false,
  });

  final IconData? icon;
  final String? title;
  final String? text;
  final Function()? onTap;
  final Function()? onLongPress;
  final bool iconSpinning;

  @override
  State<TopChip> createState() => _TopChipState();
}

class _TopChipState extends State<TopChip> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: Durations.long1,
    vsync: this,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.iconSpinning) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (widget.icon == null && widget.title == null && widget.text == null) {
      throw Exception("Either icon, title or text must be provided");
    }
    if (!widget.iconSpinning) {
      _controller.reset();
    }
    if (widget.iconSpinning && !_controller.isAnimating) {
      _controller.repeat();
    }
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(24),
      onLongPress: widget.onLongPress,
      child: Container(
        height: 36,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          //border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: 36,
                width: widget.icon != null && widget.title == null ? 36 : null,
                padding: widget.title == null
                    ? EdgeInsets.zero
                    : EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  shape: widget.icon != null && widget.title == null
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  borderRadius: widget.icon != null && widget.title == null
                      ? null
                      : BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null)
                      RotationTransition(
                        turns: _animation,
                        child: Icon(
                          widget.icon,
                          color: colorScheme.onSecondary,
                        ),
                      ),
                    if (widget.title != null) ...[
                      if (widget.icon != null) const SizedBox(width: 4),
                      Text(widget.title!,
                          style: textTheme.titleSmall
                              ?.copyWith(color: colorScheme.onSecondary)),
                    ]
                  ],
                )),
            if (widget.text != null) ...[
              const SizedBox(width: 8),
              Text(widget.text!, style: textTheme.bodyMedium),
              const SizedBox(width: 16),
            ],
          ],
        ),
      ),
    );
  }
}
