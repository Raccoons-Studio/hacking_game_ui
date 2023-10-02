import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';

class Parameters extends StatelessWidget {
  final Maestro _maestro;

  const Parameters(this._maestro, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.extraLightBackgroundGray,
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isHorizontal = constraints.maxWidth > constraints.maxHeight;
          return Center(
            child: Flex(
              direction: isHorizontal ? Axis.horizontal : Axis.vertical,
              children: <Widget>[
                _createColoredSquare(CupertinoColors.activeBlue, CupertinoIcons.add_circled, 'New Game', _onNewGame),
                SizedBox(height: 0, width: isHorizontal ? 50 : 0),
                _createColoredSquare(CupertinoColors.activeGreen, CupertinoIcons.download_circle, 'Load Game', _onLoadGame),
                SizedBox(height: 0, width: isHorizontal ? 50 : 0),
                _createColoredSquare(CupertinoColors.activeOrange, Icons.file_copy, 'Save Game', _onSaveGame),
               SizedBox(height: 0, width: isHorizontal ? 50 : 0),
                _createColoredSquare(CupertinoColors.darkBackgroundGray, Icons.settings, 'Settings', _onSettings),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _createColoredSquare(Color color, IconData iconData, String text, Function() onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 200,
          constraints: const BoxConstraints(maxHeight: 200),
          color: color,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(iconData, color: Colors.white, size: 50),
                Container(height: 10),
                Text(text, style: const TextStyle(color: Colors.white))
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onNewGame() async {
    await _maestro.start();
  }

  _onLoadGame() async {
    await _maestro.load(0);
    await _maestro.start();
  }

  _onSaveGame() async {
    await _maestro.save(0);
  }

  _onSettings() {
    // Handle settings event
  }
}