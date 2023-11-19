import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/utils/game_icons.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_health.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_image.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_scrollable.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_text.dart';
import 'package:hacking_game_ui/virtual_machine/applications/phone/phone_chat.dart';
import 'package:hacking_game_ui/virtual_machine/applications/phone/phone_map.dart';
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
  final Function(String) displayComment;

  IPhoneFrame(
      {Key? key,
      required this.maestro,
      required this.backgroundImageUrl,
      required this.splashScreenImageUrl,
      required this.currentDay,
      required this.currentHour,
      required this.files,
      required this.characterName,
      required this.displayComment})
      : super(key: key);

  @override
  _IPhoneFrameState createState() => _IPhoneFrameState();
}

class _IPhoneFrameState extends State<IPhoneFrame> {
  bool _splashScreenVisible = true;
  Files? _openedFile;

  void _displayApp(Files file) {
    widget.maestro.collectEvidence(file.evidenceID);
    setState(() {
      _openedFile = file;
      _splashScreenVisible = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (file.description != "") {
        widget.displayComment(file.description);
      }
      setState(() {
        _splashScreenVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
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
                      ? "${widget.splashScreenImageUrl}"
                      : "${widget.backgroundImageUrl}",
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
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Container(
            color: CupertinoColors.white,
            child: buildApplicationContent(_openedFile!),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 25.0,
          child: Container(
            color: CupertinoColors.lightBackgroundGray.withOpacity(0.8),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: IconButton(
                    iconSize: 10,
                    icon: const Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() => _openedFile = null),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(widget.currentHour,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 50.0)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildApplicationContent(Files file) {
    if (file.type == EvidenceType.heartbeat) {
      return FutureBuilder<int>(
          future: widget.maestro.getNumberContent(file),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return FinderHealth(
              bpm: snapshot.data!,
              hour: widget.currentHour,
              calories: 345,
              exerciseMinutes: 23,
              steps: 4532,
            );
          });
    } else if (file.type == EvidenceType.image ||
        file.type == EvidenceType.rearCamera ||
        file.type == EvidenceType.frontCamera) {
      return FutureBuilder<String>(
          future: widget.maestro.getAssetContent(file),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FinderImage(assetName: snapshot.data!);
            }
            return const Center(child: CircularProgressIndicator());
          });
    } else if (file.type == EvidenceType.call ||
        file.type == EvidenceType.message) {
      return FutureBuilder<Map<String, List<ConversationData>>>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return MobileFinderChat(conversations: snapshot.data!);
            }
            return const Center(child: CircularProgressIndicator());
          },
          future: widget.maestro.getConversations());
    } else if (file.type == EvidenceType.socialMedia ||
        file.type == EvidenceType.calendar ||
        file.type == EvidenceType.note) {
      return FutureBuilder<List<ScrollableData>>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FinderScrollable(dataList: snapshot.data!);
            }
            return const Center(child: CircularProgressIndicator());
          },
          future: widget.maestro.getScrollableData(file.type));
    } else if (file.type == EvidenceType.text) {
      return FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FinderText(
                snapshot.data.toString(),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
          future: widget.maestro.getTextContent(file));
    } else if (file.type == EvidenceType.position) {
      return FutureBuilder<TimelineData>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return PhoneMap(
                placeName: (snapshot.data!.value as PositionData).name,
                placeAddress: (snapshot.data!.value as PositionData).address,
                placeAsset: (snapshot.data!.value as PositionData).asset,
                day: widget.currentDay,
                hour: widget.currentHour,
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
          future: widget.maestro.getSingleTimelineData(file));
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
    // Create a list of all available types
    List<EvidenceType> allTypes = EvidenceType.values;

    // Find the types that exist in widget.files
    List<EvidenceType> existingTypes =
        widget.files.map((file) => file.type).toList();

    // Get the types that do not exist in widget.files
    List<EvidenceType> inactiveTypes =
        allTypes.where((type) => !existingTypes.contains(type)).toList();

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
                        label: file.type.name,
                        tooltip: file.type.name),
                  ),
                )
                .toList() +
            inactiveTypes
                .map((type) => InkWell(
                      child: VirtualDesktopIcon(
                          // Generate inactive icons
                          backgroundColor: getColorByType(type)
                              .withOpacity(0.5), // Use semi-transparent color
                          icon: getIconByType(type),
                          label: type.name,
                          tooltip: type.name),
                    ))
                .toList(),
      ),
    );
  }

  Center buildSplashScreen() {
    return Center(
      child: Text(
        "${widget.characterName}'s phone",
        textAlign: TextAlign.center,
        style: const TextStyle(
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
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.w500),
          ),
          Text(
            widget.currentHour,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 48.0,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
