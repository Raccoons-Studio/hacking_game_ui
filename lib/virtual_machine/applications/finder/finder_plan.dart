import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FinderPlan extends StatefulWidget {
  final ImageProvider image;
  final List<Offset> markers;

  const FinderPlan({super.key, required this.image, required this.markers});

  @override
  _FinderPlanState createState() => _FinderPlanState();
}

class _FinderPlanState extends State<FinderPlan> {
  ui.Image? image;
  late Future _fetchImage;
  double radius = 20.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchImage = _loadImage(widget.image);
    _timer = Timer.periodic(const Duration(milliseconds: 200), (Timer timer) {
      setState(() {
        radius < 60.0 ? radius += 10.0 : radius = 20.0;
      });
    });
  }

  @override
  void dispose() {
    image?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future _loadImage(ImageProvider provider) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    final ImageStream stream = provider.resolve(const ImageConfiguration());

    void listener(ImageInfo info, bool _) {
      if (!completer.isCompleted) {
        completer.complete(info.image);
      }
    }

    final ImageStreamListener imageStreamListener =
        ImageStreamListener(listener);
    stream.addListener(imageStreamListener);
    image = await completer.future;
    stream.removeListener(imageStreamListener);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchImage,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done || image == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: image!.width.toDouble(),
            height: image!.height.toDouble(),
            child: Stack(
              children: [
                RawImage(
                  image: image,
                  fit: BoxFit.cover,
                ),
                CustomPaint(
                  painter: _MarkerPainter(
                      radius: radius,
                      markers: widget.markers,
                      imageSize: Size(
                          image!.width.toDouble(), image!.height.toDouble())),
                  child: SizedBox(
                    width: image!.width.toDouble(),
                    height: image!.height.toDouble(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MarkerPainter extends CustomPainter {
  final List<Offset> markers;
  final Size imageSize;
  final double radius;

  const _MarkerPainter(
      {required this.markers, required this.imageSize, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    const iconData = CupertinoIcons.map_pin_ellipse;

    for (final marker in markers) {
      final mappedOffset = Offset(
        (marker.dx * size.width) / imageSize.width,
        (marker.dy * size.height) / imageSize.height,
      );

      // Draw the radar
      for (int i = 1; i <= 3; i++) {
        final radarPaint = Paint()
          ..color = Colors.red.withOpacity(1 - 0.25 * i)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;
        canvas.drawCircle(mappedOffset, radius * i, radarPaint);
      }

      // Draw the Icon
      TextSpan spn = TextSpan(
          style: TextStyle(
              fontSize: 40,
              color: Colors.red,
              fontFamily: iconData.fontFamily,
              package: iconData.fontPackage),
          text: String.fromCharCode(iconData.codePoint));

      TextPainter tp = TextPainter(
          text: spn,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center);

      tp.layout();
      tp.paint(
          canvas,
          Offset(
              mappedOffset.dx - tp.width / 2, mappedOffset.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
