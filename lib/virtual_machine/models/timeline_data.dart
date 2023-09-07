enum TimelineType {
  image,
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
  String name;
  String address;
  String asset;
  double x;
  double y;

  PositionData(this.name, this.address, this.asset, this.x, this.y);
}