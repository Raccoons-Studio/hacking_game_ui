import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/utils/image_code.dart';
import 'package:hacking_game_ui/virtual_machine/models/cinematic.dart';

class CinematicWidget extends StatefulWidget {
  final Cinematic cinematic;
  final Function onEndCinematic;
  final Maestro maestro;

  const CinematicWidget(
      {Key? key, required this.cinematic, required this.onEndCinematic, required this.maestro})
      : super(key: key);

  @override
  _CinematicWidgetState createState() => _CinematicWidgetState();
}

class _CinematicWidgetState extends State<CinematicWidget>
    with SingleTickerProviderStateMixin {
  int sequencesIndex = 0;
  int conversationsIndex = 0;
  late final AnimationController _controller;
  bool showConversation = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      value: 1.0,
    );
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.resumed.toString()) {
        nextSequence();
      }
      return Future.value("");
    });
    scheduleMicrotask(() {
      for (var img in widget.cinematic.cinematicSequences) {
        precacheImage(
            AssetImage("images/${img.cinematicAsset}"), context);
      }
    });
  }

  void nextSequence() {
    if (sequencesIndex < widget.cinematic.cinematicSequences.length - 1) {
      showConversation = false;
      updateState();
    } else {
      widget.onEndCinematic();
    }
  }

  void nextConversation() {
    if (showConversation) {
      if (conversationsIndex <
          widget.cinematic.cinematicSequences[sequencesIndex]
                  .cinematicConversations.length -
              1) {
        conversationsIndex++;
        updateState();
      } else {
        nextSequence();
      }
    } else {
      sequencesIndex++;
      conversationsIndex = 0;
      _controller.reset();
      _controller.forward();
      showConversation = true;
      updateState();
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
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: nextConversation,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
              child: Container(
            color: Colors.black,
          )),
          Positioned.fill(
            child: ImageWithCode(
              "images/${widget.cinematic.cinematicSequences[sequencesIndex > 0 ? sequencesIndex - 1 : 0].cinematicAsset}",
              code: widget.maestro.getPrefixCode(),
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                print(exception);
                // Vérifiez si cinematic.cinematicDescription n'est pas nulle
                if (widget.cinematic.cinematicSequences[sequencesIndex]
                            .cinematicDescription !=
                        null &&
                    widget.cinematic.cinematicSequences[sequencesIndex]
                        .cinematicDescription!.isNotEmpty) {
                  // Affichez la cinematicDescription au milieu de l'écran sur fond noir
                  return Center(
                    child: Container(
                      color: Colors.black,
                      child: Text(
                        widget.cinematic.cinematicSequences[sequencesIndex]
                            .cinematicDescription!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                } else {
                  // Si aucune description n'est disponible, affichez un texte par défaut
                  return Center(
                    child: Container(
                      color: Colors.black,
                      child: Text(
                        'Error loading image.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Positioned.fill(
            child: FadeTransition(
                opacity: _controller,
                child: ImageWithCode(
                  "images/${widget.cinematic.cinematicSequences[sequencesIndex].cinematicAsset}",
                  code: widget.maestro.getPrefixCode(),
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    // Vérifiez si cinematic.cinematicDescription n'est pas nulle
                    if (widget.cinematic.cinematicSequences[sequencesIndex]
                                .cinematicDescription !=
                            null &&
                        widget.cinematic.cinematicSequences[sequencesIndex]
                            .cinematicDescription!.isNotEmpty) {
                      // Affichez la cinematicDescription au milieu de l'écran sur fond noir
                      return Center(
                        child: Container(
                          color: Colors.black,
                          child: Text(
                            widget.cinematic.cinematicSequences[sequencesIndex]
                                .cinematicDescription!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Si aucune description n'est disponible, affichez un texte par défaut
                      return Center(
                        child: Container(
                          color: Colors.black,
                          child: Text(
                            'Error loading image.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                )),
          ),
          Positioned(
            top: 10.0,
            right: 10.0,
            child: GestureDetector(
              onTap: () {
                widget.onEndCinematic();
              },
              child: const Text(
                "Skip",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
          if (showConversation)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IntrinsicHeight(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.black54,
                  constraints: const BoxConstraints(minHeight: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget
                            .cinematic
                            .cinematicSequences[sequencesIndex]
                            .cinematicConversations[conversationsIndex]
                            .character,
                        style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.cinematic.cinematicSequences[sequencesIndex]
                            .cinematicConversations[conversationsIndex].text,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
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
