class Player {
  String name;
  int currentWeek;
  int currentDay;
  int currentHour;
  List<String> revealedElements;
  List<String> elementsMarkedAsEvidence;
  List<String> revealedConversations;
  List<String> solvedCases;
  List<String> currentCases;
  List<String> unlockedApplications;
  String lang;
  bool isDevModeEnable;
  int nsfwLevel;

  Player(
      this.name,
      this.currentWeek,
      this.currentDay,
      this.currentHour,
      this.revealedElements,
      this.elementsMarkedAsEvidence,
      this.solvedCases,
      this.currentCases,
      this.unlockedApplications,
      this.revealedConversations,
      {this.isDevModeEnable = false,
      this.nsfwLevel = 0,
      this.lang = 'en'});

  Player.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        currentWeek = json['currentWeek'],
        currentDay = json['currentDay'],
        currentHour = json['currentHour'],
        revealedElements = List<String>.from(json["revealedElements"]),
        elementsMarkedAsEvidence =
            List<String>.from(json["elementsMarkedAsEvidence"]),
        solvedCases = List<String>.from(json["solvedCases"]),
        currentCases = List<String>.from(json["currentCases"]),
        revealedConversations = List<String>.from(json["revealedConversations"]),
        unlockedApplications = List<String>.from(json["unlockedApplications"]),
        lang = json['lang'],
        isDevModeEnable = json['isDevModeEnable'],
        nsfwLevel = json['nsfwLevel'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'currentWeek': currentWeek,
        'currentDay': currentDay,
        'currentHour': currentHour,
        'revealedElements': revealedElements,
        'elementsMarkedAsEvidence': elementsMarkedAsEvidence,
        'solvedCases': solvedCases,
        'currentCases': currentCases,
        'unlockedApplications': unlockedApplications,
        'lang': lang,
        'isDevModeEnable': isDevModeEnable,
        'nsfwLevel': nsfwLevel,
      };
}