enum ScrollableType {
  note,
  webHistory,
  socialMedia,
  calendar,
}

class ScrollableData {
  int week;
  int day;
  int hour;
  ScrollableType type;
  String content;
  String subcontent;
  bool isMarkedAsEvidence;

  ScrollableData(this.week, this.day, this.hour, this.type, this.content, this.subcontent, {this.isMarkedAsEvidence = false});
}