import 'package:flutter/material.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/utils/game_date.dart';
import 'package:hacking_game_ui/virtual_machine/applications/cinematic/cinematic_display.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder.dart';
import 'package:hacking_game_ui/virtual_machine/applications/phone/virtual_phone.dart';
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

  final List<VirtualApplication> applications = [
    VirtualApplication('Finder', Icons.file_copy, Colors.blue),
    VirtualApplication('Messages', Icons.message, Colors.green),
    VirtualApplication('Cinematic', Icons.movie, Colors.purple),
    VirtualApplication('Phones', Icons.phone, Colors.greenAccent),
    VirtualApplication('Next', Icons.skip_next, Colors.orangeAccent),
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
                if (snapshot.hasData)
                  return Text(
                      'Week ${_maestroState!.week} - ${snapshot.data} ${_maestroState!.hour}:00');
                else
                  return Container();
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
            future: widget.maestro.getFilesProvider().getDirectory("/"),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return FinderApplication(
                    rootDirectory: snapshot.data!,
                    filesProvider: widget.maestro.getFilesProvider());
              } else {
                return Container(child: Text('Loading...'));
              }
            });
      case 'Messages':
        return FutureBuilder<Directory>(
            future: widget.maestro.getFilesProvider().getDirectory("/"),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return FinderApplication(
                    rootDirectory: snapshot.data!,
                    filesProvider: widget.maestro.getFilesProvider());
              } else {
                return Container(child: Text('Loading...'));
              }
            });
      case 'Phones':
        return FutureBuilder<List<Files>>(
            future: widget.maestro.getPhoneEvidences('1'),
            builder: (context, evidences) {
              if (evidences.hasData) {
                return FutureBuilder<String>(
                  future: getDayOfWeek(_maestroState!.day),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    return IPhoneFrame(
                      maestro: widget.maestro,
                      characterName: "John Doe",
                      files: evidences.data!,
                      currentDay: snapshot.data!,
                      currentHour: "${_maestroState!.hour}:00",
                      backgroundImageUrl: "assets/iphone.jpg",
                      splashScreenImageUrl: "assets/images/avatar.jpeg",
                    );
                  }
                );
              } else {
                return Container(child: Text('Loading...'));
              }
            });
      case 'Cinematic':
        setState(() {
          isCinematicPlaying = true;
        });
        return FutureBuilder<Cinematic>(
            future: widget.maestro.getCinematicProvider().getCinematicData(""),
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
      decoration: BoxDecoration(
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
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: GestureDetector(
                  onTap: () async {
                    if (applications[index].name == 'Next') {
                      if (!await widget.maestro.nextHour()) {
                        // TODO : Display a cinematic to show that the user need to discover more evidences
                      }
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
            padding: EdgeInsets.symmetric(
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
      ],
    );
  }
}
