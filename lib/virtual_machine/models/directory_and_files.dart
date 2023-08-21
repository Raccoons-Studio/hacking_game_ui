

import 'package:hacking_game_ui/engine/model_engine.dart';

class Files {
  String evidenceID;
  String name;
  EvidenceType type;
  Directory? parent;
  bool isMarkedAsEvidence;

  Files(this.evidenceID, this.name, this.type, {this.parent, this.isMarkedAsEvidence = false});
}

class Directory extends Files {
  List<Directory> subdirectories;
  List<Files> files;

  Directory(uniqueID, name, this.subdirectories, this.files, {super.parent}) : super(uniqueID, name, EvidenceType.directory);
}

