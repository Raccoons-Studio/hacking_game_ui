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

class StoryEngine {
  String storyID;
  String name;
  String description;
  List<CharacterEngine> characters;
  List<PlaceEngine> places;
  List<ElementEngine> elements;
  List<CaseEngine> cases;
  List<CinematicEngine> cinematics;

  StoryEngine(this.storyID, this.name, this.description, this.characters,
      this.places, this.elements, this.cases, this.cinematics);
  
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
    };
  }

  static StoryEngine fromMap(Map<String, dynamic> map) {
    return StoryEngine(
      map['storyID'],
      map['name'],
      map['description'],
      List<CharacterEngine>.from(map['characters']?.map((x) => CharacterEngine.fromMap(x))),
      List<PlaceEngine>.from(map['places']?.map((x) => PlaceEngine.fromMap(x))),
      List<ElementEngine>.from(map['elements']?.map((x) => ElementEngine.fromMap(x))),
      List<CaseEngine>.from(map['cases']?.map((x) => CaseEngine.fromMap(x))),
      List<CinematicEngine>.from(map['cinematics']?.map((x) => CinematicEngine.fromMap(x))),
    );
  }
}

class CharacterEngine {
  String characterID;
  String name;
  String avatar;
  int weekAvailability;

  CharacterEngine(
      this.characterID, this.name, this.weekAvailability, this.avatar);
  
  Map<String, dynamic> toMap() {
    return {
      'characterID': characterID,
      'name': name,
      'avatar': avatar,
      'weekAvailability': weekAvailability,
    };
  }

  static CharacterEngine fromMap(Map<String, dynamic> map) {
    return CharacterEngine(
      map['characterID'],
      map['name'],
      map['weekAvailability'],
      map['avatar'],
    );
  }
}

class PlaceEngine {
  String placeID;
  String name;
  String description;
  String address;

  PlaceEngine(this.placeID, this.name, this.description, {this.address = ""});

  Map<String, dynamic> toMap() {
    return {
      'placeID': placeID,
      'name': name,
      'description': description,
      'address': address,
    };
  }

  static PlaceEngine fromMap(Map<String, dynamic> map) {
    return PlaceEngine(
      map['placeID'],
      map['name'],
      map['description'],
      address: map['address'],
    );
  }
}

class ElementEngine {
  String elementID;
  String name;
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

  String? relatedCaseID;

  ElementEngine(this.elementID, this.name, this.description, this.characterID,
      this.type, this.isEvidence, this.week, this.day, this.hour,
      {this.relatedCaseID,
      this.assetID,
      this.placeID,
      this.numberValue,
      this.textValue,
      this.isOptionalEvidence = false});

  Map<String, dynamic> toMap() {
    return {
      'elementID': elementID,
      'name': name,
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
    };
  }

  static ElementEngine fromMap(Map<String, dynamic> map) {
    return ElementEngine(
      map['elementID'],
      map['name'],
      map['description'],
      map['characterID'],
      EvidenceType.values.firstWhere((e) => e.toString().split('.')[1] == map['type']),
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
    );
  }
}

class CaseEngine {
  String caseID;
  String characterID;
  String name;
  String description;
  int week;

  CaseEngine(
      this.caseID, this.characterID, this.name, this.description, this.week);

  Map<String, dynamic> toMap() {
    return {
      'caseID': caseID,
      'characterID': characterID,
      'name': name,
      'description': description,
      'week': week,
    };
  }

  static CaseEngine fromMap(Map<String, dynamic> map) {
    return CaseEngine(
      map['caseID'],
      map['characterID'],
      map['name'],
      map['description'],
      map['week'],
    );
  }
}

class CinematicEngine {
  String cinematicID;
  String name;
  int week;
  int day;
  int hour;
  List<CinematicSequenceEngine> sequences;

  CinematicEngine(this.cinematicID, this.name, this.week, this.day, this.hour,
      this.sequences);

  Map<String, dynamic> toMap() {
    return {
      'cinematicID': cinematicID,
      'name': name,
      'week': week,
      'day': day,
      'hour': hour,
      'sequences': sequences.map((x) => x.toMap()).toList(),
    };
  }

  static CinematicEngine fromMap(Map<String, dynamic> map) {
    return CinematicEngine(
      map['cinematicID'],
      map['name'],
      map['week'],
      map['day'],
      map['hour'],
      List<CinematicSequenceEngine>.from(map['sequences']?.map((x) => CinematicSequenceEngine.fromMap(x))),
    );
  }
}

class CinematicSequenceEngine {
  String cinematicSequenceID;
  String cinematicAsset;
  List<CinematicConversationEngine> cinematicConversations;

  CinematicSequenceEngine(this.cinematicSequenceID, this.cinematicAsset,
      this.cinematicConversations);
  
  Map<String, dynamic> toMap() {
    return {
      'cinematicSequenceID': cinematicSequenceID,
      'cinematicAsset': cinematicAsset,
      'cinematicConversations': cinematicConversations.map((x) => x.toMap()).toList(),
    };
  }

  static CinematicSequenceEngine fromMap(Map<String, dynamic> map) {
    return CinematicSequenceEngine(
      map['cinematicSequenceID'],
      map['cinematicAsset'],
      List<CinematicConversationEngine>.from(map['cinematicConversations']?.map((x) => CinematicConversationEngine.fromMap(x))),
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
      map['character'],
      map['text'],
    );
  }
}