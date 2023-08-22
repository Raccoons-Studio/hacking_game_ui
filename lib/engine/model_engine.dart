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
}

class CharacterEngine {
  String characterID;
  String name;
  String avatar;
  int weekAvailability;

  CharacterEngine(
      this.characterID, this.name, this.weekAvailability, this.avatar);
}

class PlaceEngine {
  String placeID;
  String name;
  String description;

  PlaceEngine(this.placeID, this.name, this.description);
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
      this.textValue});
}

class CaseEngine {
  String caseID;
  String characterID;
  String name;
  String description;
  int week;

  CaseEngine(
      this.caseID, this.characterID, this.name, this.description, this.week);
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
}

class CinematicSequenceEngine {
  String cinematicSequenceID;
  String cinematicAsset;
  List<CinematicConversationEngine> cinematicConversations;

  CinematicSequenceEngine(this.cinematicSequenceID, this.cinematicAsset,
      this.cinematicConversations);
}

class CinematicConversationEngine {
  String character;
  String text;

  CinematicConversationEngine(this.character, this.text);
}
