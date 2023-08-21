import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/utils/game_icons.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_chat.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_image.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_scrollable.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_text.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_timeline.dart';
import 'package:hacking_game_ui/virtual_machine/models/conversation_data.dart';
import 'package:hacking_game_ui/virtual_machine/models/directory_and_files.dart';
import 'package:hacking_game_ui/virtual_machine/models/scrollable_data.dart';
import 'package:hacking_game_ui/virtual_machine/models/timeline_data.dart';
import 'package:macos_ui/macos_ui.dart';

class FinderApplication extends StatefulWidget {
  final Maestro maestro;
  final Directory rootDirectory;
  const FinderApplication(
      {super.key, required this.rootDirectory, required this.maestro});

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
            return Container(
              child: Column(
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
              ),
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
    if (_currentFile!.type == EvidenceType.image) {
      return FutureBuilder<String>(
          future: widget.maestro.getAssetContent(_currentFile!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FinderImage(assetName: snapshot.data!);
            }
            return const Center(child: CircularProgressIndicator());
          });
    }
    if (_currentFile!.type == EvidenceType.text) {
      return FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FinderText(
                snapshot.data.toString(),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
          future: widget.maestro.getTextContent(_currentFile!));
    }
    if (_currentFile!.type == EvidenceType.position ||
        _currentFile!.type == EvidenceType.heartbeat) {
      return FutureBuilder<List<TimelineData>>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FinderTimeline(timelines: snapshot.data!);
            }
            return const Center(child: CircularProgressIndicator());
          },
          future: widget.maestro.getTimelineData(_currentFile!));
    }
    if (_currentFile!.type == EvidenceType.socialMedia ||
        _currentFile!.type == EvidenceType.calendar ||
        _currentFile!.type == EvidenceType.note) {
      return FutureBuilder<List<ScrollableData>>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FinderScrollable(dataList: snapshot.data!);
            }
            return const Center(child: CircularProgressIndicator());
          },
          future: widget.maestro.getScrollableData(_currentFile!));
    }
    if (_currentFile!.type == EvidenceType.message ||
        _currentFile!.type == EvidenceType.call) {
      return FutureBuilder<Map<String, List<ConversationData>>>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FinderChat(conversations: snapshot.data!);
            }
            return const Center(child: CircularProgressIndicator());
          },
          future: widget.maestro.getConversations());
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
      child: Stack(
        children: [
          Column(
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
                        const SizedBox(height: 8),
                        Text(
                          file.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (file.isMarkedAsEvidence)
            Positioned(
              top: 0,
              right: 0,
              child: Transform.rotate(
                angle: pi / 4,
                child: const Icon(
                  Icons.push_pin,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
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
                    const Icon(
                      Icons.folder,
                      size: 36,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dir.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
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
        label: const Text('Root'),
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
