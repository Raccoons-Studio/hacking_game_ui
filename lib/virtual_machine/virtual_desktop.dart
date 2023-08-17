import 'package:flutter/material.dart';
import 'package:hacking_game_ui/virtual_machine/models/application.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder.dart';
import 'package:hacking_game_ui/virtual_machine/models/directory_and_files.dart';
import 'package:hacking_game_ui/virtual_machine/providers/mocks/files_provider_mock.dart';
import 'package:hacking_game_ui/virtual_machine/virtual_desktop_icon.dart';

class MacOSDesktop extends StatefulWidget {
  @override
  State<MacOSDesktop> createState() => _MacOSDesktopState();
}

class _MacOSDesktopState extends State<MacOSDesktop> {
  VirtualApplication? _currentApplication;

  final List<VirtualApplication> applications = [
    VirtualApplication('Finder', Icons.file_copy, Colors.blue),
    VirtualApplication('Messages', Icons.message, Colors.green),
    // Add more applications here
  ];

  AppBar buildAppBar() {
    return AppBar(
      title: Text('My Mac OS Toolbar'),
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
            future: FilesProviderMock().getDirectory("/"),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return FinderApplication(rootDirectory: snapshot.data!, filesProvider: FilesProviderMock());
              } else {
                return Container(child: Text('Loading...'));
              }
            });
      case 'Messages':
        return FutureBuilder<Directory>(
            future: FilesProviderMock().getDirectory("/"),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return FinderApplication(rootDirectory: snapshot.data!, filesProvider: FilesProviderMock());
              } else {
                return Container(child: Text('Loading...'));
              }
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
                  onTap: () {
                    setState(() {
                      if (_currentApplication == applications[index]) {
                        _currentApplication = null;
                        return;
                      } else {
                        _currentApplication = applications[index];
                      }
                    });
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
              buildApplicationList(applications),
            ],
          ),
        ),
      ],
    );
  }
}
