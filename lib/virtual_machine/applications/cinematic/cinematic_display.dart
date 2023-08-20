import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hacking_game_ui/virtual_machine/models/cinematic.dart';

class CinematicWidget extends StatefulWidget {
  final Cinematic cinematic;
  final Function onEndCinematic;

  const CinematicWidget(
      {Key? key, required this.cinematic, required this.onEndCinematic})
      : super(key: key);

  @override
  _CinematicWidgetState createState() => _CinematicWidgetState();
}

class _CinematicWidgetState extends State<CinematicWidget> {
  int sequencesIndex = 0;
  int conversationsIndex = 0;

  void initState() {
    super.initState();
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.resumed.toString()) {
        nextSequence();
      }
      return Future.value("");
    });
  }

  void nextSequence() {
    if (sequencesIndex < widget.cinematic.cinematicSequences.length - 1) {
      sequencesIndex++;
      conversationsIndex = 0;
      updateState();
    } else {
      widget.onEndCinematic();
    }
  }

  void nextConversation() {
    if (conversationsIndex <
        widget.cinematic.cinematicSequences[sequencesIndex]
                .cinematicConversations.length -
            1) {
      conversationsIndex++;
      updateState();
    } else {
      nextSequence();
    }
  }

  void updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: nextConversation,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(widget
                .cinematic.cinematicSequences[sequencesIndex].cinematicAsset),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IntrinsicHeight(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.black54,
                constraints: BoxConstraints(minHeight: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.cinematic.cinematicSequences[sequencesIndex]
                          .cinematicConversations[conversationsIndex].character,
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.cinematic.cinematicSequences[sequencesIndex]
                          .cinematicConversations[conversationsIndex].text,
                      style: TextStyle(fontSize: 18, color: Colors.white),
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
}
