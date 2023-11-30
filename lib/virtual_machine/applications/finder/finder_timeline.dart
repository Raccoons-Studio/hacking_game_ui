import 'package:flutter/material.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_image.dart';
import 'package:hacking_game_ui/virtual_machine/applications/phone/phone_map.dart';
import 'package:hacking_game_ui/virtual_machine/models/timeline_data.dart';

import 'finder_health.dart';

class FinderTimeline extends StatefulWidget {
  final Maestro maestro;
  final Function refreshTitle;
  final List<TimelineData> timelines;

  const FinderTimeline({super.key, required this.timelines, required this.refreshTitle, required this.maestro});

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
          //child: ImageWithMarkers(image: AssetImage('images/map.png'), markers: [Offset(560, 650)],)
          child: buildContentWidget(widget.timelines[_currentPosition]),
        )),
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
    widget.refreshTitle("${data.week}w ${data.day}d ${data.hour}h");
    if (data.type == TimelineType.position) {
      return PhoneMap(
          day: data.day.toString(),
          hour: data.hour.toString(),
          placeName: (data.value as PositionData).name,
          placeAddress: (data.value as PositionData).address,
          placeAsset: (data.value as PositionData).asset);
    } else if (data.type == TimelineType.heartbeat) {
      return FinderHealth(bpm: data.value as int, hour: data.hour.toString(), calories: 345, exerciseMinutes: 23, steps: 4532,);
    } else if (data.type == TimelineType.image) {
      return FinderImage(assetName: data.value as String, maestro: widget.maestro,);
    } else {
      return Container();
    }
  }
}
