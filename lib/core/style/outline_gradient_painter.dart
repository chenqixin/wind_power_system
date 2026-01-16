
import 'package:flutter/material.dart';

class OutlineGradientPainter extends CustomPainter {
  final Paint _outlinePaint = Paint();
  final Paint _innerPaint = Paint();
  final double radius;
  final double strokeWidth;
  final Gradient gradient;
  final Color color;

  OutlineGradientPainter({
    required this.strokeWidth,
    required this.radius,
    required this.gradient,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 整体区域
    Rect outerRect = Offset.zero & size;
    var outerRRect =
        RRect.fromRectAndRadius(outerRect, Radius.circular(radius));
    // 内部区域
    Rect innerRect = Rect.fromLTWH(strokeWidth, strokeWidth,
        size.width - strokeWidth * 2, size.height - strokeWidth * 2);
    var innerRRect = RRect.fromRectAndRadius(
        innerRect, Radius.circular(radius - strokeWidth));

    // 边框路径
    Path path1 = Path()..addRRect(outerRRect);
    Path path2 = Path()..addRRect(innerRRect);
    var path = Path.combine(PathOperation.difference, path1, path2);

    _outlinePaint.shader = gradient.createShader(outerRect);
    canvas.drawPath(path, _outlinePaint);

    _innerPaint
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path2, _innerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;

  // Widget _test() {
  //   return CustomPaint(
  //     painter: OutlineGradientPainter(
  //       strokeWidth: 2,
  //       gradient: const LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomLeft,
  //         colors: [
  //           Color(0xE6FFFFFF),
  //           Color(0x80FFFFFF),
  //         ],
  //       ),
  //       radius: 16,
  //       color: const Color(0x80FFFFFF),
  //     ),
  //     child: Container(),
  //   );
  // }
}
