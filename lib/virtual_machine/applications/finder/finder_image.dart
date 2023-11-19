import 'package:flutter/cupertino.dart';

class FinderImage extends StatelessWidget {
  const FinderImage({
    super.key,
    required this.assetName,
  });

  final String assetName;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Image.asset(
        'images/$assetName',
        fit: BoxFit.fitHeight,
      ),
    );
  }
}