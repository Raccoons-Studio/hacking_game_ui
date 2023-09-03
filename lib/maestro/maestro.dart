// Maestro manage everything in the app
import 'dart:async';

import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/virtual_machine/applications/phone/phone_characters_selector.dart';
import 'package:hacking_game_ui/virtual_machine/models/cinematic.dart';
import 'package:hacking_game_ui/virtual_machine/models/conversation_data.dart';
import 'package:hacking_game_ui/virtual_machine/models/directory_and_files.dart';
import 'package:hacking_game_ui/virtual_machine/models/scrollable_data.dart';
import 'package:hacking_game_ui/virtual_machine/models/timeline_data.dart';

class MaestroState {
  int hour = 0;
  int day = 0;
  int week = 0;
  bool isCinematic = false;
  String cinematidID = '';
}

enum IntegrityErrorType {
  dupplicateID,
  unexistingPlace,
  unexistingCase,
  unexistingAsset,
  unexistingCharacter
}

class IntegrityError {
  IntegrityErrorType type;
  String elementID;
  String reason;
  bool blocking;

  IntegrityError(this.type, this.elementID, this.reason, this.blocking);
}

class NextDayError {
  String characterID;
  String reason;

  NextDayError(this.characterID, this.reason);
}

abstract class Maestro {
  StreamController<MaestroState> streamController =
      StreamController<MaestroState>.broadcast();

  Stream<MaestroState> get maestroStream => streamController.stream;

  Future<void> start();

  Future<bool> nextHour(bool devMode);

  Future<List<Files>> getPhoneEvidences(String characterID);

  Future<void> collectEvidence(String evidenceID);

  Future<void> addToEvidence(String characterID, String evidenceID);

  Future<void> removeFromEvidence(String characterID, String evidenceID);

  Future<void> submitEvidences(String characterID);

  Future<void> load(String saveID);

  Future<void> save();

  Future<List<Character>> getAvailableCharacters();

  Future<int> getAllCharacters();

  Future<Cinematic> getCinematicData(String cinematicID);

  Future<Directory> getDirectory(String path);

  Future<String> getAssetContent(Files file);

  Future<String> getTextContent(Files file);

  Future<int> getNumberContent(Files file);

  Future<List<TimelineData>> getTimelineData(Files file);

  Future<TimelineData> getSingleTimelineData(Files file);

  Future<List<ScrollableData>> getScrollableData(Files file);

  Future<Map<String, List<ConversationData>>> getConversations();

  Future<List<ContactEngine>> getContacts();

  Future<List<IntegrityError>> checkIntegrity(StoryEngine story);
}
