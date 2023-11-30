import 'package:flutter/cupertino.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/utils/image_code.dart';

class FinderImage extends StatelessWidget {
  final Maestro maestro;

  const FinderImage({
    super.key,
    required this.assetName,
    required this.maestro
  });

  final String assetName;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ImageWithCode(
        'images/$assetName',
        fit: BoxFit.fitHeight,
        code: maestro.getPrefixCode(),
      ),
    );
  }
}