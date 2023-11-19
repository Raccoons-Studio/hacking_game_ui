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
  int _selectedTab = 0;

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
        color: Colors.black,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Container(
                  color: Colors.black,
                  height: 50,
                  child: Center(
                      child: Text('Single Fans',
                          style:
                              TextStyle(color: Colors.white, fontSize: 20)))),
              // Main Area
              Expanded(
                  child: FutureBuilder(
                      future: _datas,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasData) {
                          List<ScrollableData> dataList = snapshot.data[1]!;

                          if (_selectedTab == 0) {
                            // Feed
                            return buildFeed(dataList);
                          } else if (_selectedTab == 1) {
                            // Models
                            return buildModels(dataList);
                          } else if (_selectedTab == 2) {
                            // Me
                            return buildMe();
                          } else {
                            return const SizedBox.shrink();
                          }
                        }

                        return const SizedBox.shrink();
                      })),
              // Footer
              Container(
                  color: Colors.black,
                  height: 50,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            icon: Icon(Icons.rss_feed, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _selectedTab = 0;
                              });
                            }),
                        IconButton(
                            icon: Icon(Icons.people, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _selectedTab = 1;
                              });
                            }),
                        IconButton(
                            icon: Icon(Icons.person, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _selectedTab = 2;
                              });
                            }),
                      ]))
            ]));
  }

  Widget buildFeed(List<ScrollableData> dataList) {
    return ListView.builder(
      itemCount: dataList.length,
      reverse: true,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.black,
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(dataList[index].avatar),
                ),
                title: Text(
                  'Week ${dataList[index].week} Day ${dataList[index].day} Hour ${dataList[index].hour}',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  dataList[index].content,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset("images/${dataList[index].asset}"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  dataList[index].subcontent,
                  style: const TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    label: Text('', style: TextStyle(color: Colors.white)),
                    icon: Icon(Icons.thumb_up, color: Colors.white),
                    onPressed: () {/* ... */},
                  ),
                  TextButton.icon(
                    label: Text('', style: TextStyle(color: Colors.white)),
                    icon: Icon(Icons.message, color: Colors.white),
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

  Widget buildModels(List<ScrollableData> dataList) {
    var uniqueContentDataList = [];
    for (var data in dataList) {
      bool isExist = false;
      for (var uniqueData in uniqueContentDataList) {
        if (data.content == uniqueData.content) {
          isExist = true;
          break;
        }
      }
      if (!isExist) {
        uniqueContentDataList.add(data);
      }
    }
    return ListView.builder(
      itemCount: uniqueContentDataList.length,
      itemBuilder: (context, index) {
        String content = dataList[index].content;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(dataList[index].avatar),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(content, style: TextStyle(color: Colors.white)),
              ),
            ),
            TextButton.icon(
              label: Text('', style: TextStyle(color: Colors.white)),
              icon: Icon(Icons.message, color: Colors.white),
              onPressed: () {/* ... */},
            ),
          ],
        );
      },
    );
  }

  Widget buildMe() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Me', style: TextStyle(color: Colors.white, fontSize: 24)),
          SizedBox(height: 20),
          CircleAvatar(
            backgroundImage: AssetImage(
                'images/avatar.png'), // Replace this with actual avatar
            radius: 50,
          ),
          SizedBox(height: 20),
          Text('1 subscription',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          SizedBox(height: 20),
          Text('2000 \$', style: TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }
}
