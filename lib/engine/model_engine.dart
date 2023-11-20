import 'package:uuid/uuid.dart';

enum EvidenceType {
  microphone,
  bank,
  deleted,
  frontCamera,
  rearCamera,
  position,
  heartbeat,
  note,
  call,
  webHistory,
  message,
  socialMedia,
  calendar,
  image,
  text,
  directory
}

class TimeLine {
  int week;
  int day;
  int hour;
  List<ElementEngine> elements;
  List<CinematicEngine> cinematics;
  List<ConversationEngine> conversations;

  TimeLine(this.week, this.day, this.hour, this.elements, this.cinematics,
      this.conversations);
}

class StoryEngine {
  String storyID;
  String name;
  String description;
  List<CharacterEngine> characters;
  List<PlaceEngine> places;
  List<ElementEngine> elements;
  List<CaseEngine> cases;
  List<CinematicEngine> cinematics;
  List<ConversationEngine> conversations;
  List<String> enabledApplications;

  StoryEngine(
      this.storyID,
      this.name,
      this.description,
      this.characters,
      this.places,
      this.elements,
      this.cases,
      this.cinematics,
      this.conversations,
      this.enabledApplications);

  Map<String, dynamic> toMap() {
    return {
      'storyID': storyID,
      'name': name,
      'description': description,
      'characters': characters.map((x) => x.toMap()).toList(),
      'places': places.map((x) => x.toMap()).toList(),
      'elements': elements.map((x) => x.toMap()).toList(),
      'cases': cases.map((x) => x.toMap()).toList(),
      'cinematics': cinematics.map((x) => x.toMap()).toList(),
      'conversations': conversations.map((x) => x.toMap()).toList(),
      'enabledApplications': enabledApplications.toList(),
    };
  }

  static StoryEngine fromMap(Map<String, dynamic> map) {
    return StoryEngine(
      map['storyID'],
      map['name'],
      map['description'],
      map['characters'] != null
          ? List<CharacterEngine>.from(
              map['characters']?.map((x) => CharacterEngine.fromMap(x)))
          : [],
      map['places'] != null
          ? List<PlaceEngine>.from(
              map['places']?.map((x) => PlaceEngine.fromMap(x)))
          : [],
      map['elements'] != null
          ? List<ElementEngine>.from(
              map['elements']?.map((x) => ElementEngine.fromMap(x)))
          : [],
      map['cases'] != null
          ? List<CaseEngine>.from(
              map['cases']?.map((x) => CaseEngine.fromMap(x)))
          : [],
      map['cinematics'] != null
          ? List<CinematicEngine>.from(
              map['cinematics']?.map((x) => CinematicEngine.fromMap(x)))
          : [],
      map['conversations'] != null
          ? List<ConversationEngine>.from(
              map['conversations']?.map((x) => ConversationEngine.fromMap(x)))
          : [],
      map['enabledApplications'] != null
          ? List<String>.from(map['enabledApplications'])
          : [],
    );
  }
}

class CharacterEngine {
  String ID;
  String name;
  String avatar;
  String unrevealedName;
  String wallpaper;
  int weekAvailability;
  bool isPlayable;

  CharacterEngine(
      this.ID, this.name, this.weekAvailability, this.avatar, this.wallpaper,
      {this.isPlayable = false, this.unrevealedName = ""});

  Map<String, dynamic> toMap() {
    return {
      'ID': ID,
      'name': name,
      'avatar': avatar,
      'wallpaper': wallpaper,
      'weekAvailability': weekAvailability,
      'unrevealedName': unrevealedName,
      'isPlayable': isPlayable,
    };
  }

  static CharacterEngine fromMap(Map<String, dynamic> map) {
    return CharacterEngine(
      map['ID'],
      map['name'],
      map['weekAvailability'],
      map['avatar'],
      map['wallpaper'],
      unrevealedName: map['unrevealedName'] ?? "",
      isPlayable: map['isPlayable'] ?? false,
    );
  }
}

class PlaceEngine {
  String ID;
  String name;
  String description;
  String address;
  String asset;

  PlaceEngine(this.ID, this.name, this.description, this.asset,
      {this.address = ""});

  Map<String, dynamic> toMap() {
    return {
      'ID': ID,
      'name': name,
      'description': description,
      'address': address,
      'asset': asset,
    };
  }

  static PlaceEngine fromMap(Map<String, dynamic> map) {
    return PlaceEngine(
      map['ID'],
      map['name'],
      map['description'],
      map['asset'],
      address: map['address'],
    );
  }
}

class ElementEngine {
  String ID;
  String description;
  String characterID;
  String? assetID;
  String? placeID;
  int? numberValue;
  String? textValue;
  EvidenceType type;
  bool isEvidence;
  bool isOptionalEvidence;
  int week;
  int day;
  int hour;
  int nsfwLevel;

  String? relatedCaseID;

  ElementEngine(this.ID, this.description, this.characterID, this.type,
      this.isEvidence, this.week, this.day, this.hour,
      {this.relatedCaseID,
      this.assetID,
      this.placeID,
      this.numberValue,
      this.textValue,
      this.isOptionalEvidence = false,
      this.nsfwLevel = 0});

  Map<String, dynamic> toMap() {
    return {
      'ID': ID,
      'description': description,
      'characterID': characterID,
      'assetID': assetID,
      'placeID': placeID,
      'numberValue': numberValue,
      'textValue': textValue,
      'type': type.toString(),
      'isEvidence': isEvidence,
      'isOptionalEvidence': isOptionalEvidence,
      'week': week,
      'day': day,
      'hour': hour,
      'relatedCaseID': relatedCaseID,
      'nsfwLevel': nsfwLevel,
    };
  }

  static ElementEngine fromMap(Map<String, dynamic> map) {
    return ElementEngine(
      map['ID'],
      map['description'] ?? "",
      map['characterID'],
      EvidenceType.values
          .firstWhere((e) => e.name == map['type'].split('.')[1]),
      map['isEvidence'],
      map['week'],
      map['day'],
      map['hour'],
      relatedCaseID: map['relatedCaseID'],
      assetID: map['assetID'],
      placeID: map['placeID'],
      numberValue: map['numberValue'],
      textValue: map['textValue'],
      isOptionalEvidence: map['isOptionalEvidence'] ?? false,
      nsfwLevel: map['nsfwLevel'] ?? 0,
    );
  }
}

class CaseEngine {
  String ID;
  String characterID;
  String name;
  String description;
  int week;
  CinematicEngine? resolution;
  ConversationEngine? blackmail;

  CaseEngine(this.ID, this.characterID, this.name, this.description, this.week,
      {this.resolution, this.blackmail});

  Map<String, dynamic> toMap() {
    return {
      'ID': ID,
      'characterID': characterID,
      'name': name,
      'description': description,
      'week': week,
      'resolution': resolution == null ? "" : resolution!.toMap(),
      'blackmail': blackmail == null ? "" : blackmail!.toMap(),
    };
  }

  static CaseEngine fromMap(Map<String, dynamic> map) {
    return CaseEngine(
      map['ID'],
      map['characterID'] ?? "",
      map['name'] ?? "",
      map['description'] ?? "",
      map['week'],
      resolution: map['resolution'] == null
          ? null
          : CinematicEngine.fromMap(map['resolution']),
      blackmail: map['blackmail'] == null
          ? null
          : ConversationEngine.fromMap(map['blackmail']),
    );
  }
}

class CinematicEngine {
  String ID;
  String name;
  int week;
  int day;
  int hour;
  int nsfwLevel;
  String? description;
  List<CinematicSequenceEngine> sequences;

  CinematicEngine(
      this.ID, this.name, this.week, this.day, this.hour, this.sequences,
      {this.nsfwLevel = 0, this.description});

  Map<String, dynamic> toMap() {
    return {
      'ID': ID,
      'name': name,
      'week': week,
      'day': day,
      'hour': hour,
      'sequences':
          sequences.isEmpty ? "" : sequences.map((x) => x.toMap()).toList(),
      'nsfwLevel': nsfwLevel,
      'description': description,
    };
  }

  static CinematicEngine fromMap(Map<String, dynamic> map) {
    return CinematicEngine(
        map['ID'],
        map['name'] ?? "",
        map['week'],
        map['day'],
        map['hour'],
        List<CinematicSequenceEngine>.from(
            map['sequences']?.map((x) => CinematicSequenceEngine.fromMap(x)) ?? []),
        nsfwLevel: map['nsfwLevel'] ?? 0,
        description: map['description']);
  }
}

class CinematicSequenceEngine {
  String cinematicAsset;
  String? cinematicDescription;
  List<CinematicConversationEngine> cinematicConversations;

  CinematicSequenceEngine(this.cinematicAsset, this.cinematicConversations, {this.cinematicDescription});

  Map<String, dynamic> toMap() {
    return {
      'cinematicAsset': cinematicAsset,
      'cinematicDescription': cinematicDescription,
      'cinematicConversations':
          cinematicConversations.map((x) => x.toMap()).toList(),
    };
  }

  static CinematicSequenceEngine fromMap(Map<String, dynamic> map) {
    return CinematicSequenceEngine(
      map['cinematicAsset'] ?? "",
      List<CinematicConversationEngine>.from(map['cinematicConversations']
          ?.map((x) => CinematicConversationEngine.fromMap(x))),
      cinematicDescription: map['cinematicDescription'],
    );
  }
}

class CinematicConversationEngine {
  String character;
  String text;

  CinematicConversationEngine(this.character, this.text);

  Map<String, dynamic> toMap() {
    return {
      'character': character,
      'text': text,
    };
  }

  static CinematicConversationEngine fromMap(Map<String, dynamic> map) {
    return CinematicConversationEngine(
      map['character'] ?? "",
      map['text'] ?? "",
    );
  }
}

class ConversationEngine {
  String conversationID;
  String characterID;
  int week;
  int day;
  int hour;
  bool isNameRevealed;
  List<ConversationBubbleDataEngine> conversation;

  ConversationEngine(this.conversationID, this.characterID, this.week, this.day,
      this.hour, this.conversation,
      {this.isNameRevealed = false});

  Map<String, dynamic> toMap() {
    return {
      'conversationID': conversationID,
      'characterID': characterID,
      'week': week,
      'day': day,
      'hour': hour,
      'isNameRevealed': isNameRevealed,
      'conversation': conversation.map((bubble) => bubble.toMap()).toList(),
    };
  }

  static ConversationEngine fromMap(Map<String, dynamic> map) {
    return ConversationEngine(
      map['conversationID'],
      map['characterID'] ?? "",
      map['week'],
      map['day'],
      map['hour'],
      map['conversation'] != null ?map['conversation']
          .map<ConversationBubbleDataEngine>(
              (bubbleMap) => ConversationBubbleDataEngine.fromMap(bubbleMap))
          .toList(): [],
      isNameRevealed: map['isNameRevealed'],
    );
  }
}

enum ConversationBubbleDataEngineType { text, image, bank }

class ConversationBubbleDataEngine {
  String ID;
  String content;
  bool isPlayer;
  ConversationBubbleDataEngineType type;

  ConversationBubbleDataEngine(this.ID, this.isPlayer, this.content,
      {this.type = ConversationBubbleDataEngineType.text});

  Map<String, dynamic> toMap() {
    return {
      'id': ID,
      'content': content,
      'isPlayer': isPlayer,
      'type': type.toString(),
    };
  }

  static ConversationBubbleDataEngine fromMap(Map<String, dynamic> map) {
    return ConversationBubbleDataEngine(
      map['id'] ?? const Uuid().v4(),
      map['isPlayer'],
      map['content'],
      type: map['type'] != null ? ConversationBubbleDataEngineType.values
          .firstWhere((e) => e.name == map['type'].split('.')[1]) : ConversationBubbleDataEngineType.text,
    );
  }
}
