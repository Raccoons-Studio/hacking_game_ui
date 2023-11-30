import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';

class ImageWithCode extends StatelessWidget {
  final String name;
  final Code? code;
  final double scale;
  final AssetBundle? bundle;
  final ImageErrorWidgetBuilder? errorBuilder;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final double? width;
  final double? height;
  final Color? color;
  final BlendMode colorBlendMode;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool? matchTextDirection;
  final bool gaplessPlayback;
  final bool isAntiAlias;

  ImageWithCode(
    this.name, {
    Key? key,
    this.code,
    this.scale = 1.0,
    this.bundle,
    this.errorBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode = BlendMode.srcIn,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
  }) : super(key: key);

  Future<bool> _checkIfAssetExists(BuildContext context, String path) async {
    final AssetBundle bundle = this.bundle ?? DefaultAssetBundle.of(context);
    try {
      await bundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (code != null &&
        code!.type == CodeType.prefix &&
        code!.strValue != null) {
      // Split the path to extract the file name
      var filename = name.split('/').last;
      // Split the path to extract the directory
      var directory = name.split('/').sublist(0, name.split('/').length - 1).map((e) => e).join('/');

      final String prefixedImagePath = '${directory}/${code!.strValue}_$filename';

      return FutureBuilder<bool>(
        future: _checkIfAssetExists(context, prefixedImagePath),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data == true) {
            return Image.asset(
              prefixedImagePath,
              key: key,
              scale: scale,
              bundle: bundle,
              errorBuilder: errorBuilder,
              semanticLabel: semanticLabel,
              excludeFromSemantics: excludeFromSemantics,
              width: width,
              height: height,
              color: color,
              colorBlendMode: colorBlendMode,
              fit: fit,
              alignment: alignment,
              repeat: repeat,
              centerSlice: centerSlice,
              matchTextDirection: matchTextDirection ?? false,
              gaplessPlayback: gaplessPlayback,
              isAntiAlias: isAntiAlias,
            );
          } else {
            return Image.asset(
              name,
              key: key,
              scale: scale,
              bundle: bundle,
              errorBuilder: errorBuilder,
              semanticLabel: semanticLabel,
              excludeFromSemantics: excludeFromSemantics,
              width: width,
              height: height,
              color: color,
              colorBlendMode: colorBlendMode,
              fit: fit,
              alignment: alignment,
              repeat: repeat,
              centerSlice: centerSlice,
              matchTextDirection: matchTextDirection ?? false,
              gaplessPlayback: gaplessPlayback,
              isAntiAlias: isAntiAlias,
            );
          }
        },
      );
    } else {
      return Image.asset(
        name,
        key: key,
        scale: scale,
        bundle: bundle,
        errorBuilder: errorBuilder,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        width: width,
        height: height,
        color: color,
        colorBlendMode: colorBlendMode,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection ?? false,
        gaplessPlayback: gaplessPlayback,
        isAntiAlias: isAntiAlias,
      );
    }
  }
}