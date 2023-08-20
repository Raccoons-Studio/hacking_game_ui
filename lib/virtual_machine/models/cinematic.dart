class Cinematic {
  String cinematicID;
  List<CinematicSequence> cinematicSequences;

  Cinematic(this.cinematicID, this.cinematicSequences);
}

class CinematicSequence {
  String cinematicSequenceID;
  String cinematicAsset;
  List<CinematicConversation> cinematicConversations;

  CinematicSequence(this.cinematicSequenceID, this.cinematicAsset, this.cinematicConversations);
}

class CinematicConversation {
  String character;
  String text;

  CinematicConversation(this.character, this.text);
}