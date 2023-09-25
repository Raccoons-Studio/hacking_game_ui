import 'package:flutter/cupertino.dart';

class VirtualApplication {
  // Example of VirtualApplication instance : VirtualApplication('App1', Icons.apps, Colors.blue)
  final String name;
  final IconData icon;
  final Color color;
  bool isNotification;

  VirtualApplication(this.name, this.icon, this.color, this.isNotification);
}