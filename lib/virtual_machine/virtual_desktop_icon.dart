import 'package:flutter/material.dart';

class VirtualDesktopIcon extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final String tooltip;
  final bool isNotification;
  final String? label;

  const VirtualDesktopIcon(
      {Key? key, required this.backgroundColor,
      required this.icon,
      required this.tooltip,
      this.isNotification = false,
      this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: tooltip,
              child: Stack(
                children: <Widget>[
                  ClipRRect(
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
                  if (isNotification)
                     const Positioned(
                      right: -1.8,
                      top: -1.5,
                      child: Icon(Icons.brightness_1, size: 12.0, color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}