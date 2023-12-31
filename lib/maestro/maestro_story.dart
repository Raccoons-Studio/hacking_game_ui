import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

import 'package:hacking_game_ui/engine/database_engine.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/engine/player_engine.dart';
import 'package:hacking_game_ui/engine/save_load_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/providers/savegame_service.dart';
import 'package:hacking_game_ui/virtual_machine/applications/phone/phone_characters_selector.dart';
import 'package:hacking_game_ui/virtual_machine/models/cinematic.dart';
import 'package:hacking_game_ui/virtual_machine/models/conversation_data.dart';
import 'package:hacking_game_ui/virtual_machine/models/directory_and_files.dart';
import 'package:hacking_game_ui/virtual_machine/models/scrollable_data.dart';
import 'package:hacking_game_ui/virtual_machine/models/timeline_data.dart';

class MaestroStory extends Maestro {
  DataBaseEngine? _dataBaseEngine;
  Code? _prefixCode;

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
      cinematicSequences.add(CinematicSequence(
          sequence.cinematicAsset, cinematicConversations,
          cinematicDescription: sequence.cinematicDescription));
    }
    return Cinematic(cinematicID, cinematicSequences,
        cinematicDescription: cinematic.description);
  }

  @override
  Future<Map<String, List<ConversationData>>> getConversations() async {
    if (_dataBaseEngine == null) {
      return {};
    }
    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();

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
              convertDialogues(s, p, conv.characterID, conv.conversation),
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
              convertDialogues(
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

  List<ConversationBubbleData> convertDialogues(
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

  @override
  Future<List<Files>> getAllCurrentEvidence() async {
    if (_dataBaseEngine == null) {
      return [];
    }
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
          evidences.add(Files(nsfwLevelElement.ID, nsfwLevelElement.type.name,
              nsfwLevelElement.type,
              description: nsfwLevelElement.description));
        }
      }
    }
    return evidences;
  }

  @override
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

  @override
  Future<String> getTextContent(Files file) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    ElementEngine element =
        s.elements.firstWhere((element) => element.ID == file.evidenceID);
    return element.textValue != null ? element.textValue! : "";
  }

  @override
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

  @override
  Future<void> load(Player? p) async {
    StoryEngine story = await SaveAndLoadEngine.loadStoryEngine("story.yml");
    p ??= Player("sample_player", 1, 1, 7, [], [], [], [], [], [], {}, [],
        nsfwLevel: 0);
    _dataBaseEngine = DataBaseEngine(story, p);
    // Update prefix code if it exists
    await getCodes();
  }

  @override
  Future<NextHourExceptionType> nextHour(bool devMode, bool increment) async {
    Player p = await _dataBaseEngine!.getPlayer();

    if (devMode) {
      // With dev mod we collect all evidences automatically
      for (var currentEvidence in await getAllCurrentEvidence()) {
        if (!p.revealedElements.contains(currentEvidence.evidenceID)) {
          p.revealedElements.add(currentEvidence.evidenceID);
        }
      }

      // With dev mod we collect all conversation automatically
      for (var currentConversation in (await getConversations()).values) {
        for (var conversation in currentConversation) {
          for (var bubble in conversation.conversation) {
            if (!bubble.isRevealed) {
              p.revealedConversations.add(bubble.id);
            }
          }
        }
      }
    }

    // Check if every evidences are collected
    if (increment) {
      for (var currentEvidence in await getAllCurrentEvidence()) {
        if (!p.revealedElements.contains(currentEvidence.evidenceID)) {
          return NextHourExceptionType.needToCollectEvidence;
        }
      }
      // Check if every conversations are revealed
      for (var currentConversation in (await getConversations()).values) {
        for (var conversation in currentConversation) {
          for (var bubble in conversation.conversation) {
            if (bubble.name == "Player" && !bubble.isRevealed) {
              return NextHourExceptionType.needToCollectConversation;
            }
          }
        }
      }
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
        state.cinematicID = cinematicNsfw.ID;
        state.isCinematic = true;
        break;
      }
    }

    await _dataBaseEngine!.savePlayer(p);
    if (!await isNextHourExists()) {
      return NextHourExceptionType.endOfStory;
    }

    if (!await isElementsToDisplay() && !state.isCinematic) {
      return nextHour(devMode, increment);
    }
    super.streamController.add(state);
    return NextHourExceptionType.GoOn;
  }

  Future<bool> isNextHourExists() async {
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

  @override
  Future<void> removeFromEvidence(String characterID, String evidenceID) async {
    Player p = await _dataBaseEngine!.getPlayer();
    if (p.elementsMarkedAsEvidence.contains(evidenceID)) {
      p.elementsMarkedAsEvidence.remove(evidenceID);
      await _dataBaseEngine!.savePlayer(p);
    }
  }

  @override
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

  @override
  Future<void> start() async {
    await load(null);
    await nextHour(false, false);
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
  Future<List<CharacterEngine>> getContacts() async {
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

  @override
  Future<StoryEngine> getStory() async {
    return await _dataBaseEngine!.getStory();
  }

  @override
  Future<Player> getPlayer() async {
    return await _dataBaseEngine!.getPlayer();
  }

  @override
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

  @override
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

  @override
  Future<void> collectConversation(String conversationID) async {
    Player p = await _dataBaseEngine!.getPlayer();
    p.revealedConversations.add(conversationID);
  }

  @override
  Future<bool> addCode(String codeStr) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();
    for (var code in s.codes) {
      var bytes = utf8.encode(codeStr); // data being hashed
      var digest = sha1.convert(bytes);
      if (code.name == digest.toString()) {
        p.codes.add(codeStr);
        if (code.type == CodeType.prefix) {
          _prefixCode = code;
        }
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> removeCode(String codeStr) async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();
    p.codes.remove(codeStr);
  }

  @override
  Future<List<Code>> getCodes() async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();
    List<Code> codes = [];
    for (var code in s.codes) {
      for (var codePlayer in p.codes) {
        if (code.name == codePlayer) {
          codes.add(code);
          if (code.type == CodeType.prefix) {
            _prefixCode = code;
          }
        }
      }
    }
    return codes;
  }

  @override
  Future<List<String>> getPlayerCodes() async {
    Player p = await _dataBaseEngine!.getPlayer();
    return p.codes;
  }

  @override
  Code? getPrefixCode() {
    return _prefixCode;
  }

  @override
  Future<bool> checkCodeAvailability() async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    Player p = await _dataBaseEngine!.getPlayer();
    for (var codePlayer in p.codes) {
      bool isCodePlayerAvailable = false;
      for (var code in s.codes) {
        if (code.name == codePlayer) {
          isCodePlayerAvailable = true;
        }
      }
      if (!isCodePlayerAvailable) {
        return false;
      }
    }
    return true;
  }

  Future<String> getPatreonCode() async {
    StoryEngine s = await _dataBaseEngine!.getStory();
    return s.patreonLink;
  }
}
