
enum FileType { 
  position, 
  heartbeat, 
  note, 
  call,
  webHistory,
  message,
  socialMedia,
  calendar,
  image,
  text,
  directory }

class Files {
  String evidenceID;
  String name;
  FileType type;
  Directory? parent;
  bool isMarkedAsEvidence;

  Files(this.evidenceID, this.name, this.type, {this.parent, this.isMarkedAsEvidence = false});
}

class Directory extends Files {
  List<Directory> subdirectories;
  List<Files> files;

  Directory(uniqueID, name, this.subdirectories, this.files, {super.parent}) : super(uniqueID, name, FileType.directory);
}

