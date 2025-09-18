import 'package:flutter/material.dart';

class ResponsiveLayoutContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const ResponsiveLayoutContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ensure our content has a maximum width for larger screens
        final maxWidth = constraints.maxWidth > 600
            ? 600.0
            : constraints.maxWidth;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(padding: padding, child: child),
          ),
        );
      },
    );
  }
}
