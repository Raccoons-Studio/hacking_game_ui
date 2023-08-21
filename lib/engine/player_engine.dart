class Player {
  String name;
  int currentWeek;
  int currentDay;
  int currentHour;
  List<String> revealedElements;
  List<String> elementsMarkedAsEvidence;
  List<String> solvedCases;
  List<String> currentCases;
  List<String> unlockedApplications;

  Player(this.name, this.currentWeek, this.currentDay, this.currentHour, this.revealedElements, this.elementsMarkedAsEvidence, this.solvedCases, this.currentCases, this.unlockedApplications);
}