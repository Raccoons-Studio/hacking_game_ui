import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/utils/game_date.dart';
import 'package:hacking_game_ui/virtual_machine/applications/cinematic/cinematic_display.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder.dart';
import 'package:hacking_game_ui/virtual_machine/applications/phone/phone_characters_selector.dart';
import 'package:hacking_game_ui/virtual_machine/models/application.dart';
import 'package:hacking_game_ui/virtual_machine/models/cinematic.dart';
import 'package:hacking_game_ui/virtual_machine/models/directory_and_files.dart';
import 'package:hacking_game_ui/virtual_machine/virtual_desktop_icon.dart';

class MacOSDesktop extends StatefulWidget {
  final Maestro maestro;

  const MacOSDesktop({Key? key, required this.maestro}) : super(key: key);

  @override
  State<MacOSDesktop> createState() => _MacOSDesktopState();
}

class _MacOSDesktopState extends State<MacOSDesktop> {
  VirtualApplication? _currentApplication;
  MaestroState? _maestroState;
  bool isCinematicPlaying = false;
  bool isDescriptionVisible = false;
  String descriptionContent = "";

  final List<VirtualApplication> applications = [
    VirtualApplication('Finder', Icons.file_copy, Colors.blue),
    VirtualApplication('Messages', Icons.message, Colors.green),
    //VirtualApplication('Cinematic', Icons.movie, Colors.purple),
    VirtualApplication('Phones', Icons.phone, Colors.greenAccent),
    VirtualApplication('Webcam', Icons.camera_alt, Colors.red),
    VirtualApplication('Settings', Icons.settings, Colors.grey),
    VirtualApplication('Next', Icons.skip_next, Colors.orangeAccent),
    VirtualApplication('Next Dev', Icons.developer_board, Colors.deepOrange),
    // Add more applications here
  ];

  @override
  void initState() {
    super.initState();
    widget.maestro.maestroStream.listen((event) {
      _maestroState = event;
      if (event.isCinematic) {
        setState(() {
          isCinematicPlaying = true;
          _currentApplication =
              VirtualApplication("Cinematic", Icons.movie, Colors.purple);
        });
      } else {
        setState(() {
          isCinematicPlaying = false;
        });
      }
    });
    widget.maestro.start();
  }

  AppBar buildAppBar() {
    return AppBar(
      // If a MaestroState is available, show the current week, day and hour
      title: _maestroState != null
          ? FutureBuilder<String>(
              future: getDayOfWeek(_maestroState!.day),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                      'Week ${_maestroState!.week} - ${snapshot.data} ${_maestroState!.hour}:00');
                } else {
                  return Container();
                }
              })
          : Container(),
      backgroundColor: Colors.grey.shade800.withAlpha(50),
    );
  }

  Widget buildContent() {
    return Expanded(
        child: Container(
      color: Colors.white.withAlpha(50),
      child:
          _currentApplication == null ? Container() : showCurrentApplication(),
    ));
  }

  Widget showCurrentApplication() {
    switch (_currentApplication!.name) {
      case 'Finder':
        return FutureBuilder<Directory>(
            future: widget.maestro.getDirectory("/"),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return FinderApplication(
                    rootDirectory: snapshot.data!, maestro: widget.maestro);
              } else {
                return Container(child: const Text('Loading...'));
              }
            });
      case 'Messages':
        return FutureBuilder<Directory>(
            future: widget.maestro.getDirectory("/"),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return FinderApplication(
                    rootDirectory: snapshot.data!, maestro: widget.maestro);
              } else {
                return Container(child: const Text('Loading...'));
              }
            });
      case 'Phones':
        return FutureBuilder<List<Files>>(
            future: widget.maestro.getPhoneEvidences('1'),
            builder: (context, evidences) {
              if (evidences.hasData) {
                return FutureBuilder<int>(
                    future: widget.maestro.getAllCharacters(),
                    builder: (context, nbCharacters) {
                      if (!nbCharacters.hasData) {
                        return Container();
                      }
                      return FutureBuilder<List<Character>>(
                          future: widget.maestro.getAvailableCharacters(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            return FutureBuilder<String>(
                                future: getDayOfWeek(_maestroState!.day),
                                builder: (context, day) {
                                  if (!day.hasData) {
                                    return Container();
                                  }
                                  return CharacterSelection(
                                    avatars: nbCharacters.data!,
                                    characters: snapshot.data!,
                                    maestro: widget.maestro,
                                    currentDay: day.data!,
                                    currentHour: "${_maestroState!.hour}:00",
                                    displayComment: displayComment,
                                  );
                                });
                          });
                    });
              } else {
                return Container(child: const Text('Loading...'));
              }
            });
      case 'Cinematic':
        setState(() {
          isCinematicPlaying = true;
        });
        return FutureBuilder<Cinematic>(
            future: widget.maestro.getCinematicData(_maestroState!.cinematidID),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return CinematicWidget(
                  cinematic: snapshot.data!,
                  onEndCinematic: () {
                    setState(() {
                      _currentApplication = null;
                      isCinematicPlaying = false;
                    });
                  });
            });
      default:
        return Container();
    }
  }

  Widget buildApplicationList(List<VirtualApplication> applications) {
    return Container(
      height: 60.0,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(70),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: GestureDetector(
                  onTap: () async {
                    if (applications[index].name == 'Next') {
                      if (!await widget.maestro.nextHour(false)) {
                        displayComment(
                            "I think I need to collect more evidences before going to the next hour");
                      }
                    } if (applications[index].name == 'Next Dev') {
                      await widget.maestro.nextHour(true);
                    } else {
                      setState(() {
                        if (_currentApplication == applications[index]) {
                          _currentApplication = null;
                          return;
                        } else {
                          _currentApplication = applications[index];
                        }
                      });
                    }
                  },
                  child: VirtualDesktopIcon(
                    backgroundColor: applications[index].color,
                    icon: applications[index].icon,
                    tooltip: applications[index].name,
                  ),
                ),
              );
            },
            itemCount: applications.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal:
                    5.0), // Here Padding is added around the ListView to have some inside spacing
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          'assets/wallpaper.jpg',
          fit: BoxFit.fill,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: buildAppBar(),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              buildContent(),
              isCinematicPlaying
                  ? Container()
                  : buildApplicationList(applications),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          child: Visibility(
            visible: isDescriptionVisible,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isDescriptionVisible = false;
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                color: Colors.black54,
                child: Center(
                  child: Text(
                    this.descriptionContent,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void displayComment(String comment) {
    scheduleMicrotask(() {
      setState(() {
        isDescriptionVisible = true;
        descriptionContent = comment;
      });
    });
  }
}
