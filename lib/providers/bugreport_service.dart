import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hacking_game_ui/engine/player_engine.dart';
import 'package:uuid/uuid.dart';

enum BugReportType { bug, suggestion, other }

class BugReportService {
  final CollectionReference bugReportCollection =
      FirebaseFirestore.instance.collection('bug_report');
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> save(Player player, BugReportType type, String comment) async {
    await bugReportCollection.doc(Uuid().v4()).set({
      'type': type.toString(),
      'comment': comment,
      'player': player.toJson(),
      'date': DateTime.now().toIso8601String(),
    });
  }
}
