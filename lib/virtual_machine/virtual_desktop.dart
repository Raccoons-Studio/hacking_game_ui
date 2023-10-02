import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/utils/game_date.dart';
import 'package:hacking_game_ui/virtual_machine/applications/cinematic/cinematic_display.dart';
import 'package:hacking_game_ui/virtual_machine/applications/editor/story_editor.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder.dart';
import 'package:hacking_game_ui/virtual_machine/applications/messages/messages_viewer.dart';
import 'package:hacking_game_ui/virtual_machine/applications/parameters/parameters.dart';
import 'package:hacking_game_ui/virtual_machine/applications/phone/phone_characters_selector.dart';
import 'package:hacking_game_ui/virtual_machine/applications/single_fans/single_fans.dart';
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
  bool isBlackmailPlaying = false;
  bool isDescriptionVisible = false;
  bool isDateVisible = false;
  String descriptionContent = "";

  List<VirtualApplication> applications = [
    VirtualApplication('Finder', Icons.file_copy, Colors.blue, false),
    VirtualApplication('Messages', Icons.message, Colors.green, false),
    VirtualApplication('SingleFans', Icons.star_outlined, Colors.black, false),
    //VirtualApplication('Cinematic', Icons.movie, Colors.purple),
    VirtualApplication('Phones', Icons.phone, Colors.greenAccent, true),
    VirtualApplication('Webcam', Icons.camera_alt, Colors.red, false),
    VirtualApplication('Settings', Icons.settings, Colors.grey, false),
    VirtualApplication('Next', Icons.skip_next, Colors.orangeAccent, false),
    // Add more applications here
  ];

  @override
  void initState() {
    super.initState();

    widget.maestro.isMessagesNow().then((bool value) => {
          scheduleMicrotask(() {
            setState(
              () {
                applications
                    .firstWhere((element) => element.name == 'Messages')
                    .isNotification = value;
              },
            );
          })
        });

    widget.maestro.maestroStream.listen((event) {
      if (_maestroState == null || _maestroState!.hour != event.hour) {
        setState(() {
          _currentApplication = null;
          isDateVisible = true;
          widget.maestro.isMessagesNow().then((bool value) => {
                scheduleMicrotask(() {
                  setState(
                    () {
                      applications
                          .firstWhere((element) => element.name == 'Messages',
                              orElse: () => VirtualApplication('Messages',
                                  Icons.message, Colors.green, false))
                          .isNotification = value;
                    },
                  );
                })
              });
        });
      } else {
        if (event.isCinematic) {
          setState(() {
            isCinematicPlaying = true;
            _currentApplication = applications
                .firstWhere((element) => element.name == 'Cinematic');
          });
        } else {
          setState(() {
            isCinematicPlaying = false;
          });
        }

        if (!event.isCinematic && event.isBlackmail) {
          setState(() {
            isBlackmailPlaying = true;
            _currentApplication = applications
                .firstWhere((element) => element.name == 'Messages');
          });
        } else {
          setState(() {
            isBlackmailPlaying = false;
          });
        }
      }
      _maestroState = event;
    });
    widget.maestro.start().then((value) {
      widget.maestro.getStory().then((value) {
        // Filter applications with enabledApplications
        applications = applications
            .where(
                (element) => value.enabledApplications.contains(element.name))
            .toList();

        if (kDebugMode) {
          applications.add(VirtualApplication(
              'Next Dev', Icons.developer_board, Colors.deepOrange, false));
          applications.add(VirtualApplication(
              'Editor', Icons.edit, Colors.deepOrange, false));
        }
      }).onError((error, stackTrace) {
        print(error);
        print(stackTrace);
      });
    });
  }

  AppBar buildAppBar() {
    return AppBar(
      // If a MaestroState is available, show the current week, day and hour
      title: Text(
          'Week ${_maestroState?.week ?? ""} - ${getDayOfWeek(_maestroState?.day ?? 0)} ${_maestroState?.hour ?? ""}:00'),
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
        return FutureBuilder<StoryEngine>(
            future: widget.maestro.getStory(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return MessagesViewer(
                  story: snapshot.data!,
                  maestro: widget.maestro,
                  isBlackMail: _maestroState!.isBlackmail,
                  caseID: _maestroState!.caseID);
            });
      case 'Phones':
        return FutureBuilder<List<Files>>(
            future: widget.maestro.getPhoneEvidences('1'),
            builder: (context, evidences) {
              if (evidences.hasData) {
                return FutureBuilder<List<Character>>(
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

                            return CharacterSelection(
                              avatars: nbCharacters.data!.length,
                              characters: snapshot.data!,
                              maestro: widget.maestro,
                              currentDay: getDayOfWeek(_maestroState!.day),
                              currentHour: "${_maestroState!.hour}:00",
                              displayComment: displayComment,
                            );
                          });
                    });
              } else {
                return Container(child: const Text('Loading...'));
              }
            });
      case 'Editor':
        return FutureBuilder<StoryEngine>(
            future: widget.maestro.getStory(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return StoryEditor(
                  story: snapshot.data!, maestro: widget.maestro);
            });
      case 'SingleFans':
        return FutureBuilder<StoryEngine>(
            future: widget.maestro.getStory(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return SingleFans(story: snapshot.data!, maestro: widget.maestro);
            });
      case 'Settings':
        return FutureBuilder<StoryEngine>(
            future: widget.maestro.getStory(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return Parameters(widget.maestro);
            });
      case 'Cinematic':
        setState(() {
          isCinematicPlaying = true;
        });
        return FutureBuilder<Cinematic>(
            future: widget.maestro.getCinematicData(_maestroState!.cinematicID),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return CinematicWidget(
                  cinematic: snapshot.data!,
                  onEndCinematic: () async {
                    if (!await widget.maestro.isElementsToDisplay()) {
                      widget.maestro.nextHour(false, true);
                    } else {
                      setState(() {
                        _currentApplication = null;
                        isCinematicPlaying = false;
                        if (_maestroState!.isBlackmail) {
                          setState(() {
                            isBlackmailPlaying = true;
                            _currentApplication = applications.firstWhere(
                                (element) => element.name == 'Messages');
                          });
                        }
                      });
                    }
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
                    if (applications[index].name == 'Next' &&
                        !isBlackmailPlaying) {
                      if (!await widget.maestro.nextHour(false, true)) {
                        displayComment(
                            "I think I need to collect more evidences before going to the next hour");
                      }
                    }
                    if (applications[index].name == 'Next Dev' &&
                        !isBlackmailPlaying) {
                      await widget.maestro.nextHour(true, true);
                    } else {
                      setState(() {
                        if (_currentApplication == applications[index] &&
                            !isBlackmailPlaying) {
                          _currentApplication = null;
                          return;
                        } else if (!isBlackmailPlaying) {
                          _currentApplication = applications[index];
                        }
                      });
                    }
                  },
                  child: VirtualDesktopIcon(
                    backgroundColor: applications[index].color,
                    icon: applications[index].icon,
                    tooltip: applications[index].name,
                    isNotification: applications[index].isNotification,
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
          fit: BoxFit.cover,
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
                    descriptionContent,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          bottom: 0,
          child: Visibility(
            visible: isDateVisible,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isDateVisible = false;
                  if (_maestroState!.isCinematic) {
                    setState(() {
                      isCinematicPlaying = true;
                      _currentApplication = VirtualApplication(
                          "Cinematic", Icons.movie, Colors.purple, false);
                    });
                  } else {
                    setState(() {
                      isCinematicPlaying = false;
                    });
                  }
                });
              },
              child: Container(
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      'Week ${_maestroState?.week ?? ""} - ${getDayOfWeek(_maestroState?.day ?? 0)} ${_maestroState?.hour ?? ""}:00',
                      style: const TextStyle(color: Colors.white, fontSize: 30),
                    ),
                  )),
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
