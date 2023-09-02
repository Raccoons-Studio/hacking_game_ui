import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FinderHealth extends StatefulWidget {
  final int bpm;
  final String hour;
  final int steps;
  final int calories;
  final int exerciseMinutes;

  const FinderHealth({
    Key? key,
    required this.bpm,
    required this.hour,
    required this.steps,
    required this.calories,
    required this.exerciseMinutes,
  }) : super(key: key);

  @override
  _HeartBeatState createState() => _HeartBeatState();
}

class _HeartBeatState extends State<FinderHealth> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.extraLightBackgroundGray,
      child: Column(
        children: [
          Container(
            height: 40,
          ),
          buildCard(
              icon: Icons.favorite,
              iconSize: 24.0,
              title: "${widget.bpm} BPM",
              subTitle: widget.hour,
              color: CupertinoColors.systemPink),
          buildCard(
              icon: Icons.directions_walk,
              iconSize: 24.0,
              title: "${widget.steps} Steps",
              subTitle: widget.hour,
              color: CupertinoColors.activeOrange),
          buildCard(
              icon: Icons.fireplace,
              iconSize: 24.0,
              title: "${widget.calories} Calories Burned",
              subTitle: widget.hour,
              color: CupertinoColors.systemRed),
          buildCard(
              icon: Icons.timer,
              iconSize: 24.0,
              title: "${widget.exerciseMinutes} Exercise Minutes",
              subTitle: widget.hour,
              color: CupertinoColors.systemOrange),
        ],
      ),
    );
  }

  Card buildCard(
      {required IconData icon,
      required double iconSize,
      required String title,
      required String subTitle,
      required Color color}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Container(
        height: 75,
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: iconSize,
              color: color,
            ),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Text(
              subTitle,
              style: const TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
