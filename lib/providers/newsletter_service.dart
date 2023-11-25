import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hacking_game_ui/engine/player_engine.dart';
import 'package:uuid/uuid.dart';


class NewsLetterProvider {
  final CollectionReference bugReportCollection =
      FirebaseFirestore.instance.collection('newsletters');
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> save(String email) async {
    await bugReportCollection.doc(Uuid().v4()).set({
      'email': email,
      'date': DateTime.now().toIso8601String(),
    });
  }
}
