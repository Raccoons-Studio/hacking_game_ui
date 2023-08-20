import 'package:hacking_game_ui/virtual_machine/models/cinematic.dart';

abstract class CinematicProvider {
  Future<Cinematic> getCinematicData(String cinematicID);
}