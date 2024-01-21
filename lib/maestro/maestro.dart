// Maestro manage everything in the app
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hacking_game_ui/engine/database_engine.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/engine/player_engine.dart';
import 'package:hacking_game_ui/engine/save_load_engine.dart';
import 'package:hacking_game_ui/maestro/maestro_codes.dart';
import 'package:hacking_game_ui/providers/savegame_service.dart';
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

class Maestro with MaestroCodes {
  DataBaseEngine? _dataBaseEngine;
  StreamController<MaestroState> streamController =
      StreamController<MaestroState>.broadcast();
  Stream<MaestroState> get maestroStream => streamController.stream;

  Future<Map<String, List<ConversationData>>> getConversations() {
    return getPlayer()
        .then((p) => getStory().then((s) => _getConversations(p, s)));
  }

  Future<List<IntegrityError>> checkIntegrity(StoryEngine story) async {
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

  @visibleForTesting
  List<IntegrityError> checkForDuplicateIDs(List list, String type) =>
      _checkForDuplicateIDs(list, type);

  List<IntegrityError> _checkForDuplicateIDs(List list, String type) {
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

  List<IntegrityError> checkPlaceIDExistence(
          List items, List<PlaceEngine> places, String type) =>
      _checkPlaceIDExistence(items, places, type);

  List<IntegrityError> _checkPlaceIDExistence(
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

  Future<List<IntegrityError>> checkAssetFileExistence(
          List items, String type) =>
      _checkAssetFileExistence(items, type);

  Future<List<IntegrityError>> _checkAssetFileExistence(
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

  Future<List<IntegrityError>> _checkCinematicAssetExistence(
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

  Future<List<IntegrityError>> checkCharacterIDExistence(
          List items, List<CharacterEngine> characters, String type) =>
      _checkCharacterIDExistence(items, characters, type);

  Future<List<IntegrityError>> _checkCharacterIDExistence(
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

  Future<bool> isEvidenceNow(EvidenceType evidence) async {
    Player player = await getPlayer();
    StoryEngine story = await getStory();
    return _isEvidenceNow(evidence, player, story);
  }

  @visibleForTesting
  Future<bool> isEvidenceNowTest(
          EvidenceType evidence, Player p, StoryEngine s) =>
      _isEvidenceNow(evidence, p, s);

  Future<bool> _isEvidenceNow(
      EvidenceType evidence, Player p, StoryEngine s) async {
    var evidences = await _getAllCurrentEvidence(p, s);
    return evidences.any((e) => e.type == evidence);
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

  void init(StoryEngine storyEngine, Player playerEngine) {
    _dataBaseEngine = DataBaseEngine(storyEngine, playerEngine);
  }

  Future<void> _addToEvidence(String characterID, String evidenceID) async {
    Player p = await _dataBaseEngine!.getPlayer();
    // Check if the evidence is already in the player's inventory
    if (!p.elementsMarkedAsEvidence.contains(evidenceID)) {
      // If not, add it
      p.elementsMarkedAsEvidence.add(evidenceID);
      await _dataBaseEngine!.savePlayer(p);
    }
  }

  Future<void> collectEvidence(String evidenceID) async {
    Player p = await _dataBaseEngine!.getPlayer();
    p.revealedElements.add(evidenceID);
  }

  Future<List<Character>> getAllCharacters() async {
    StoryEngine p = await _dataBaseEngine!.getStory();
    return p.characters
        .where((element) => element.isPlayable)
        .map((character) => Character(
            characterID: character.ID,
            name: character.name,
            avatar: character.avatar,
            wallpaper: character.wallpaper))
        .toList();
  }

  Future<String> getAssetContent(Files file) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    ElementEngine element =
        s.elements.firstWhere((element) => element.ID == file.evidenceID);
    return element.assetID != null ? element.assetID! : "";
  }

  Future<List<Character>> getAvailableCharacters() async {
    List<Character> characters = [];
    Player p = await _dataBaseEngine!.getPlayer();
    StoryEngine s = await _dataBaseEngine!.getStory();
    for (CharacterEngine c in s.characters) {
      if (p.currentWeek >= c.weekAvailability && c.isPlayable) {
        characters.add(Character(
            characterID: c.ID,
            name: c.name,
            avatar: c.avatar,
            wallpaper: c.wallpaper));
      }
    }
    return characters;
  }

  Future<Cinematic> getCinematicData(String cinematicID) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    CinematicEngine cinematic =
        s.cinematics.firstWhere((cinematic) => cinematic.ID == cinematicID);
    List<CinematicSequence> cinematicSequences = [];
    for (var sequence in cinematic.sequences) {
      List<CinematicConversation> cinematicConversations = [];
      for (var conversation in sequence.cinematicConversations) {
        cinematicConversations.add(
            CinematicConversation(conversation.character, conversation.text));
      }
      cinematicSequences.add(CinematicSequence(
          sequence.cinematicAsset, cinematicConversations,
          cinematicDescription: sequence.cinematicDescription));
    }
    return Cinematic(cinematicID, cinematicSequences,
        cinematicDescription: cinematic.description);
  }

  Future<Map<String, List<ConversationData>>> _getConversations(
      Player p, StoryEngine s) async {
    Map<String, List<ConversationData>> data = {};

    for (var character in s.characters) {
      var charsConv = s.conversations
          .where((c) =>
              c.characterID == character.ID &&
              (c.week < p.currentWeek ||
                  c.week == p.currentWeek &&
                      (c.day < p.currentDay ||
                          c.day == p.currentDay && c.hour <= p.currentHour)))
          .toList();

      charsConv.sort((a, b) => a.week.compareTo(b.week));

      var dataList = charsConv
          .map((conv) => ConversationData(
              conv.characterID,
              _convertDialogues(s, p, conv.characterID, conv.conversation),
              conv.week,
              conv.day,
              conv.hour,
              isNow: conv.week == p.currentWeek &&
                  conv.day == p.currentDay &&
                  conv.hour == p.currentHour))
          .toList();

      for (var solvedCase in p.solvedCases) {
        var caseEngine = s.cases.firstWhere((ce) => ce.ID == solvedCase);
        var caseConv = caseEngine.blackmail;

        if (caseConv != null && caseConv.characterID == character.ID) {
          dataList.add(ConversationData(
              caseConv.characterID,
              _convertDialogues(
                  s, p, caseConv.characterID, caseConv.conversation),
              caseEngine.week,
              7,
              22));
        }
      }

      if (dataList.isNotEmpty) {
        data[character.name] = dataList;
      }
    }

    // Sort the data by week, day and hour
    data.forEach((key, value) {
      value.sort((a, b) {
        if (a.week == b.week) {
          if (a.day == b.day) {
            return a.hour.compareTo(b.hour);
          } else {
            return a.day.compareTo(b.day);
          }
        } else {
          return a.week.compareTo(b.week);
        }
      });
    });

    return data;
  }

  List<ConversationBubbleData> _convertDialogues(
      StoryEngine story,
      Player player,
      String characterID,
      List<ConversationBubbleDataEngine> conversations) {
    List<ConversationBubbleData> convertedDialogues = [];

    for (var d in conversations) {
      if (d.isPlayer) {
        if (!player.revealedConversations.contains(d.ID)) {
          convertedDialogues.add(ConversationBubbleData(
            d.ID,
            "Player",
            d.content,
            d.type,
            isRevealed: false,
          ));
          break;
        }
      }

      convertedDialogues.add(ConversationBubbleData(
          d.ID,
          d.isPlayer
              ? "Player"
              : story.characters.firstWhere((c) => c.ID == characterID).name,
          d.content,
          d.type,
          isRevealed: player.revealedConversations.contains(d.ID)));
    }

    return convertedDialogues;
  }

  Future<Directory> getDirectory(String path) async {
    Directory currentDirectory = Directory("Root", "Root", [], []);
    Player p = await _dataBaseEngine!.getPlayer();
    StoryEngine s = await _dataBaseEngine!.getStory();
    // We create one directory per available character
    var characters = await getAvailableCharacters();
    for (int i = 0; i < characters.length; i++) {
      var characterDirectory =
          Directory(characters[i].characterID, characters[i].name, [], []);
      // We add a directory for each weeks
      // We add a file for each revealed evidence
      for (ElementEngine e in s.elements) {
        if (e.characterID == characters[i].characterID) {
          for (String evidenceID in p.revealedElements) {
            if (e.ID == evidenceID) {
              // If evidence type is other than image, we check if an evidence is already in the weekDirectory
              bool alreadyInDirectory = false;
              for (Files f in characterDirectory.files) {
                if (f.type == e.type && f.name == "Week ${e.week}") {
                  alreadyInDirectory = true;
                }
              }
              if (!alreadyInDirectory) {
                characterDirectory.files.add(Files(
                    e.ID, "Week ${e.week}", e.type,
                    description: e.description));
              }
            }
          }
        }
      }
      currentDirectory.subdirectories.add(characterDirectory);
    }
    return currentDirectory;
  }

  Future<List<Files>> getPhoneEvidences(String characterID) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();
    List<Files> evidences = [];
    for (ElementEngine e in s.elements) {
      if (e.week == p.currentWeek &&
          e.day == p.currentDay &&
          e.hour == p.currentHour &&
          e.characterID == characterID) {
        ElementEngine nsfwLevelElement = _getClosestNsfwElement(characterID,
            e.type, e.week, e.day, e.hour, p.nsfwLevel, s.elements);
        if (!evidences.any((element) => element.type == e.type)) {
          evidences.add(Files(nsfwLevelElement.ID, nsfwLevelElement.type.name,
              nsfwLevelElement.type,
              description: nsfwLevelElement.description));
        }
      }
    }
    return evidences;
  }

  ElementEngine _getClosestNsfwElement(
      String characterID,
      EvidenceType type,
      int week,
      int day,
      int hour,
      int nsfwLevel,
      List<ElementEngine> elements) {
    List<ElementEngine> filteredElements = elements
        .where((e) =>
            e.type == type &&
            e.week == week &&
            e.day == day &&
            e.hour == hour &&
            e.characterID == characterID)
        .toList();

    filteredElements.sort((a, b) => (a.nsfwLevel - nsfwLevel)
        .abs()
        .compareTo((b.nsfwLevel - nsfwLevel).abs()));

    return filteredElements.first;
  }

  CinematicEngine _getClosestNsfwCinematic(int week, int day, int hour,
      int nsfwLevel, List<CinematicEngine> elements) {
    List<CinematicEngine> filteredElements = elements
        .where((e) => e.week == week && e.day == day && e.hour == hour)
        .toList();

    filteredElements.sort((a, b) => (a.nsfwLevel - nsfwLevel)
        .abs()
        .compareTo((b.nsfwLevel - nsfwLevel).abs()));

    return filteredElements.first;
  }

  Future<List<Files>> _getAllCurrentEvidence(Player p, StoryEngine s) async {
    List<Files> evidences = [];
    for (ElementEngine e in s.elements) {
      if (e.week == p.currentWeek &&
          e.day == p.currentDay &&
          e.hour == p.currentHour) {
        ElementEngine nsfwLevelElement = _getClosestNsfwElement(e.characterID,
            e.type, e.week, e.day, e.hour, p.nsfwLevel, s.elements);
        // If evidences doesn't already contains an evidence of this type
        if (!evidences.any((element) => element.type == e.type)) {
          evidences.add(Files(nsfwLevelElement.ID, nsfwLevelElement.type.name,
              nsfwLevelElement.type,
              description: nsfwLevelElement.description));
        }
      }
    }
    return evidences;
  }

  Future<List<ScrollableData>> getScrollableData(EvidenceType type) async {
    // Make a list with all revealed evidences of this type
    List<ScrollableData> timelineData = [];

    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();

    for (ElementEngine e in s.elements) {
      if (p.revealedElements.contains(e.ID) && e.type == type) {
        switch (e.type) {
          case EvidenceType.socialMedia:
            CharacterEngine character = s.characters
                .firstWhere((character) => character.ID == e.characterID);
            timelineData.add(ScrollableData(
                e.week,
                e.day,
                e.hour,
                ScrollableType.socialMedia,
                character.name,
                e.description,
                e.assetID ?? "",
                character.avatar));
          default:
            break;
        }
      }
    }

    return timelineData;
  }

  Future<String> getTextContent(Files file) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    ElementEngine element =
        s.elements.firstWhere((element) => element.ID == file.evidenceID);
    return element.textValue != null ? element.textValue! : "";
  }

  Future<List<TimelineData>> getTimelineData(EvidenceType type) async {
    // Make a list with all revealed evidences of this type
    List<TimelineData> timelineData = [];

    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();

    for (ElementEngine e in s.elements) {
      if (p.revealedElements.contains(e.ID) && e.type == type) {
        switch (e.type) {
          case EvidenceType.position:
            PlaceEngine place =
                s.places.firstWhere((place) => place.ID == e.placeID);
            timelineData.add(TimelineData(
                e.week,
                e.day,
                e.hour,
                TimelineType.position,
                e.description,
                PositionData(
                    place.name,
                    place.address,
                    place.asset,
                    Random().nextInt(1024).toDouble(),
                    Random().nextInt(1024).toDouble())));
          case EvidenceType.heartbeat:
            timelineData.add(TimelineData(e.week, e.day, e.hour,
                TimelineType.heartbeat, e.description, e.numberValue!));
          case EvidenceType.rearCamera:
            timelineData.add(TimelineData(e.week, e.day, e.hour,
                TimelineType.image, e.description, e.assetID!));
          default:
            break;
        }
      }
    }

    return timelineData;
  }

  Future<void> load(Player? p) async {
    StoryEngine story = await SaveAndLoadEngine.loadStoryEngine("story.yml");
    p ??= Player("sample_player", 1, 1, 7, [], [], [], [], [], [], {}, [],
        nsfwLevel: 0);
    _dataBaseEngine = DataBaseEngine(story, p);
    // Update prefix code if it exists
    await getCodesMixin(story, p);
  }

  void _collectAllEvidenceAndConversations(Player p, StoryEngine s) async {
    // Collect all evidences automatically
    for (var currentEvidence in await _getAllCurrentEvidence(p, s)) {
      if (!p.revealedElements.contains(currentEvidence.evidenceID)) {
        p.revealedElements.add(currentEvidence.evidenceID);
      }
    }

    // Collect all conversations automatically
    for (var currentConversation in (await _getConversations(p, s)).values) {
      for (var conversation in currentConversation) {
        for (var bubble in conversation.conversation) {
          if (!bubble.isRevealed) {
            p.revealedConversations.add(bubble.id);
          }
        }
      }
    }
  }

  @visibleForTesting
  Future<NextHourExceptionType?> checkEvidenceAndConversations(
          Player p, StoryEngine s) =>
      _checkEvidenceAndConversations(p, s);

  Future<NextHourExceptionType?> _checkEvidenceAndConversations(
      Player p, StoryEngine s) async {
    // Check if every evidence is collected
    for (var currentEvidence in await _getAllCurrentEvidence(p, s)) {
      if (!p.revealedElements.contains(currentEvidence.evidenceID)) {
        return NextHourExceptionType.needToCollectEvidence;
      }
    }

    // Check if every conversation is revealed
    for (var currentConversation in (await _getConversations(p, s)).values) {
      for (var conversation in currentConversation) {
        for (var bubble in conversation.conversation) {
          if (bubble.name == "Player" && !bubble.isRevealed) {
            return NextHourExceptionType.needToCollectConversation;
          }
        }
      }
    }

    return null;
  }

  @visibleForTesting
  Future<MaestroState> checkCinematicConditions(Player p, StoryEngine s) =>
      _checkCinematicConditions(p, s);

  Future<MaestroState> _checkCinematicConditions(
      Player p, StoryEngine s) async {
    MaestroState state = MaestroState();
    state.week = p.currentWeek;
    state.day = p.currentDay;
    state.hour = p.currentHour;

    for (CinematicEngine c in s.cinematics) {
      if (c.week == p.currentWeek &&
          c.day == p.currentDay &&
          c.hour == p.currentHour &&
          c.isConditionsAreGood(p)) {
        var cinematicNsfw = _getClosestNsfwCinematic(
            c.week, c.day, c.hour, p.nsfwLevel, s.cinematics);
        state.cinematicID = cinematicNsfw.ID;
        state.isCinematic = true;
        break;
      }
    }
    return state;
  }

  @visibleForTesting
  Future<void> updateNextHour(Player p) => _updateNextHour(p);

  Future<void> _updateNextHour(Player p) async {
    if (p.currentHour >= 22) {
      p.currentHour = 7;
      p.currentDay++;
      if (p.currentDay > 7) {
        p.currentDay = 1;
        p.currentWeek++;
      }
    } else {
      p.currentHour += 3;
    }
  }

  Future<NextHourExceptionType> nextHour(bool devMode, bool increment) async {
    Player p = await _dataBaseEngine!.getPlayer();
    StoryEngine s = await _dataBaseEngine!.getStory();

    if (devMode) {
      _collectAllEvidenceAndConversations(p, s);
    }

    // Check if every evidences are collected
    if (increment) {
      NextHourExceptionType? exceptionType =
          await _checkEvidenceAndConversations(p, s);
      if (exceptionType != null) {
        return exceptionType;
      }

      await updateNextHour(p);
    }

    MaestroState state = await checkCinematicConditions(p, s);

    await _dataBaseEngine!.savePlayer(p);
    if (!await _isNextHourExists()) {
      return NextHourExceptionType.endOfStory;
    }

    if (!await isElementsToDisplay() && !state.isCinematic) {
      return nextHour(devMode, increment);
    }
    streamController.add(state);
    return NextHourExceptionType.GoOn;
  }

  Future<bool> isElementsToDisplay() async {
    Player player = await getPlayer();
    StoryEngine story = await getStory();
    var evidences = await _getAllCurrentEvidence(player, story);
    if (evidences.isNotEmpty) {
      return true;
    }
    return await isMessagesNow();
  }

  Future<bool> isMessagesNow() async {
    Player player = await getPlayer();
    StoryEngine story = await getStory();
    var conversations = await _getConversations(player, story);
    return conversations.values
        .any((conversation) => conversation.any((c) => c.isNow));
  }

  Future<bool> _isNextHourExists() async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();

    bool nextHourExists = false;

    s.cinematics.forEach((cinematic) {
      if (cinematic.week > p.currentWeek) {
        nextHourExists = true;
      } else if (cinematic.week == p.currentWeek) {
        if (cinematic.day > p.currentDay) {
          nextHourExists = true;
        } else if (cinematic.day == p.currentDay) {
          if (cinematic.hour >= p.currentHour) {
            nextHourExists = true;
          }
        }
      }
    });

    s.conversations.forEach((conversation) {
      if (!nextHourExists && conversation.week > p.currentWeek) {
        nextHourExists = true;
      } else if (!nextHourExists && conversation.week == p.currentWeek) {
        if (conversation.day > p.currentDay) {
          nextHourExists = true;
        } else if (conversation.day == p.currentDay) {
          if (conversation.hour >= p.currentHour) {
            nextHourExists = true;
          }
        }
      }
    });

    s.elements.forEach((element) {
      if (!nextHourExists && element.week > p.currentWeek) {
        nextHourExists = true;
      } else if (!nextHourExists && element.week == p.currentWeek) {
        if (element.day > p.currentDay) {
          nextHourExists = true;
        } else if (element.day == p.currentDay) {
          if (element.hour >= p.currentHour) {
            nextHourExists = true;
          }
        }
      }
    });

    return nextHourExists;
  }

  Future<void> _removeFromEvidence(
      String characterID, String evidenceID) async {
    Player p = await _dataBaseEngine!.getPlayer();
    if (p.elementsMarkedAsEvidence.contains(evidenceID)) {
      p.elementsMarkedAsEvidence.remove(evidenceID);
      await _dataBaseEngine!.savePlayer(p);
    }
  }

  Future<bool> save(int slot) async {
    Player p = await _dataBaseEngine!.getPlayer();
    SavegameService().saveLocalPlayer(p);
    // if user connected
    if (SavegameService().isUserConnected()) {
      SavegameService().save(p);
      return true;
    }
    return false;
  }

  Future<void> start() async {
    await load(null);
    await nextHour(false, false);
  }

  Future<TimelineData> getSingleTimelineData(Files file) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    // We find the element in the story
    ElementEngine element =
        s.elements.firstWhere((element) => element.ID == file.evidenceID);
    if (element.type == EvidenceType.note) {
      throw UnimplementedError();
    } else if (element.type == EvidenceType.position) {
      PlaceEngine place =
          s.places.firstWhere((place) => place.ID == element.placeID);
      return TimelineData(
          element.week,
          element.day,
          element.hour,
          TimelineType.position,
          element.description,
          PositionData(
              place.name,
              place.address,
              place.asset,
              Random().nextInt(1024).toDouble(),
              Random().nextInt(1024).toDouble()));
    } else if (element.type == TimelineType.heartbeat) {
      throw UnimplementedError();
    }
    throw UnimplementedError();
  }

  Future<int> getNumberContent(Files file) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    ElementEngine element =
        s.elements.firstWhere((element) => element.ID == file.evidenceID);
    return element.numberValue != null ? element.numberValue! : 0;
  }

  Future<List<CharacterEngine>> _getContacts() async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();

    List<CharacterEngine> contacts = s.characters.where((character) {
      bool hasValidConversations = s.conversations.any((conversation) {
        if (conversation.characterID == character.ID) {
          if (conversation.week < p.currentWeek ||
              (conversation.week == p.currentWeek &&
                  conversation.day < p.currentDay) ||
              (conversation.week == p.currentWeek &&
                  conversation.day == p.currentDay &&
                  conversation.hour <= p.currentHour)) {
            return true;
          }
        }
        return false;
      });
      bool isInSolvedCases = p.solvedCases.contains(character.ID);
      return hasValidConversations || isInSolvedCases;
    }).toList();

    return contacts;
  }

  Future<StoryEngine> getStory() async {
    return await _dataBaseEngine!.getStory();
  }

  Future<Player> getPlayer() async {
    return await _dataBaseEngine!.getPlayer();
  }

  Future<void> goTo(int week, int day, int hour) async {
    // Reset player evidences
    Player p = await _dataBaseEngine!.getPlayer();
    p.revealedElements = [];
    p.currentDay = 1;
    p.currentWeek = 1;
    p.currentHour = 4;

    while (
        p.currentWeek != week || p.currentDay != day || p.currentHour != hour) {
      await nextHour(true, true);
      p = await _dataBaseEngine!.getPlayer();
    }
  }

  Future<void> collectEvidencesByType(EvidenceType type) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();
    List<Files> evidences = [];
    for (ElementEngine e in s.elements) {
      if (e.week == p.currentWeek &&
          e.day == p.currentDay &&
          e.hour == p.currentHour) {
        evidences
            .add(Files(e.ID, e.type.name, e.type, description: e.description));
      }
    }
    for (Files file in evidences) {
      p.revealedElements.add(file.evidenceID);
    }
  }

  Future<void> collectConversation(String conversationID) async {
    Player p = await _dataBaseEngine!.getPlayer();
    p.revealedConversations.add(conversationID);
  }

  Future<bool> addCode(String codeStr) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();
    return addCodeMixin(s, p, codeStr);
  }

  Future<void> removeCode(String codeStr) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();
    return removeCodeMixin(s, p, codeStr);
  }

  Future<List<String>> getPlayerCodes() async {
    Player p = await _dataBaseEngine!.getPlayer();
    return getPlayerCodesMixin(p);
  }

  Future<String> getPatreonCode() async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    return s.patreonLink;
  }
}
