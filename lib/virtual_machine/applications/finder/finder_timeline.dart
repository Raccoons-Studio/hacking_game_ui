import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/virtual_machine/models/timeline_data.dart';

import 'finder_health.dart';
import 'finder_plan.dart';

class FinderTimeline extends StatefulWidget {
  final List<TimelineData> timelines;

  FinderTimeline({required this.timelines});

  @override
  _FinderTimelineState createState() => _FinderTimelineState();
}

class _FinderTimelineState extends State<FinderTimeline> {
  late ScrollController _scrollController;
  int _currentPosition = 0;

  @override
  void initState() {
    super.initState();
    widget.timelines.sort((a, b) =>
        a.week.compareTo(b.week) * 10000 +
        a.day.compareTo(b.day) * 100 +
        a.hour.compareTo(b.hour));
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _currentPosition = _scrollController.offset.round();
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
            child: Center(
          //child: ImageWithMarkers(image: AssetImage('assets/images/map.png'), markers: [Offset(560, 650)],)
          child: buildContentWidget(widget.timelines[_currentPosition]),
        )),
        Container(
          height: 50,
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Week ${widget.timelines[_currentPosition].week}'),
              SizedBox(width: 10),
              Text('Day ${widget.timelines[_currentPosition].day}'),
              SizedBox(width: 10),
              Text('Hour ${widget.timelines[_currentPosition].hour}'),
            ],
          ),
        ),
        Slider(
          value: _currentPosition.toDouble(),
          min: 0,
          max: (widget.timelines.length - 1).toDouble(),
          onChanged: (double value) {
            setState(() {
              _currentPosition = value.round();
            });
          },
        ),
      ],
    );
  }

  Widget buildContentWidget(TimelineData data) {
    if (data.type == TimelineType.position) {
      return FinderPlan(image: AssetImage('assets/images/map.png'), markers: [Offset((data.value as PositionData).x, (data.value as PositionData).y)]);
    } else if (data.type == TimelineType.heartbeat) {
      return FinderHealth(beatsPerMinute: data.value as int, bpm: data.value as int,);
    } else {
      return Container();
    }
  } 
}
