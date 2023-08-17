import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder_image.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder_scrollable.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder_text.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder_timeline.dart';
import 'package:hacking_game_ui/virtual_machine/models/scrollable_data.dart';
import 'package:hacking_game_ui/virtual_machine/models/timeline_data.dart';
import 'package:hacking_game_ui/virtual_machine/providers/files_providers.dart';
import 'package:macos_ui/macos_ui.dart';

import '../models/directory_and_files.dart';

class FinderApplication extends StatefulWidget {
  final Directory rootDirectory;
  final FilesProvider filesProvider;
  const FinderApplication(
      {super.key, required this.rootDirectory, required this.filesProvider});

  @override
  State<FinderApplication> createState() => _FinderApplicationState();
}

class _FinderApplicationState extends State<FinderApplication> {
  Directory? _currentDirectory;
  Files? _currentFile;

  @override
  void initState() {
    super.initState();
    _currentDirectory = widget.rootDirectory;
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        alignment: Alignment.centerLeft,
        actions: buildActions(),
      ),
      children: [
        ResizablePane(
          minSize: 180,
          startSize: 200,
          windowBreakpoint: 700,
          resizableSide: ResizableSide.right,
          builder: (_, __) {
            return buildFavorites(widget.rootDirectory);
          },
        ),
        ContentArea(
          builder: (_, __) {
            return Column(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    child: _currentFile == null
                        ? buildFoldersAndFiles(_currentDirectory)
                        : buildDisplayFile(),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  List<ToolbarItem>? buildActions() {
    List<ToolbarItem> actions = [];
    if (_currentDirectory?.parent != null) {
      actions.add(ToolBarIconButton(
        icon: const MacosIcon(
          CupertinoIcons.back,
        ),
        onPressed: () {
          setState(() {
            _currentDirectory = _currentDirectory!.parent;
          });
        },
        label: 'Go back',
        showLabel: true,
        tooltipMessage: 'Go back',
      ));
    }
    if (_currentFile?.parent != null) {
      actions.add(ToolBarIconButton(
        icon: const MacosIcon(
          CupertinoIcons.check_mark,
        ),
        onPressed: () {
          setState(() {
            _currentFile = null;
          });
        },
        label: 'Close',
        showLabel: true,
        tooltipMessage: 'Close',
      ));
    }
    return actions;
  }

  Widget buildDisplayFile() {
    if (_currentFile == null) {
      return Container();
    }
    if (_currentFile!.type == FileType.image) {
      return FinderImage(currentFile: _currentFile);
    }
    if (_currentFile!.type == FileType.text) {
      return FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FinderText(
                snapshot.data.toString(),
              );
            }
            return Center(child: CircularProgressIndicator());
          },
          future: widget.filesProvider.getTextContent(_currentFile!));
    }
    if (_currentFile!.type == FileType.timeline) {
      return FutureBuilder<List<TimelineData>>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FinderTimeline(timelines: snapshot.data!);
            }
            return Center(child: CircularProgressIndicator());
          },
          future: widget.filesProvider.getTimelineData(_currentFile!));
    }
    if (_currentFile!.type == FileType.scrollable) {
      return FutureBuilder<List<ScrollableData>>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FinderScrollable(dataList: snapshot.data!);
            }
            return Center(child: CircularProgressIndicator());
          },
          future: widget.filesProvider.getScrollableData(_currentFile!));
    }
    return Center(
      child: Text(_currentFile!.name),
    );
  }

  Widget buildFoldersAndFiles(Directory? currentDirectory) {
    List<Widget> allItems = [];

    if (currentDirectory == null) {
      return Container();
    }

    allItems.addAll(currentDirectory.subdirectories.map((dir) {
      return buildDirectory(dir, currentDirectory);
    }).toList());

    allItems
        .addAll(currentDirectory.files.map((file) => buildFile(file)).toList());

    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: allItems,
        ),
      ),
    );
  }

  Widget buildFile(Files file) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _currentFile = file),
            child: Container(
              width: 80,
              height: 90,
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Icon(
                      getIconByType(file.type),
                      size: 36,
                      color: getColorByType(file.type),
                    ),
                    SizedBox(height: 8),
                    Text(
                      file.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData getIconByType(FileType type) {
    switch (type) {
      case FileType.timeline:
        return CupertinoIcons.doc_chart;
      case FileType.image:
        return CupertinoIcons.photo;
      case FileType.scrollable:
        return CupertinoIcons.switch_camera_solid;
      case FileType.text:
        return CupertinoIcons.pencil;
      default:
        return CupertinoIcons.question;
    }
  }

  Color getColorByType(FileType type) {
    switch (type) {
      case FileType.timeline:
        return CupertinoColors.systemGreen;
      case FileType.image:
        return CupertinoColors.activeOrange;
      case FileType.scrollable:
        return CupertinoColors.systemRed;
      case FileType.text:
        return CupertinoColors.activeBlue;
      default:
        return CupertinoColors.black;
    }
  }

  Widget buildDirectory(Directory dir, Directory currentDirectory) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _currentDirectory = dir),
            child: Container(
              width: 80,
              height: 90,
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder,
                      size: 36,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 8),
                    Text(
                      dir.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int favoritePageIndex = 0;

  Widget buildFavorites(Directory rootDirectory) {
    List<SidebarItem> items = [
      SidebarItem(
        leading: Icon(
          Icons.home,
          color: favoritePageIndex == 0 ? Colors.white : Colors.black,
        ),
        label: Text('Root'),
      ),
    ];
    for (var i = 0; i < rootDirectory.subdirectories.length; i++) {
      items.add(SidebarItem(
        leading: Icon(
          Icons.folder,
          color: favoritePageIndex == i + 1 ? Colors.white : Colors.black,
        ),
        label: Text(rootDirectory.subdirectories[i].name),
      ));
    }

    return SidebarItems(
        items: items,
        currentIndex: favoritePageIndex,
        onChanged: (index) {
          setState(() {
            if (index == 0) {
              _currentDirectory = rootDirectory;
            } else {
              _currentDirectory = rootDirectory.subdirectories[index - 1];
            }
            _currentFile = null;
            favoritePageIndex = index;
          });
        });
  }
}
