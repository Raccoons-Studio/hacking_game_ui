class Cinematic {
  String cinematicID;
  String? cinematicDescription;
  List<CinematicSequence> cinematicSequences;

  Cinematic(this.cinematicID, this.cinematicSequences, {this.cinematicDescription});
}

class CinematicSequence {
  String cinematicAsset;
  String? cinematicDescription;
  List<CinematicConversation> cinematicConversations;

  CinematicSequence(this.cinematicAsset, this.cinematicConversations, {this.cinematicDescription});
}

class CinematicConversation {
  String character;
  String text;

  CinematicConversation(this.character, this.text);
}