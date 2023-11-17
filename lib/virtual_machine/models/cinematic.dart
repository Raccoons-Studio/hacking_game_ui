class Cinematic {
  String cinematicID;
  List<CinematicSequence> cinematicSequences;

  Cinematic(this.cinematicID, this.cinematicSequences);
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