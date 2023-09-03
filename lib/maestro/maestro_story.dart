import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:hacking_game_ui/engine/database_engine.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/engine/player_engine.dart';
import 'package:hacking_game_ui/engine/save_load_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/providers/mocks/sample_story.dart';
import 'package:hacking_game_ui/virtual_machine/applications/phone/phone_characters_selector.dart';
import 'package:hacking_game_ui/virtual_machine/models/cinematic.dart';
import 'package:hacking_game_ui/virtual_machine/models/conversation_data.dart';
import 'package:hacking_game_ui/virtual_machine/models/directory_and_files.dart';
import 'package:hacking_game_ui/virtual_machine/models/scrollable_data.dart';
import 'package:hacking_game_ui/virtual_machine/models/timeline_data.dart';

class MaestroStory extends Maestro {
  DataBaseEngine? _dataBaseEngine;

  void init(StoryEngine storyEngine, Player playerEngine) {
    _dataBaseEngine = DataBaseEngine(storyEngine, playerEngine);
  }

  @override
  Future<void> addToEvidence(String characterID, String evidenceID) async {
    Player p = await _dataBaseEngine!.getPlayer();
    // Check if the evidence is already in the player's inventory
    if (!p.elementsMarkedAsEvidence.contains(evidenceID)) {
      // If not, add it
      p.elementsMarkedAsEvidence.add(evidenceID);
      await _dataBaseEngine!.savePlayer(p);
    }
  }

  @override
  Future<void> collectEvidence(String evidenceID) async {
    Player p = await _dataBaseEngine!.getPlayer();
    p.revealedElements.add(evidenceID);
  }

  @override
  Future<int> getAllCharacters() async {
    StoryEngine p = await _dataBaseEngine!.getStory();
    return p.characters.length;
  }

  @override
  Future<String> getAssetContent(Files file) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    ElementEngine element =
        s.elements.firstWhere((element) => element.ID == file.evidenceID);
    return element.assetID != null ? element.assetID! : "";
  }

  @override
  Future<List<Character>> getAvailableCharacters() async {
    List<Character> characters = [];
    Player p = await _dataBaseEngine!.getPlayer();
    StoryEngine s = await _dataBaseEngine!.getStory();
    for (CharacterEngine c in s.characters) {
      if (c.weekAvailability >= p.currentWeek) {
        characters.add(Character(
            characterID: c.ID,
            name: c.name,
            avatar: c.avatar,
            wallpaper: c.wallpaper));
      }
    }
    return characters;
  }

  @override
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
      cinematicSequences.add(
          CinematicSequence(sequence.cinematicAsset, cinematicConversations));
    }
    return Cinematic(cinematicID, cinematicSequences);
  }

  @override
  Future<Map<String, List<ConversationData>>> getConversations() {
    // TODO: implement getConversations
    throw UnimplementedError();
  }

  @override
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
      for (int j = 0; j <= p.currentWeek; j++) {
        var weekDirectory = Directory("Week $j", "Week $j", [], []);
        // We add a file for each revealed evidence
        for (ElementEngine e in s.elements) {
          if (e.week == j && e.characterID == characters[i].characterID) {
            for (String evidenceID in p.revealedElements) {
              if (e.ID == evidenceID) {
                // If evidence type is other than image, we check if an evidence is already in the weekDirectory
                if (e.type != EvidenceType.image) {
                  bool alreadyInDirectory = false;
                  for (Files f in weekDirectory.files) {
                    if (f.type == e.type) {
                      alreadyInDirectory = true;
                    }
                  }
                  if (!alreadyInDirectory) {
                    weekDirectory.files.add(Files(e.ID, e.name, e.type,
                        description: e.description));
                  }
                } else {
                  weekDirectory.files.add(
                      Files(e.ID, e.name, e.type, description: e.description));
                }
              }
            }
          }
        }
        characterDirectory.subdirectories.add(weekDirectory);
      }
      currentDirectory.subdirectories.add(characterDirectory);
    }
    return currentDirectory;
  }

  @override
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
          evidences.add(Files(
              nsfwLevelElement.ID, nsfwLevelElement.name, nsfwLevelElement.type,
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

  Future<List<Files>> getAllCurrentEvidence() async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();
    List<Files> evidences = [];
    for (ElementEngine e in s.elements) {
      if (e.week == p.currentWeek &&
          e.day == p.currentDay &&
          e.hour == p.currentHour) {
        ElementEngine nsfwLevelElement = _getClosestNsfwElement(e.characterID,
            e.type, e.week, e.day, e.hour, p.nsfwLevel, s.elements);
        // If evidences doesn't already contains an evidence of this type
        if (!evidences.any((element) => element.type == e.type)) {
          evidences.add(Files(
              nsfwLevelElement.ID, nsfwLevelElement.name, nsfwLevelElement.type,
              description: nsfwLevelElement.description));
        }
      }
    }
    return evidences;
  }

  @override
  Future<List<ScrollableData>> getScrollableData(Files file) {
    // TODO: implement getScrollableData
    throw UnimplementedError();
  }

  @override
  Future<String> getTextContent(Files file) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    ElementEngine element =
        s.elements.firstWhere((element) => element.ID == file.evidenceID);
    return element.textValue != null ? element.textValue! : "";
  }

  @override
  Future<List<TimelineData>> getTimelineData(Files file) async {
    // Make a list with all revealed evidences of this type
    List<TimelineData> timelineData = [];

    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();

    for (ElementEngine e in s.elements) {
      if (p.revealedElements.contains(e.ID) && e.type == file.type) {
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
          default:
            break;
        }
      }
    }

    return timelineData;
  }

  @override
  Future<void> load(String saveID) async {
    StoryEngine story = await SaveAndLoadEngine.loadStoryEngine(saveID);
    //var integrity = await this.checkIntegrity(story);
    Player player = getSamplePlayer();
    _dataBaseEngine = DataBaseEngine(story, player);
  }

  @override
  Future<bool> nextHour(bool devMode) async {
    Player p = await _dataBaseEngine!.getPlayer();

    if (devMode) {
      // With dev mod we collect all evidences automatically
      for (var currentEvidence in await this.getAllCurrentEvidence()) {
        if (!p.revealedElements.contains(currentEvidence.evidenceID)) {
          p.revealedElements.add(currentEvidence.evidenceID);
        }
      }
    }

    // Check if every evidences are collected
    for (var currentEvidence in await this.getAllCurrentEvidence()) {
      if (!p.revealedElements.contains(currentEvidence.evidenceID)) {
        return false;
      }
    }

    if (p.currentHour >= 22) {
      p.currentHour = 7;
      p.currentDay++;
      if (p.currentDay == 7) {
        p.currentDay = 0;
        p.currentWeek++;
      }
    } else {
      p.currentHour += 3;
    }

    // Search if we need to play a cinematic
    StoryEngine s = await _dataBaseEngine!.getStory();
    MaestroState state = MaestroState();
    state.week = p.currentWeek;
    state.day = p.currentDay;
    state.hour = p.currentHour;
    for (CinematicEngine c in s.cinematics) {
      if (c.week == p.currentWeek &&
          c.day == p.currentDay &&
          c.hour == p.currentHour) {
        var cinematicNsfw = _getClosestNsfwCinematic(
            c.week, c.day, c.hour, p.nsfwLevel, s.cinematics);
        state.cinematidID = cinematicNsfw.ID;
        state.isCinematic = true;
        break;
      }
    }

    await _dataBaseEngine!.savePlayer(p);
    super.streamController.add(state);
    return true;
  }

  @override
  Future<void> removeFromEvidence(String characterID, String evidenceID) async {
    Player p = await _dataBaseEngine!.getPlayer();
    if (p.elementsMarkedAsEvidence.contains(evidenceID)) {
      p.elementsMarkedAsEvidence.remove(evidenceID);
      await _dataBaseEngine!.savePlayer(p);
    }
  }

  @override
  Future<void> save() {
    // TODO: implement save
    throw UnimplementedError();
  }

  @override
  Future<void> start() async {
    await load("anna_story.yml");
    await nextHour(false);
  }

  @override
  Future<void> submitEvidences(String characterID) {
    // TODO: implement submitEvidences
    throw UnimplementedError();
  }

  @override
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

  @override
  Future<int> getNumberContent(Files file) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    ElementEngine element =
        s.elements.firstWhere((element) => element.ID == file.evidenceID);
    return element.numberValue != null ? element.numberValue! : 0;
  }

  @override
  Future<List<ContactEngine>> getContacts() {
    // TODO: implement getContacts
    throw UnimplementedError();
  }

  @override
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

  Future<List<IntegrityError>> _checkAssetFileExistence(
      List items, String type) async {
    var errors = <IntegrityError>[];
    for (var item in items) {
      if (item.assetID != null) {
        var assetPath = 'assets/images/${item.assetID}';
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
        if (sequence.cinematicAsset != null) {
          var assetPath = 'assets/images/${sequence.cinematicAsset}';
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
    }
    return errors;
  }

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
}
