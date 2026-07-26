import 'package:actly/core/design/actly_colors.dart';
import 'package:flutter/material.dart';

class TechnicalCard extends StatelessWidget {
  const TechnicalCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.borderColor = ActlyColors.divider,
    this.backgroundColor = ActlyColors.panelBlue,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return content;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: content,
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: ActlyColors.signalCyan,
            shape: BoxShape.square,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
