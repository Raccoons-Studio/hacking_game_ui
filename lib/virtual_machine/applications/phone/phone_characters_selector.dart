import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/virtual_machine/applications/phone/virtual_phone.dart';

import '../../models/directory_and_files.dart';

class Character {
  String characterID;
  String name;
  String avatar;

  Character(
      {required this.characterID, required this.name, required this.avatar});
}

class CharacterSelection extends StatefulWidget {
  final String currentDay;
  final String currentHour;
  final Maestro maestro;
  final List<Character> characters;
  final int avatars;

  CharacterSelection(
      {required this.maestro,
      required this.characters,
      required this.avatars,
      required this.currentDay,
      required this.currentHour});

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
                              return CircularProgressIndicator();
                            }
                            return IPhoneFrame(
                              maestro: widget.maestro,
                              characterName: _selectedCharacter!.name,
                              files: snapshot.data!,
                              currentDay: widget.currentDay,
                              currentHour: widget.currentHour,
                              backgroundImageUrl: "assets/iphone.jpg",
                              splashScreenImageUrl: "assets/images/avatar.jpeg",
                            );
                          }))
                  : Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 32.0,
                      runSpacing: 32.0,
                      children: widget.characters
                          .map((character) => Padding(
                                padding: EdgeInsets.all(16),
                                child: GestureDetector(
                                  onTap: () {
                                    _handleTap(character);
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 50.0,
                                        backgroundImage: AssetImage(
                                            "assets/images/" +
                                                character.avatar),
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
                            padding: EdgeInsets.all(16),
                            child: GestureDetector(
                              child: Column(
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
                                    padding: const EdgeInsets.only(top: 8.0),
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
