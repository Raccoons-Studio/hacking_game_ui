enum ScrollableType {
  call,
  webHistory,
  message,
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

  ScrollableData(this.week, this.day, this.hour, this.type, this.content, this.subcontent);
}