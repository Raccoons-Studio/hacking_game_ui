class ConversationData {
  String evidenceID;
  int week;
  int day;
  int hour;
  bool isMarkedAsEvidence;
  bool isNow;
  List<ConversationBubbleData> conversation;

  ConversationData(this.evidenceID, this.conversation, this.week, this.day, this.hour, {this.isMarkedAsEvidence = false, this.isNow = false});
}

class ConversationBubbleData {
  String name;
  String content;

  ConversationBubbleData(this.name, this.content);    
}