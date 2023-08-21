import 'package:flutter/material.dart';

class VirtualDesktopIcon extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final String tooltip;
  final String? label;

  const VirtualDesktopIcon(
      {super.key, required this.backgroundColor,
      required this.icon,
      required this.tooltip,
      this.label});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Tooltip(
          message: tooltip,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              color: backgroundColor,
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}