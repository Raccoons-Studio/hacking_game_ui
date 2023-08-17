
enum FileType { timeline, image, text, scrollable, directory }

class Files {
  String uniqueID;
  String name;
  FileType type;
  Directory? parent;

  Files(this.uniqueID, this.name, this.type, {this.parent});
}

class Directory extends Files {
  List<Directory> subdirectories;
  List<Files> files;

  Directory(uniqueID, name, this.subdirectories, this.files, {super.parent}) : super(uniqueID, name, FileType.directory);
}

