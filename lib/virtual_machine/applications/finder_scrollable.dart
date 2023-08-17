import 'package:flutter/material.dart';
import 'package:hacking_game_ui/virtual_machine/models/scrollable_data.dart';

class FinderScrollable extends StatelessWidget {
  final List<ScrollableData> dataList;

  FinderScrollable({required this.dataList});

  @override
  Widget build(BuildContext context) {
    dataList.sort((a, b) {
      return a.week.compareTo(b.week) == 0
          ? (a.day.compareTo(b.day) == 0
              ? a.hour.compareTo(b.hour)
              : a.day.compareTo(b.day))
          : a.week.compareTo(b.week);
    });

    return ListView.builder(
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        return Card(
            child: Stack(children: <Widget>[
          ListTile(
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Text(
                dataList[index].content,
                textAlign: TextAlign.center,
              ),
            ),
            subtitle: Text(
              dataList[index].subcontent,
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Week: ${dataList[index].week}, Day: ${dataList[index].day}, Hour: ${dataList[index].hour}',
                style: TextStyle(fontSize: 12.0),
              ),
            ),
          ),
        ]));
      },
    );
  }
}
