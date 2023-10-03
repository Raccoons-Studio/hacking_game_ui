import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/virtual_machine/models/scrollable_data.dart';

class SingleFans extends StatefulWidget {
  final Maestro maestro;
  final StoryEngine story;

  const SingleFans({Key? key, required this.maestro, required this.story})
      : super(key: key);

  @override
  _SingleFansState createState() => _SingleFansState();
}

class _SingleFansState extends State<SingleFans> {
  Future? _datas;

  @override
  void initState() {
    super.initState();
    _datas = Future.wait([
      widget.maestro.collectEvidencesByType(EvidenceType.socialMedia),
      widget.maestro.getScrollableData(EvidenceType.socialMedia),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.extraLightBackgroundGray,
      child: FutureBuilder(
          future: _datas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData) {
              List<ScrollableData> dataList = snapshot.data[1]!;
              return ListView.builder(
                itemCount: dataList.length,
                reverse: true,
                itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(dataList[index].avatar),
                          ),
                          title: Text(dataList[index].content),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Image.asset(
                              "assets/images/${dataList[index].asset}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            dataList[index].subcontent,
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        ),
                        ButtonBar(
                          children: [
                            TextButton(
                              child: const Text('Like'),
                              onPressed: () {/* ... */},
                            ),
                            TextButton(
                              child: const Text('Share'),
                              onPressed: () {/* ... */},
                            ),
                            TextButton(
                              child: const Text('Contact'),
                              onPressed: () {/* ... */},
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          }),
    );
  }
}
