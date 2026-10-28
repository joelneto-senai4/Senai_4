import 'package:flutter/material.dart';

/// Mesma imagem ilustrativa neutra do wireframe, desenhada em vetor.
class PlaceArt extends StatelessWidget {
  final String categoria;
  final bool large;
  const PlaceArt({super.key, required this.categoria, this.large = false});
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _PlaceholderPainter(),
    child: const SizedBox.expand(),
  );
}

class _PlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFD0D2D2), BlendMode.src);
    final side = size.shortestSide * .92;
    final x = (size.width - side) / 2;
    final y = (size.height - side) / 2;
    final p = Paint()..color = const Color(0xFFB2B5B5);
    canvas.drawCircle(Offset(x + side * .38, y + side * .27), side * .075, p);
    canvas.drawPath(
      Path()
        ..moveTo(x + side * .12, y + side * .76)
        ..lineTo(x + side * .36, y + side * .49)
        ..lineTo(x + side * .49, y + side * .61)
        ..lineTo(x + side * .65, y + side * .38)
        ..lineTo(x + side * .90, y + side * .76)
        ..close(),
      p,
    );
  }

  @override
  bool shouldRepaint(_PlaceholderPainter oldDelegate) => false;
}
