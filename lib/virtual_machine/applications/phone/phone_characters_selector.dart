import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/virtual_machine/applications/phone/virtual_phone.dart';

import '../../models/directory_and_files.dart';

class Character {
  String characterID;
  String name;
  String avatar;
  String wallpaper;

  Character(
      {required this.characterID, required this.name, required this.avatar, required this.wallpaper});
}

class CharacterSelection extends StatefulWidget {
  final String currentDay;
  final String currentHour;
  final Maestro maestro;
  final List<Character> characters;
  final int avatars;
  final Function(String) displayComment;

  CharacterSelection(
      {super.key,
      required this.maestro,
      required this.characters,
      required this.avatars,
      required this.currentDay,
      required this.currentHour,
      required this.displayComment});

  @override
  _CharacterSelectionState createState() => _CharacterSelectionState();
}

class _CharacterSelectionState extends State<CharacterSelection> {
  bool _selected = false;
  Character? _selectedCharacter;

  void _handleTap(Character character) {
    setState(() {
      _selected = true;
      _selectedCharacter = character;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: _selected
                  ? Center(
                      child: FutureBuilder<List<Files>>(
                          future: widget.maestro.getPhoneEvidences(
                              _selectedCharacter!.characterID),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }
                            return IPhoneFrame(
                              maestro: widget.maestro,
                              characterName: _selectedCharacter!.name,
                              files: snapshot.data!,
                              currentDay: widget.currentDay,
                              currentHour: widget.currentHour,
                              backgroundImageUrl: _selectedCharacter!.wallpaper,
                              splashScreenImageUrl: _selectedCharacter!.wallpaper,
                              displayComment: widget.displayComment,
                            );
                          }))
                  : Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 32.0,
                      runSpacing: 32.0,
                      children: widget.characters
                          .map((character) => Padding(
                                padding: const EdgeInsets.all(16),
                                child: GestureDetector(
                                  onTap: () {
                                    _handleTap(character);
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 50.0,
                                        backgroundImage: AssetImage(
                                            "${character.avatar}"),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(character.name),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList()
                        ..addAll(List.generate(
                          widget.avatars - widget.characters.length,
                          (_) => Padding(
                            padding: const EdgeInsets.all(16),
                            child: GestureDetector(
                              child: const Column(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 50.0,
                                    backgroundColor:
                                        CupertinoColors.lightBackgroundGray,
                                    child: Icon(
                                      Icons.question_mark,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('Unknown phone'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
