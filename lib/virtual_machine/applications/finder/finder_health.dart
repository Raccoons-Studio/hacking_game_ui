import 'package:flutter/material.dart';

class FinderHealth extends StatefulWidget {
  final int bpm;

  const FinderHealth({super.key, required this.bpm, required int beatsPerMinute});

  @override
  _HeartBeatState createState() => _HeartBeatState();
}

class _HeartBeatState extends State<FinderHealth> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: ((60 / widget.bpm * 1000) / 2).round()),
      vsync: this,
    );

    _animation = Tween(begin: 140.0, end: 170.0).animate(_controller)
      ..addListener(() => setState(() {}));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void didUpdateWidget(FinderHealth oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bpm != widget.bpm) {
      _controller.duration = Duration(milliseconds: ((60 / widget.bpm * 1000) / 2).round());
    }
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(Icons.favorite, color: Colors.red, size: _animation.value),
            Text(
              "${widget.bpm} BPM",
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

