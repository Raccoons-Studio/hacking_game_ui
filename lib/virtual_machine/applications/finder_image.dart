import 'package:flutter/cupertino.dart';
import 'package:hacking_game_ui/virtual_machine/models/directory_and_files.dart';

class FinderImage extends StatelessWidget {
  const FinderImage({
    super.key,
    required Files? currentFile,
  }) : _currentFile = currentFile;

  final Files? _currentFile;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/${_currentFile!.uniqueID}.jpg',
        fit: BoxFit.contain,
      ),
    );
  }
}