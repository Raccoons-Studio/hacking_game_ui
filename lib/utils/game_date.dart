Future<String> getDayOfWeek(int day) async {
  switch (day) {
    case 0:
      return Future.value("Monday");
    case 1:
      return Future.value("Tuesday");
    case 2:
      return Future.value("Wednesday");
    case 3:
      return Future.value("Thursday");
    case 4:
      return Future.value("Friday");
    case 5:
      return Future.value("Saturday");
    case 6:
      return Future.value("Sunday");
    default:
      return Future.value("Monday");
  }
}