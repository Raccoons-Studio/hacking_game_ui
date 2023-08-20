// Maestro manage everything in the app
import 'dart:async';

import 'package:hacking_game_ui/providers/cinematic_providers.dart';
import 'package:hacking_game_ui/providers/files_providers.dart';
import 'package:hacking_game_ui/virtual_machine/applications/phone/phone_characters_selector.dart';
import 'package:hacking_game_ui/virtual_machine/models/directory_and_files.dart';

class MaestroState {
  int hour = 0;
  int day = 0;
  int week = 0;
  bool isCinematic = false;
  String cinematidID = '';
}

abstract class Maestro {
  StreamController<MaestroState> streamController = StreamController<MaestroState>.broadcast();

  Stream<MaestroState> get maestroStream => streamController.stream;

  Future<void> start();

  Future<bool> nextHour();

  Future<List<Files>> getPhoneEvidences(String characterID);

  Future<Files> collectEvidence(String characterID, String evidenceID);

  Future<void> addToEvidence(String characterID, String evidenceID);

  Future<void> removeFromEvidence(String characterID, String evidenceID);
  
  Future<void> submitEvidences(String characterID);

  Future<void> load(String saveID);

  Future<void> save();

  Future<List<Character>> getAvailableCharacters();

  Future<int> getAllCharacters();

  CinematicProvider getCinematicProvider();

  FilesProvider getFilesProvider();
}