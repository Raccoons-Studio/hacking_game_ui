enum TimelineType {
  position,
  heartbeat,
  note,
}

class TimelineData {
  int week;
  int day;
  int hour;
  TimelineType type;
  String content;
  Object value;

  TimelineData(this.week, this.day, this.hour, this.type, this.content, this.value);
}

class PositionData {
  double x;
  double y;

  PositionData(this.x, this.y);
}