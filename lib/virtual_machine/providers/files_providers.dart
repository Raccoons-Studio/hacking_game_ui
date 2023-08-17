import 'package:hacking_game_ui/virtual_machine/models/scrollable_data.dart';
import 'package:hacking_game_ui/virtual_machine/models/timeline_data.dart';

import '../models/directory_and_files.dart';

abstract class FilesProvider {
  Future<Directory> getDirectory(String path);

  Future<String> getTextContent(Files file);

  Future<List<TimelineData>> getTimelineData(Files file);

  Future<List<ScrollableData>> getScrollableData(Files file);
}