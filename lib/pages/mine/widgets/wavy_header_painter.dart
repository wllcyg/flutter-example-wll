import 'package:flutter/material.dart';

/// 一个精美的贝塞尔曲线波浪背景绘制器
class WavyHeaderPainter extends CustomPainter {
  final Color color;

  WavyHeaderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // 起点是左上角 (0, 0)
    path.lineTo(0, size.height * 0.85);

    // 第一段波浪 (贝塞尔曲线)
    // 控制点 (x1, y1), 终点 (x2, y2)
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    // 第二段波浪
    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    // 封口到右上角
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavyHeaderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
