import 'package:flutter/material.dart';

class EvidenceSwitch extends StatefulWidget {
  final String evidencdID;
  final bool isSwitched;
  const EvidenceSwitch(this.evidencdID, this.isSwitched, {super.key});

  @override
  _EvidenceSwitchState createState() => _EvidenceSwitchState();
}

class _EvidenceSwitchState extends State<EvidenceSwitch> {
  bool _isSwitched = false;

  @override
  void initState() {
    super.initState();
    _isSwitched = widget.isSwitched;
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text("Mark this conversation as evidence"),
      value: _isSwitched,
      onChanged: (value) {
        setState(() {
          _isSwitched = value;
        });
      },
    );
  }
}