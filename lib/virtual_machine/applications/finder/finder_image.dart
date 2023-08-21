import 'package:flutter/cupertino.dart';

class FinderImage extends StatelessWidget {
  const FinderImage({
    super.key,
    required this.assetName,
  });

  final String assetName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/$assetName',
        fit: BoxFit.contain,
      ),
    );
  }
}