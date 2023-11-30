import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hacking_game_ui/engine/player_engine.dart';
import 'package:hacking_game_ui/engine/save_load_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SavegameService {
  final CollectionReference savegameCollection =
      FirebaseFirestore.instance.collection('players');
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<String> _getUserUUIDFromFirebase() async {
    if (auth.currentUser == null) {
      throw Exception("User not connected");
    }
    return auth.currentUser!.uid;
  }

  bool isUserConnected() {
    return auth.currentUser != null;
  }

  Future<Savegame> load(String id) async {
    final userUUID = await _getUserUUIDFromFirebase();
    final docSnapshot = await savegameCollection
        .doc(userUUID)
        .collection('players')
        .doc(id)
        .get();

    return Savegame.fromJson(docSnapshot.data() as Map<String, dynamic>);
  }

  Future<List<Savegame>> listSave() async {
    if (auth.currentUser == null) {
      return [];
    }
    final userUUID = await _getUserUUIDFromFirebase();
    final querySnapshot =
        await savegameCollection.doc(userUUID).collection('players').get();
    return querySnapshot.docs.map((e) {
      print(e.data());
      return Savegame.fromJson(e.data());
    }).toList();
  }

  Future<Savegame> save(Player player) async {
    final userUUID = await _getUserUUIDFromFirebase();
    Savegame savegame = Savegame(
        DateTime.now().toString(),
        DateTime.now(),
        player.name,
        player.currentWeek,
        player.currentDay,
        player.currentHour,
        player,
        false);

    await savegameCollection
        .doc(userUUID)
        .collection('players')
        .doc(savegame.id)
        .set(savegame.toJson());

    return savegame;
  }

  Future<void> delete(String id) async {
    final userUUID = await _getUserUUIDFromFirebase();
    await savegameCollection
        .doc(userUUID)
        .collection('players')
        .doc(id)
        .delete();
  }

  Future<Player?> loadLocalPlayer(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    final playerJson = prefs.getString('player_$slot');
    if (playerJson != null) {
      return Player.fromJson(jsonDecode(playerJson));
    }
    return null;
  }

  Future<Savegame> saveLocalPlayer(Player player) async {
    final prefs = await SharedPreferences.getInstance();
    var save = Savegame(Uuid().v4(), DateTime.now(), player.name, player.currentWeek,
        player.currentDay, player.currentHour, player, true);
    final playerJson = jsonEncode(save.toJson());
    await prefs.setString('player_${save.id}', playerJson);
    return save;
  }

  Future<List<Savegame>> getLocalSaveGame() async {
    final prefs = await SharedPreferences.getInstance();
    List<Savegame> slots = [];
    prefs.getKeys().forEach((key) {
      if (key.startsWith('player_')) {
        Savegame savegame = Savegame.fromJson(jsonDecode(prefs.getString(key)!));
        savegame.isLocal = true;
        slots.add(savegame);
      }
    });
    return slots;
  }
}
