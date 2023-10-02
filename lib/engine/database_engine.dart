import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/engine/player_engine.dart';

class DataBaseEngine {
  final StoryEngine _storyEngine;
  Player _playerEngine;

  DataBaseEngine(this._storyEngine, this._playerEngine);

  Future<StoryEngine> getStory() async{
    return _storyEngine;
  }

  Future<Player> getPlayer() async{
    return _playerEngine;
  }

  Future<void> savePlayer(Player player) async{
    _playerEngine = player;
  }

}