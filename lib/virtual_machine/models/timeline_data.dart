enum TimelineType {
  position,
  heartbeat,
}

class TimelineData {
  int week;
  int day;
  int hour;
  TimelineType type;
  String content;

  TimelineData(this.week, this.day, this.hour, this.type, this.content);
}