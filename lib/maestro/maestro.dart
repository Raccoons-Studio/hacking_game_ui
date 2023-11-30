// Maestro manage everything in the app
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/engine/player_engine.dart';
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
  bool isBlackmail = false;
  String caseID = '';
  String cinematicID = '';
}

enum IntegrityErrorType {
  dupplicateID,
  unexistingPlace,
  unexistingCase,
  unexistingAsset,
  unexistingCharacter
}

enum NextHourExceptionType {
  GoOn,
  endOfStory,
  needToCollectEvidence,
  needToCollectConversation,
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

  Future<NextHourExceptionType> nextHour(bool devMode, bool increment);

  Future<List<Files>> getPhoneEvidences(String characterID);

  Future<void> collectEvidence(String evidenceID);

  Future<void> collectConversation(String conversationID);

  Future<void> collectEvidencesByType(EvidenceType type);

  Future<void> addToEvidence(String characterID, String evidenceID);

  Future<void> removeFromEvidence(String characterID, String evidenceID);

  Future<void> submitEvidences(String characterID);

  Future<void> load(Player? p);

  Future<bool> save(int slot);

  Future<List<Character>> getAvailableCharacters();

  Future<List<Character>> getAllCharacters();

  Future<Cinematic> getCinematicData(String cinematicID);

  Future<Directory> getDirectory(String path);

  Future<String> getAssetContent(Files file);

  Future<String> getTextContent(Files file);

  Future<int> getNumberContent(Files file);

  Future<List<TimelineData>> getTimelineData(EvidenceType type);

  Future<TimelineData> getSingleTimelineData(Files file);

  Future<List<ScrollableData>> getScrollableData(EvidenceType type);

  Future<Map<String, List<ConversationData>>> getConversations();

  Future<List<CharacterEngine>> getContacts();

  static Future<List<IntegrityError>> checkIntegrity(StoryEngine story) async {
    var errors = <IntegrityError>[];

    errors.addAll(_checkForDuplicateIDs(story.characters, 'Character'));
    errors.addAll(_checkForDuplicateIDs(story.places, 'Place'));
    errors.addAll(_checkForDuplicateIDs(story.elements, 'Element'));
    errors.addAll(_checkForDuplicateIDs(story.cases, 'Case'));
    errors.addAll(_checkForDuplicateIDs(story.cinematics, 'Cinematic'));

    errors.addAll(
        _checkPlaceIDExistence(story.elements, story.places, 'Element'));

    errors.addAll(await _checkAssetFileExistence(story.elements, 'Element'));

    errors.addAll(
        await _checkCinematicAssetExistence(story.cinematics, 'Cinematic'));

    errors.addAll(await _checkAssetFileExistence(story.elements, 'Element'));

    // TODO : Cases

    return errors;
  }

  static List<IntegrityError> _checkForDuplicateIDs(List list, String type) {
    var errors = <IntegrityError>[];
    var ids = <String>{};
    for (var item in list) {
      if (!ids.add(item.ID)) {
        errors.add(IntegrityError(IntegrityErrorType.dupplicateID, item.ID,
            '$type ID is duplicate', true));
      }
    }
    return errors;
  }

  static List<IntegrityError> _checkPlaceIDExistence(
      List items, List<PlaceEngine> places, String type) {
    var errors = <IntegrityError>[];
    var placeIDs = places.map((place) => place.ID).toSet();
    for (var item in items) {
      if (item.placeID != null && !placeIDs.contains(item.placeID)) {
        errors.add(IntegrityError(IntegrityErrorType.unexistingPlace, item.ID,
            '$type references nonexistent place : ${item.placeID}', true));
      }
    }
    return errors;
  }

  static Future<List<IntegrityError>> _checkAssetFileExistence(
      List items, String type) async {
    var errors = <IntegrityError>[];
    for (var item in items) {
      if (item.assetID != null) {
        var assetPath = 'images/${item.assetID}';
        try {
          await rootBundle.load(assetPath);
        } catch (e) {
          errors.add(IntegrityError(IntegrityErrorType.unexistingAsset, item.ID,
              "$type references nonexistent asset (${item.assetID})", true));
        }
      }
    }
    return errors;
  }

  static Future<List<IntegrityError>> _checkCinematicAssetExistence(
      List<CinematicEngine> cinematics, String type) async {
    var errors = <IntegrityError>[];
    for (var cinematic in cinematics) {
      for (var sequence in cinematic.sequences) {
        var assetPath = 'images/${sequence.cinematicAsset}';
        try {
          await rootBundle.load(assetPath);
        } catch (e) {
          errors.add(IntegrityError(
              IntegrityErrorType.unexistingAsset,
              cinematic.ID,
              "$type references nonexistent asset (${sequence.cinematicAsset})",
              true));
        }
      }
    }
    return errors;
  }

  static Future<List<IntegrityError>> _checkCharacterIDExistence(
      List items, List<CharacterEngine> characters, String type) async {
    var errors = <IntegrityError>[];
    var characterIDs = characters.map((c) => c.ID).toSet();
    for (var item in items) {
      if (item.characterID != null &&
          !characterIDs.contains(item.characterID)) {
        errors.add(IntegrityError(IntegrityErrorType.unexistingCharacter,
            item.ID, '$type references nonexistent character', true));
      }
    }
    return errors;
  }

  Future<StoryEngine> getStory();

  Future<Player> getPlayer();

  Future<void> goTo(int week, int day, int hour);

  Future<bool> isMessagesNow() async {
    var conversations = await getConversations();
    return conversations.values
        .any((conversation) => conversation.any((c) => c.isNow));
  }

  Future<bool> isEvidenceNow(EvidenceType evidence) async {
    var evidences = await getAllCurrentEvidence();
    return evidences.any((e) => e.type == evidence);
  }

  Future<List<Files>> getAllCurrentEvidence();

  Future<bool> isElementsToDisplay() async {
    var evidences = await getAllCurrentEvidence();
    if (evidences.isNotEmpty) {
      return true;
    }
    return await isMessagesNow();
  }

  List<TimeLine> createTimeLines(StoryEngine story) {
    Map<String, TimeLine> timeLinesMap = {};

    // Helper function to generate a map key for each timeline.
    String generateTimeLineKey(int week, int day, int hour) =>
        'week_$week-day_$day-hour_$hour';

    for (var element in story.elements) {
      var key = generateTimeLineKey(element.week, element.day, element.hour);
      timeLinesMap.putIfAbsent(
          key,
          () => TimeLine(
                element.week,
                element.day,
                element.hour,
                [],
                [],
                [],
              ));
      timeLinesMap[key]!.elements.add(element);
    }

    for (var cinematic in story.cinematics) {
      var key =
          generateTimeLineKey(cinematic.week, cinematic.day, cinematic.hour);
      timeLinesMap.putIfAbsent(
          key,
          () => TimeLine(
                cinematic.week,
                cinematic.day,
                cinematic.hour,
                [],
                [],
                [],
              ));
      timeLinesMap[key]!.cinematics.add(cinematic);
    }

    // Note: Without the definition of ConversationEngine, the following loop
    // assumes that it has week, day, and hour attributes like CinematicEngine.
    // Otherwise, adjust it accordingly.
    for (var conversation in story.conversations) {
      var key = generateTimeLineKey(
          conversation.week, conversation.day, conversation.hour);
      timeLinesMap.putIfAbsent(
          key,
          () => TimeLine(
                conversation.week,
                conversation.day,
                conversation.hour,
                [],
                [],
                [],
              ));
      timeLinesMap[key]!.conversations.add(conversation);
    }

    // Convert the map to a list of timelines and sort it.
    List<TimeLine> timeLines = timeLinesMap.values.toList();

    // Sort based on week, day, and then hour.
    timeLines.sort((a, b) {
      int weekComparison = a.week.compareTo(b.week);
      if (weekComparison != 0) return weekComparison;
      int dayComparison = a.day.compareTo(b.day);
      if (dayComparison != 0) return dayComparison;
      return a.hour.compareTo(b.hour);
    });

    return timeLines;
  }

  Future<bool> addCode(String code);

  Future<List<Code>> getCodes();

  Future<bool> checkCodeAvailability();

  Code? getPrefixCode();

  Future<List<String>> getPlayerCodes();

  Future<void> removeCode(String codeStr);

  Future<String> getPatreonCode();
}
