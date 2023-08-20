import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/utils/game_icons.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_health.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_image.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_plan.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_scrollable.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_text.dart';
import 'package:hacking_game_ui/virtual_machine/applications/phone/phone_chat.dart';
import 'package:hacking_game_ui/virtual_machine/models/conversation_data.dart';
import 'package:hacking_game_ui/virtual_machine/models/directory_and_files.dart';
import 'package:hacking_game_ui/virtual_machine/models/scrollable_data.dart';
import 'package:hacking_game_ui/virtual_machine/models/timeline_data.dart';
import 'package:hacking_game_ui/virtual_machine/virtual_desktop_icon.dart';

class IPhoneFrame extends StatefulWidget {
  final String backgroundImageUrl;
  final String splashScreenImageUrl;
  final String currentDay;
  final String currentHour;
  final List<Files> files;
  final String characterName;
  final Maestro maestro;

  IPhoneFrame(
      {Key? key,
      required this.maestro,
      required this.backgroundImageUrl,
      required this.splashScreenImageUrl,
      required this.currentDay,
      required this.currentHour,
      required this.files,
      required this.characterName})
      : super(key: key);

  @override
  _IPhoneFrameState createState() => _IPhoneFrameState();
}

class _IPhoneFrameState extends State<IPhoneFrame> {
  bool _splashScreenVisible = true;
  Files? _openedFile;

  void _displayApp(Files file) {
    setState(() {
      _openedFile = file;
      _splashScreenVisible = true;
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _splashScreenVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: AspectRatio(
        aspectRatio: 10 / 19.5,
        child: GestureDetector(
          onTap: () {
            if (_splashScreenVisible) {
              setState(() {
                _splashScreenVisible = false;
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.asset(
                  _splashScreenVisible
                      ? widget.splashScreenImageUrl
                      : widget.backgroundImageUrl,
                  fit: BoxFit.cover,
                ),
                if (_openedFile == null || _splashScreenVisible) ...[
                  buildHour(),
                ],
                if (_splashScreenVisible) ...[
                  buildSplashScreen(),
                ],
                if (_openedFile == null && !_splashScreenVisible) ...[
                  buildApplications(),
                ],
                if (_openedFile != null && _splashScreenVisible) ...[
                  buildAppSplashscreen(),
                ],
                if (_openedFile != null && !_splashScreenVisible) ...[
                  buildAppContent(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAppContent() {
    return Container(
      color: CupertinoColors.white,
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    CupertinoIcons.back,
                    color: CupertinoColors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _openedFile = null;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: buildApplicationContent(_openedFile!),
            // You can add your application details here
          ),
        ],
      ),
    );
  }

  Widget buildApplicationContent(Files file) {
    if (file.type == FileType.heartbeat) {
      return FinderHealth(
        bpm: 90,
        beatsPerMinute: 90,
      );
    } else if (file.type == FileType.image) {
      return FutureBuilder<String>(
          future: widget.maestro.getFilesProvider().getAssetContent(file),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FinderImage(assetName: snapshot.data!);
            }
            return Center(child: CircularProgressIndicator());
          });
    } else if (file.type == FileType.call || file.type == FileType.message) {
      return FutureBuilder<Map<String, List<ConversationData>>>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return MobileFinderChat(conversations: snapshot.data!);
            }
            return Center(child: CircularProgressIndicator());
          },
          future: widget.maestro.getFilesProvider().getConversations());
    } else if (file.type == FileType.socialMedia ||
        file.type == FileType.calendar ||
        file.type == FileType.note) {
      return FutureBuilder<List<ScrollableData>>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FinderScrollable(dataList: snapshot.data!);
            }
            return Center(child: CircularProgressIndicator());
          },
          future: widget.maestro.getFilesProvider().getScrollableData(file));
    } else if (file.type == FileType.text) {
      return FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FinderText(
                snapshot.data.toString(),
              );
            }
            return Center(child: CircularProgressIndicator());
          },
          future: widget.maestro.getFilesProvider().getTextContent(file));
    } else if (file.type == FileType.position) {
      return FutureBuilder<List<TimelineData>>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FinderPlan(image: AssetImage('assets/images/map.png'), markers: [Offset((snapshot.data![0].value as PositionData).x, (snapshot.data![0].value as PositionData).y)]);
            }
            return Center(child: CircularProgressIndicator());
          },
          future: widget.maestro.getFilesProvider().getTimelineData(file));
    } else {
      return Container();
    }
  }

  Container buildAppSplashscreen() {
    return Container(
      color: getColorByType(_openedFile!.type),
      child: Center(
        child: Icon(
          getIconByType(_openedFile!.type),
          color: Colors.white,
          size: 100,
        ),
      ),
    );
  }

  Padding buildApplications() {
    return Padding(
      padding: const EdgeInsets.only(top: 130.0),
      child: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20.0),
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0,
        crossAxisCount: 4,
        children: widget.files
            .map(
              (file) => InkWell(
                onTap: () => _displayApp(file),
                child: VirtualDesktopIcon(
                    backgroundColor: getColorByType(file.type),
                    icon: getIconByType(file.type),
                    tooltip: file.type.name),
              ),
            )
            .toList(),
      ),
    );
  }

  Center buildSplashScreen() {
    return Center(
      child: Text(
        "${widget.characterName}'s phone",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w500),
      ),
    );
  }

  Positioned buildHour() {
    return Positioned(
      top: 8.0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            widget.currentDay,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.w500),
          ),
          Text(
            widget.currentHour,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 48.0,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
