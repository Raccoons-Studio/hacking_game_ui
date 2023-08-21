import 'dart:math';

import 'package:hacking_game_ui/engine/database_engine.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/engine/player_engine.dart';
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
  Future<Files> collectEvidence(String characterID, String evidenceID) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();
    ElementEngine element =
        s.elements.firstWhere((element) => element.elementID == evidenceID);
    bool isMarkedAsEvidence = p.elementsMarkedAsEvidence.contains(evidenceID);
    return Files(element.elementID, element.name, element.type,
        isMarkedAsEvidence: isMarkedAsEvidence);
  }

  @override
  Future<int> getAllCharacters() async {
    StoryEngine p = await _dataBaseEngine!.getStory();
    return p.characters.length;
  }

  @override
  Future<String> getAssetContent(Files file) {
    // TODO: implement getAssetContent
    throw UnimplementedError();
  }

  @override
  Future<List<Character>> getAvailableCharacters() async {
    List<Character> characters = [];
    Player p = await _dataBaseEngine!.getPlayer();
    StoryEngine s = await _dataBaseEngine!.getStory();
    for (CharacterEngine c in s.characters) {
      if (c.weekAvailability >= p.currentWeek) {
        characters.add(Character(
            characterID: c.characterID, name: c.name, avatar: c.avatar));
      }
    }
    return characters;
  }

  @override
  Future<Cinematic> getCinematicData(String cinematicID) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    CinematicEngine cinematic = s.cinematics
        .firstWhere((cinematic) => cinematic.cinematicID == cinematicID);
    List<CinematicSequence> cinematicSequences = [];
    for (var sequence in cinematic.sequences) {
      List<CinematicConversation> cinematicConversations = [];
      for (var conversation in sequence.cinematicConversations) {
        cinematicConversations.add(
            CinematicConversation(conversation.character, conversation.text));
      }
      cinematicSequences.add(CinematicSequence(sequence.cinematicSequenceID,
          sequence.cinematicAsset, cinematicConversations));
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
              if (e.elementID == evidenceID) {
                weekDirectory.files.add(Files(e.elementID, e.name, e.type));
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
        evidences.add(Files(e.elementID, e.name, e.type));
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
  Future<String> getTextContent(Files file) {
    // TODO: implement getTextContent
    throw UnimplementedError();
  }

  @override
  Future<List<TimelineData>> getTimelineData(Files file) {
    // TODO: implement getTimelineData
    throw UnimplementedError();
  }

  @override
  Future<void> load(String saveID) async {
    StoryEngine story = getSampleStory();
    Player player = getSamplePlayer();
    _dataBaseEngine = DataBaseEngine(story, player);
  }

  @override
  Future<bool> nextHour() async {
    Player p = await _dataBaseEngine!.getPlayer();
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
        state.cinematidID = c.cinematicID;
        state.isCinematic = true;
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
    await load("");
    await nextHour();
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
    ElementEngine element = s.elements
        .firstWhere((element) => element.elementID == file.evidenceID);
    if (element.type == EvidenceType.note) {
      throw UnimplementedError();
    } else if (element.type == EvidenceType.position) {
      PlaceEngine place = s.places.firstWhere((place) => place.placeID == element.placeID);
      return TimelineData(
          element.week,
          element.day,
          element.hour,
          TimelineType.position,
          element.description,
          PositionData(place.name, Random().nextInt(1024).toDouble(),
              Random().nextInt(1024).toDouble()));
    } else if (element.type == TimelineType.heartbeat) {
      throw UnimplementedError();
    }
    throw UnimplementedError();
  }
}
