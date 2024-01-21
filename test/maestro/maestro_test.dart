import 'package:flutter_test/flutter_test.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/engine/player_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';

void main() {
  group('updateNextHour', () {
    test(
        'updateNextHour should increment currentHour by 3 when currentHour is less than 22',
        () {
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
      player.currentHour = 10;

      Maestro().updateNextHour(player);

      expect(player.currentHour, 13);
    });

    test(
        'updateNextHour should reset currentHour to 7 and increment currentDay by 1 when currentHour is 22',
        () {
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
      player.currentHour = 22;
      player.currentDay = 3;

      Maestro().updateNextHour(player);

      expect(player.currentHour, 7);
      expect(player.currentDay, 4);
    });

    test(
        'updateNextHour should reset currentHour to 7, increment currentDay by 1, and increment currentWeek by 1 when currentHour is 22 and currentDay is 7',
        () {
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
      player.currentHour = 22;
      player.currentDay = 7;
      player.currentWeek = 2;

      Maestro().updateNextHour(player);

      expect(player.currentHour, 7);
      expect(player.currentDay, 1);
      expect(player.currentWeek, 3);
    });
  });

  group('checkCinematicConditions', () {
    test(
        'checkCinematicConditions should return MaestroState with correct week, day, and hour when conditions are met',
        () async {
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
      player.currentWeek = 3;
      player.currentDay = 2;
      player.currentHour = 15;

      final storyEngine =
          StoryEngine("", "", "", "", [], [], [], [], [], [], [], []);
      final cinematicEngine =
          CinematicEngine("abcdefghij", "UNIT TEST", 1, 1, 7, []);
      cinematicEngine.week = 3;
      cinematicEngine.day = 2;
      cinematicEngine.hour = 15;
      storyEngine.cinematics = [cinematicEngine];

      final maestroStory = Maestro();
      final maestroState =
          await maestroStory.checkCinematicConditions(player, storyEngine);

      expect(maestroState.week, player.currentWeek);
      expect(maestroState.day, player.currentDay);
      expect(maestroState.hour, player.currentHour);
    });

    test(
        'checkCinematicConditions should return MaestroState with isCinematic set to true and correct cinematicID when conditions are met',
        () async {
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
      player.currentWeek = 3;
      player.currentDay = 2;
      player.currentHour = 15;
      player.nsfwLevel = 2;

      final storyEngine =
          StoryEngine("", "", "", "", [], [], [], [], [], [], [], []);
      final cinematicEngine =
          CinematicEngine("abcdefghij", "UNIT TEST", 1, 1, 7, []);
      cinematicEngine.week = 3;
      cinematicEngine.day = 2;
      cinematicEngine.hour = 15;
      storyEngine.cinematics = [cinematicEngine];

      final maestroStory = Maestro();
      final maestroState =
          await maestroStory.checkCinematicConditions(player, storyEngine);

      expect(maestroState.isCinematic, true);
      expect(maestroState.cinematicID, cinematicEngine.ID);
    });

    test(
        'checkCinematicConditions should return MaestroState with isCinematic set to false when conditions are not met',
        () async {
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
      player.currentWeek = 3;
      player.currentDay = 2;
      player.currentHour = 15;

      final storyEngine =
          StoryEngine("", "", "", "", [], [], [], [], [], [], [], []);
      final cinematicEngine =
          CinematicEngine("abcdefghij", "UNIT TEST", 1, 1, 7, []);
      cinematicEngine.week = 1;
      cinematicEngine.day = 1;
      cinematicEngine.hour = 7;
      storyEngine.cinematics = [cinematicEngine];

      final maestroStory = Maestro();
      final maestroState =
          await maestroStory.checkCinematicConditions(player, storyEngine);

      expect(maestroState.isCinematic, false);
    });
  });

  group('checkCinematicConditions', () {
    test(
        'checkEvidenceAndConversations should return null when all evidence is collected and all conversations are revealed',
        () async {
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
      final storyEngine =
          StoryEngine("", "", "", "", [], [], [], [], [], [], [], []);
      player.revealedElements = ["evidence1", "evidence2", "evidence3"];

      final maestroStory = Maestro();
      final result =
          await maestroStory.checkEvidenceAndConversations(player, storyEngine);

      expect(result, null);
    });

    test(
        'checkEvidenceAndConversations should return NextHourExceptionType.needToCollectEvidence when not all evidence is collected',
        () async {
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
      final storyEngine =
          StoryEngine("", "", "", "", [], [], [], [], [], [], [], []);
      player.revealedElements = ["evidence1", "evidence2"];

      final maestroStory = Maestro();
      // Add mock evidence
      storyEngine.elements = [
        ElementEngine(
            "evidence1", "1", "CHARACTER", EvidenceType.bank, true, 1, 1, 7),
        ElementEngine("evidence2", "1", "CHARACTER", EvidenceType.calendar,
            true, 1, 1, 7),
        ElementEngine("evidence3", "1", "CHARACTER", EvidenceType.directory,
            true, 1, 1, 7),
      ];
      final result =
          await maestroStory.checkEvidenceAndConversations(player, storyEngine);

      expect(result, NextHourExceptionType.needToCollectEvidence);
    });

    test(
        'checkEvidenceAndConversations should return NextHourExceptionType.needToCollectConversation when not all conversations are revealed',
        () async {
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
      final storyEngine =
          StoryEngine("", "", "", "", [], [], [], [], [], [], [], []);

      // Add a mock character
      storyEngine.characters = [
        CharacterEngine("CHARACTER", "TEST CHARACTER", 1, "", "")
      ];

      final maestroStory = Maestro();
      // Add mock conversations
      storyEngine.conversations = [
        ConversationEngine("1", "CHARACTER", 1, 1, 7,
            [ConversationBubbleDataEngine("A", true, "TEST CONTENT")]),
        ConversationEngine("2", "CHARACTER", 1, 1, 7,
            [ConversationBubbleDataEngine("B", true, "TEST CONTENT")]),
        ConversationEngine("3", "CHARACTER", 1, 1, 7,
            [ConversationBubbleDataEngine("C", true, "TEST CONTENT")]),
      ];
      final result =
          await maestroStory.checkEvidenceAndConversations(player, storyEngine);

      expect(result, NextHourExceptionType.needToCollectConversation);
    });

    test(
        'checkEvidenceAndConversations should return null when all evidence is collected and all conversations are revealed',
        () async {
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
      final storyEngine =
          StoryEngine("", "", "", "", [], [], [], [], [], [], [], []);
      player.revealedElements = ["evidence1", "evidence2", "evidence3"];
      player.revealedConversations = [
        "conversation1",
        "conversation2",
        "conversation3"
      ];

      // Add mock conversations
      storyEngine.conversations = [
        ConversationEngine("1", "CHARACTER", 1, 1, 7, [
          ConversationBubbleDataEngine("conversation1", true, "TEST CONTENT")
        ]),
        ConversationEngine("2", "CHARACTER", 1, 1, 7, [
          ConversationBubbleDataEngine("conversation2", true, "TEST CONTENT")
        ]),
        ConversationEngine("3", "CHARACTER", 1, 1, 7, [
          ConversationBubbleDataEngine("conversation3", true, "TEST CONTENT")
        ]),
      ];

      // Add mock evidence
      storyEngine.elements = [
        ElementEngine(
            "evidence1", "1", "CHARACTER", EvidenceType.bank, true, 1, 1, 7),
        ElementEngine("evidence2", "1", "CHARACTER", EvidenceType.calendar,
            true, 1, 1, 7),
        ElementEngine("evidence3", "1", "CHARACTER", EvidenceType.directory,
            true, 1, 1, 7),
      ];

      final maestroStory = Maestro();
      final result =
          await maestroStory.checkEvidenceAndConversations(player, storyEngine);

      expect(result, null);
    });
  });

  group('checkForDuplicateIDs', () {
    test(
        'checkForDuplicateIDs should return an empty list when there are no duplicate IDs',
        () {
      final list = [
        ElementEngine("1", "", "", EvidenceType.bank, true, 1, 1, 7),
        ElementEngine("2", "", "", EvidenceType.bank, true, 1, 1, 7),
        ElementEngine("3", "", "", EvidenceType.bank, true, 1, 1, 7)
      ];
      final maestro = Maestro();

      final errors = maestro.checkForDuplicateIDs(list, "Item");

      expect(errors, isEmpty);
    });

    test(
        'checkForDuplicateIDs should return a list of IntegrityErrors when there are duplicate IDs',
        () {
      final list = [
        ElementEngine("1", "", "", EvidenceType.bank, true, 1, 1, 7),
        ElementEngine("2", "", "", EvidenceType.bank, true, 1, 1, 7),
        ElementEngine("3", "", "", EvidenceType.bank, true, 1, 1, 7),
        ElementEngine("1", "", "", EvidenceType.bank, true, 1, 1, 7),
      ];
      final maestro = Maestro();

      final errors = maestro.checkForDuplicateIDs(list, "Item");

      expect(errors.length, 1);
      expect(errors[0].type, IntegrityErrorType.dupplicateID);
      expect(errors[0].elementID, "1");
    });
  });

  group('_checkPlaceIDExistence', () {
    test(
        '_checkPlaceIDExistence should return an empty list when all place IDs exist',
        () {
      final items = [
        ElementEngine(
            "evidence1", "1", "CHARACTER", EvidenceType.bank, true, 1, 1, 7,
            placeID: "Place 1"),
        ElementEngine(
            "evidence2", "1", "CHARACTER", EvidenceType.bank, true, 1, 1, 7,
            placeID: "Place 2"),
        ElementEngine(
            "evidence3", "1", "CHARACTER", EvidenceType.bank, true, 1, 1, 7,
            placeID: "Place 3"),
      ];
      final places = [
        PlaceEngine("Place 1", "Item 1", "Place 1", ""),
        PlaceEngine("Place 2", "Item 2", "Place 2", ""),
        PlaceEngine("Place 3", "Item 3", "Place 3", ""),
      ];
      final maestro = Maestro();

      final errors = maestro.checkPlaceIDExistence(items, places, "Item");

      expect(errors, isEmpty);
    });

    test(
        '_checkPlaceIDExistence should return a list of IntegrityErrors when there are unexisting place IDs',
        () {
      final items = [
        ElementEngine(
            "evidence1", "1", "CHARACTER", EvidenceType.bank, true, 1, 1, 7,
            placeID: "Place 1"),
        ElementEngine(
            "evidence2", "1", "CHARACTER", EvidenceType.bank, true, 1, 1, 7,
            placeID: "Place 2"),
        ElementEngine(
            "evidence3", "1", "CHARACTER", EvidenceType.bank, true, 1, 1, 7,
            placeID: "Place 4"),
      ];
      final places = [
        PlaceEngine("Place 1", "Item 1", "Place 1", ""),
        PlaceEngine("Place 2", "Item 2", "Place 2", ""),
        PlaceEngine("Place 3", "Item 3", "Place 3", ""),
      ];
      final maestro = Maestro();

      final errors = maestro.checkPlaceIDExistence(items, places, "Item");

      expect(errors.length, 1);
      expect(errors[0].type, IntegrityErrorType.unexistingPlace);
      expect(errors[0].elementID, "evidence3");
    });
  });
  /*group('_checkAssetFileExistence', () {
    test(
        '_checkAssetFileExistence should return an empty list when all asset files exist',
        () async {
      final items = [
        ElementEngine(
            "evidence1", "1", "CHARACTER", EvidenceType.bank, true, 1, 1, 7,
            assetID: "asset1"),
        ElementEngine(
            "evidence2", "1", "CHARACTER", EvidenceType.bank, true, 1, 1, 7,
            assetID: "asset2"),
        ElementEngine(
            "evidence3", "1", "CHARACTER", EvidenceType.bank, true, 1, 1, 7,
            assetID: "asset3"),
      ];
      final maestro = Maestro();

      final errors = await maestro.checkAssetFileExistence(items, "Item");

      expect(errors, isEmpty);
    });

    test(
        '_checkAssetFileExistence should return a list of IntegrityErrors when there are nonexistent asset files',
        () async {
      final items = [
        ElementEngine(
            "evidence1", "1", "CHARACTER", EvidenceType.bank, true, 1, 1, 7,
            assetID: "asset1"),
        ElementEngine(
            "evidence2", "1", "CHARACTER", EvidenceType.bank, true, 1, 1, 7,
            assetID: "asset2"),
        ElementEngine(
            "evidence3", "1", "CHARACTER", EvidenceType.bank, true, 1, 1, 7,
            assetID: "nonexistent_asset"),
      ];
      final maestro = Maestro();

      final errors = await maestro.checkAssetFileExistence(items, "Item");

      expect(errors.length, 1);
      expect(errors[0].type, IntegrityErrorType.unexistingAsset);
      expect(errors[0].elementID, "evidence3");
    });
  });*/

  group('_checkCharacterIDExistence', () {
    test(
        '_checkCharacterIDExistence should return an empty list when all character IDs exist',
        () async {
      final items = [
        ElementEngine(
            "evidence1", "1", "character1", EvidenceType.bank, true, 1, 1, 7),
        ElementEngine(
            "evidence2", "1", "character2", EvidenceType.bank, true, 1, 1, 7),
        ElementEngine(
            "evidence3", "1", "character3", EvidenceType.bank, true, 1, 1, 7),
      ];
      final characters = [
        CharacterEngine("character1", "Character 1", 1, "", ""),
        CharacterEngine("character2", "Character 2", 1, "", ""),
        CharacterEngine("character3", "Character 3", 1, "", ""),
      ];
      final maestro = Maestro();

      final errors =
          await maestro.checkCharacterIDExistence(items, characters, "Item");

      expect(errors, isEmpty);
    });

    test(
        '_checkCharacterIDExistence should return a list of IntegrityErrors when there are unexisting character IDs',
        () async {
      final items = [
        ElementEngine(
            "evidence1", "1", "character1", EvidenceType.bank, true, 1, 1, 7),
        ElementEngine(
            "evidence2", "1", "character2", EvidenceType.bank, true, 1, 1, 7),
        ElementEngine(
            "evidence3", "1", "character3", EvidenceType.bank, true, 1, 1, 7),
        ElementEngine(
            "evidence4", "1", "character4", EvidenceType.bank, true, 1, 1, 7),
      ];
      final characters = [
        CharacterEngine("character1", "Character 1", 1, "", ""),
        CharacterEngine("character2", "Character 2", 1, "", ""),
        CharacterEngine("character3", "Character 3", 1, "", ""),
      ];
      final maestro = Maestro();

      final errors =
          await maestro.checkCharacterIDExistence(items, characters, "Item");

      expect(errors.length, 1);
      expect(errors[0].type, IntegrityErrorType.unexistingCharacter);
      expect(errors[0].elementID, "evidence4");
    });
  });

  group('_isEvidenceNow', () {
    test(
        '_isEvidenceNow should return true when the specified evidence is present',
        () async {
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
      final storyEngine =
          StoryEngine("", "", "", "", [], [], [], [], [], [], [], []);
      final items = [
        ElementEngine("evidence1", "evidence1", "character1", EvidenceType.bank,
            true, 1, 1, 7),
        ElementEngine("evidence2", "evidence2", "character2", EvidenceType.bank,
            true, 1, 1, 7),
        ElementEngine("evidence3", "evidence3", "character3", EvidenceType.bank,
            true, 1, 1, 7),
        ElementEngine("evidence4", "evidence4", "character4", EvidenceType.bank,
            true, 1, 1, 7),
      ];
      storyEngine.elements = items;
      player.revealedElements = ["evidence1", "evidence2", "evidence3"];

      final maestroStory = Maestro();
      final result = await maestroStory.isEvidenceNowTest(
          EvidenceType.bank, player, storyEngine);

      expect(result, true);
    });

    test(
        '_isEvidenceNow should return false when the specified evidence is not present',
        () async {
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
      final storyEngine =
          StoryEngine("", "", "", "", [], [], [], [], [], [], [], []);
      final items = [
        ElementEngine("evidence1", "evidence1", "character1", EvidenceType.bank,
            true, 1, 1, 13),
        ElementEngine("evidence2", "evidence2", "character2", EvidenceType.bank,
            true, 1, 1, 13),
        ElementEngine("evidence3", "evidence3", "character3", EvidenceType.bank,
            true, 1, 1, 13),
        ElementEngine("evidence4", "evidence4", "character4", EvidenceType.bank,
            true, 1, 1, 13),
      ];
      storyEngine.elements = items;
      player.revealedElements = ["evidence1", "evidence2", "evidence3"];

      final maestroStory = Maestro();
      final result = await maestroStory.isEvidenceNowTest(
          EvidenceType.calendar, player, storyEngine);

      expect(result, false);
    });
  });
}
