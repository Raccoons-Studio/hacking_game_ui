import 'package:flutter/material.dart';
import 'package:hacking_game_ui/virtual_machine/models/scrollable_data.dart';

class FinderScrollable extends StatefulWidget {
  final List<ScrollableData> dataList;

  const FinderScrollable({super.key, required this.dataList});

  @override
  State<FinderScrollable> createState() => _FinderScrollableState();
}

class _FinderScrollableState extends State<FinderScrollable> {
  @override
  Widget build(BuildContext context) {
    widget.dataList.sort((a, b) {
      return a.week.compareTo(b.week) == 0
          ? (a.day.compareTo(b.day) == 0
              ? a.hour.compareTo(b.hour)
              : a.day.compareTo(b.day))
          : a.week.compareTo(b.week);
    });

    return ListView.builder(
      itemCount: widget.dataList.length,
      itemBuilder: (context, index) {
        return Card(
            child: Stack(children: <Widget>[
          ListTile(
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: buildContent(index),
            ),
            subtitle: Text(
              widget.dataList[index].subcontent,
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Week: ${widget.dataList[index].week}, Day: ${widget.dataList[index].day}, Hour: ${widget.dataList[index].hour}',
                style: const TextStyle(fontSize: 12.0),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Text(
                    widget.dataList[index].isMarkedAsEvidence
                        ? 'Added to evidences'
                        : 'Add to evidences',
                    style: const TextStyle(fontSize: 12.0),
                  ),
                  Switch(
                    value: widget.dataList[index].isMarkedAsEvidence,
                    onChanged: (value) {
                      setState(() {
                        widget.dataList[index].isMarkedAsEvidence = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ]));
      },
    );
  }

  Widget buildContent(int index) {
    if (widget.dataList[index].type == ScrollableType.socialMedia) {
      // Display the image fitting the screen
      return Image.asset(
        widget.dataList[index].content,
        height: 200,
        fit: BoxFit.fitHeight,
      );
    }
    return Text(
      widget.dataList[index].content,
      textAlign: TextAlign.center,
    );
  }
}
