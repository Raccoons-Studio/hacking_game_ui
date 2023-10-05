import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hacking_game_ui/engine/player_engine.dart';
import 'package:hacking_game_ui/engine/save_load_engine.dart';

class SavegameService {
  final CollectionReference savegameCollection = FirebaseFirestore.instance.collection('savegames');

  Future<Savegame> load(String id) async {
    final docSnapshot = await savegameCollection.doc(id).get();

    return Savegame.fromJson(docSnapshot.data() as Map<String, dynamic>);
  }

  Future<List<Savegame>> listSave() async {
    final querySnapshot = await savegameCollection.get();
    return querySnapshot.docs.map((e) => Savegame.fromJson(e.data() as Map<String, dynamic>)).toList();
  }

  Future<Savegame> save(Player player) async {
    Savegame savegame = Savegame(
      DateTime.now().toString(),
      DateTime.now(), 
      player.name,
      player.currentWeek,
      player.currentDay,
      player.currentHour,
      player);

    await savegameCollection.doc(savegame.id).set(savegame.toJson());

    return savegame;
  }

  Future<void> delete(String id) async {
    await savegameCollection.doc(id).delete();
  }
}