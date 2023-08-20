import 'dart:math';

import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/providers/cinematic_providers.dart';
import 'package:hacking_game_ui/providers/files_providers.dart';
import 'package:hacking_game_ui/providers/mocks/cinematic_provider_mock.dart';
import 'package:hacking_game_ui/providers/mocks/files_provider_mock.dart';
import 'package:hacking_game_ui/virtual_machine/applications/phone/phone_characters_selector.dart';
import 'package:hacking_game_ui/virtual_machine/models/directory_and_files.dart';

class MaestroMock extends Maestro {
  MaestroState _state = MaestroState();
  MaestroState _saved = MaestroState();

  MaestroMock() {
    _state.hour = 7;
    _state.day = 0;
    _state.week = 0;
    _state.isCinematic = false;
    _state.cinematidID = '';
    super.streamController.add(_state);
  }

  @override
  Future<void> addToEvidence(String characterID, String evidenceID) {
    // TODO: implement addToEvidence
    throw UnimplementedError();
  }

  @override
  CinematicProvider getCinematicProvider() {
    return CinematicProviderMock();
  }

  @override
  FilesProvider getFilesProvider() {
    return FilesProviderMock();
  }

  @override
  Future<void> load(String saveID) async {
    _state = _saved;
    super.streamController.add(_state);
  }

  @override
  Future<bool> nextHour() async {
    // TODO : Check if every evidences are collected
    // TODO : Check at the end of the day if every evidences are marked
    // TODO : Check at the end of the week if every evidences are submitted
    if (_state.hour >= 22) {
      _state.hour = 7;
      _state.day++;
      if (_state.day == 7) {
        _state.day = 0;
        _state.week++;
      }
    } else {
      _state.hour += 3;
    }
    super.streamController.add(_state);
    return true;
  }

  @override
  Future<void> removeFromEvidence(String characterID, String evidenceID) {
    // TODO: implement removeFromEvidence
    throw UnimplementedError();
  }

  @override
  Future<void> save() async {
    _saved = _state;
  }

  @override
  Future<void> submitEvidences(String characterID) async {
    super.streamController.add(_state);
  }

  @override
  Future<void> start() async {
    super.streamController.add(_state);
  }

  @override
  Future<Files> collectEvidence(String characterID, String evidenceID) {
    // TODO: implement collectEvidence
    throw UnimplementedError();
  }

  @override
  Future<List<Files>> getPhoneEvidences(String characterID) async {
    List<Files> files = [
      Files('File 1', 'Map', FileType.position),
      Files('File_2', 'Gallery', FileType.image),
      Files('File_2', 'Front camera', FileType.frontCamera),
      Files('File_2', 'Rear camera', FileType.rearCamera),
      Files('File_2', 'Deleted files', FileType.deleted),
      Files('File 3', 'Calendar', FileType.calendar),
      Files('File 4', 'Phone', FileType.call, isMarkedAsEvidence: true),
      Files('File 4', 'Microphone', FileType.microphone),
      Files('File 5', 'Health', FileType.heartbeat),
      Files('File 6', 'Message', FileType.message),
      Files('File 7', 'Note', FileType.note),
      Files('File 7', 'Bank', FileType.bank),
      Files('File 8', 'SocialMedia', FileType.socialMedia),
      Files('File 9', 'Text', FileType.text),
      Files('File 10', 'Browser', FileType.webHistory),
    ];
    return files;
  }

  @override
  Future<int> getAllCharacters() async {
    return 12;
  }

  @override
  Future<List<Character>> getAvailableCharacters() async {
    Random random = Random();

    List<Character> characters = List.generate(
      3,
      (index) => Character(
        characterID: 'character-${random.nextInt(1000)}',
        name: 'Character ${random.nextInt(1000)}',
        avatar: 'avatar.jpeg',
      ),
    );

    return characters;
  }
}
