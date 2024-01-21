import 'package:flutter_test/flutter_test.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/engine/player_engine.dart';

void main() {
  group('ModelEngine', () {
    test('isConditionsAreGood should return true when conditions are null', () {
      final engine = CinematicEngine("", "", 1, 1, 7, []);
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);

      final result = engine.isConditionsAreGood(player);

      expect(result, true);
    });

    test('isConditionsAreGood should return true when conditions are empty',
        () {
      final engine = CinematicEngine("", "", 1, 1, 7, []);
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
      engine.conditions = [];

      final result = engine.isConditionsAreGood(player);

      expect(result, true);
    });

    test('isConditionsAreGood should return true when conditions are met', () {
      final engine = CinematicEngine("", "", 1, 1, 7, []);
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
      engine.conditions = [
        Condition(
          'score',
          ConditionOperator.EQUAL,
          intValue: 100,
        ),
        Condition(
          'level',
          ConditionOperator.GREATER,
          intValue: 5,
        ),
      ];
      player.variables = {
        'score': 100,
        'level': 10,
      };

      final result = engine.isConditionsAreGood(player);

      expect(result, true);
    });

    test('isConditionsAreGood should return false when conditions are not met',
        () {
      final engine = CinematicEngine("", "", 1, 1, 7, []);
      final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
      engine.conditions = [
        Condition(
          'score',
          ConditionOperator.EQUAL,
          intValue: 100,
        ),
        Condition(
          'level',
          ConditionOperator.GREATER,
          intValue: 5,
        ),
      ];
      player.variables = {
        'score': 50,
        'level': 3,
      };

      final result = engine.isConditionsAreGood(player);

      expect(result, false);
    });
  });

  test(
      'isConditionsAreGood should return true when conditions are met with GREATER_EQUAL operator',
      () {
    final engine = CinematicEngine("", "", 1, 1, 7, []);
    final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
    engine.conditions = [
      Condition(
        'score',
        ConditionOperator.GREATER_EQUAL,
        intValue: 100,
      ),
      Condition(
        'level',
        ConditionOperator.GREATER_EQUAL,
        intValue: 5,
      ),
    ];
    player.variables = {
      'score': 100,
      'level': 10,
    };

    final result = engine.isConditionsAreGood(player);

    expect(result, true);
  });

  test(
      'isConditionsAreGood should return true when conditions are met with LESS_EQUAL operator',
      () {
    final engine = CinematicEngine("", "", 1, 1, 7, []);
    final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
    engine.conditions = [
      Condition(
        'score',
        ConditionOperator.LESS_EQUAL,
        intValue: 100,
      ),
      Condition(
        'level',
        ConditionOperator.LESS_EQUAL,
        intValue: 5,
      ),
    ];
    player.variables = {
      'score': 50,
      'level': 3,
    };

    final result = engine.isConditionsAreGood(player);

    expect(result, true);
  });

  test(
      'isConditionsAreGood should return true when conditions are met with NOT operator',
      () {
    final engine = CinematicEngine("", "", 1, 1, 7, []);
    final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
    engine.conditions = [
      Condition(
        'score',
        ConditionOperator.NOT,
        boolValue: false,
      ),
      Condition(
        'level',
        ConditionOperator.NOT,
        boolValue: true,
      ),
    ];
    player.variables = {
      'score': true,
      'level': false,
    };

    final result = engine.isConditionsAreGood(player);

    expect(result, true);
  });

  test(
      'isConditionsAreGood should return false when conditions are not met with STRING_EQUAL operator',
      () {
    final engine = CinematicEngine("", "", 1, 1, 7, []);
    final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
    engine.conditions = [
      Condition(
        'name',
        ConditionOperator.EQUAL,
        strValue: "test",
      ),
      Condition(
        'level',
        ConditionOperator.EQUAL,
        strValue: "beginner",
      ),
    ];
    player.variables = {
      'name': "John",
      'level': "intermediate",
    };

    final result = engine.isConditionsAreGood(player);

    expect(result, false);
  });

  test(
      'isConditionsAreGood should return true when conditions are met with STRING_EQUAL operator',
      () {
    final engine = CinematicEngine("", "", 1, 1, 7, []);
    final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
    engine.conditions = [
      Condition(
        'name',
        ConditionOperator.EQUAL,
        strValue: "test",
      ),
      Condition(
        'level',
        ConditionOperator.EQUAL,
        strValue: "beginner",
      ),
    ];
    player.variables = {
      'name': "test",
      'level': "beginner",
    };

    final result = engine.isConditionsAreGood(player);

    expect(result, true);
  });

  test(
      'isConditionsAreGood should return false when conditions are not met with BOOL_EQUAL operator',
      () {
    final engine = CinematicEngine("", "", 1, 1, 7, []);
    final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
    engine.conditions = [
      Condition(
        'isActivated',
        ConditionOperator.EQUAL,
        boolValue: true,
      ),
      Condition(
        'isCompleted',
        ConditionOperator.EQUAL,
        boolValue: false,
      ),
    ];
    player.variables = {
      'isActivated': false,
      'isCompleted': true,
    };

    final result = engine.isConditionsAreGood(player);

    expect(result, false);
  });

  test(
      'isConditionsAreGood should return true when conditions are met with BOOL_EQUAL operator',
      () {
    final engine = CinematicEngine("", "", 1, 1, 7, []);
    final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
    engine.conditions = [
      Condition(
        'isActivated',
        ConditionOperator.EQUAL,
        boolValue: true,
      ),
      Condition(
        'isCompleted',
        ConditionOperator.EQUAL,
        boolValue: false,
      ),
    ];
    player.variables = {
      'isActivated': true,
      'isCompleted': false,
    };

    final result = engine.isConditionsAreGood(player);

    expect(result, true);
  });

  test(
      'isConditionsAreGood should return false when conditions are not met with LESS operator',
      () {
    final engine = CinematicEngine("", "", 1, 1, 7, []);
    final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
    engine.conditions = [
      Condition(
        'score',
        ConditionOperator.LESS,
        intValue: 100,
      ),
      Condition(
        'level',
        ConditionOperator.LESS,
        intValue: 5,
      ),
    ];
    player.variables = {
      'score': 150,
      'level': 3,
    };

    final result = engine.isConditionsAreGood(player);

    expect(result, false);
  });

  test(
      'isConditionsAreGood should return true when conditions are met with GREATER_EQUAL operator',
      () {
    final engine = CinematicEngine("", "", 1, 1, 7, []);
    final player = Player("test", 1, 1, 7, [], [], [], [], [], [], {}, []);
    engine.conditions = [
      Condition(
        'score',
        ConditionOperator.GREATER_EQUAL,
        intValue: 100,
      ),
      Condition(
        'level',
        ConditionOperator.GREATER_EQUAL,
        intValue: 5,
      ),
    ];
    player.variables = {
      'score': 150,
      'level': 10,
    };

    final result = engine.isConditionsAreGood(player);

    expect(result, true);
  });

  group('CinematicEngine', () {
    test('toMap should return a valid map', () {
      final engine = CinematicEngine(
        "ID",
        "name",
        1,
        1,
        7,
        [],
        conditions: [],
        nsfwLevel: 0,
        description: "description",
      );

      final result = engine.toMap();

      expect(result, {
        'ID': "ID",
        'name': "name",
        'week': 1,
        'day': 1,
        'hour': 7,
        'sequences': [],
        'conditions': [],
        'nsfwLevel': 0,
        'description': "description",
      });
    });

    test('fromMap should return a valid CinematicEngine instance', () {
      final map = {
        'ID': "ID",
        'name': "name",
        'week': 1,
        'day': 1,
        'hour': 7,
        'sequences': [],
        'conditions': [],
        'nsfwLevel': 0,
        'description': "description",
      };

      final result = CinematicEngine.fromMap(map);

      expect(result.ID, "ID");
      expect(result.name, "name");
      expect(result.week, 1);
      expect(result.day, 1);
      expect(result.hour, 7);
      expect(result.sequences, []);
      expect(result.conditions, []);
      expect(result.nsfwLevel, 0);
      expect(result.description, "description");
    });
  });
}
