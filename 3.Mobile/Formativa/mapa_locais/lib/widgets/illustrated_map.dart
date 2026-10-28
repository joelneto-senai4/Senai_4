import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/local.dart';
import 'shared.dart';

class IllustratedMap extends StatelessWidget {
  final List<Local> locais;
  final Local? selected;
  final ValueChanged<Local> onSelect;
  final VoidCallback? onOpen;
  final bool compacto, contrast;
  final double bottomInset;
  const IllustratedMap({
    super.key,
    required this.locais,
    required this.onSelect,
    this.selected,
    this.onOpen,
    this.compacto = false,
    this.contrast = false,
    this.bottomInset = 0,
  });
  @override
  Widget build(BuildContext context) => ClipRect(
    child: LayoutBuilder(
      builder: (context, bounds) => Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _StreetPainter(contrast)),
          ),
          if (!compacto)
            Positioned(
              left: bounds.maxWidth * .5 - 30,
              top: bounds.maxHeight * .39 - 30,
              child: IgnorePointer(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0x243C9EEF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x3EFFFFFF),
                      width: 5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 17,
                      height: 17,
                      decoration: BoxDecoration(
                        color: const Color(0xFF399CE7),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          for (final local in locais) _marker(bounds, local),
        ],
      ),
    ),
  );
  Widget _marker(BoxConstraints bounds, Local local) {
    final active = selected?.id == local.id;
    final x = (bounds.maxWidth - 36) * local.mapaX;
    final y =
        (bounds.maxHeight - 44 - bottomInset).clamp(1.0, double.infinity) *
        local.mapaY;
    if (active && !compacto) {
      return Positioned(
        left: (x - 10).clamp(8.0, math.max(8.0, bounds.maxWidth - 184)),
        top: y,
        child: Tooltip(
          message: local.nome,
          child: Semantics(
            button: true,
            label: 'Marcador ${local.nome}',
            child: Material(
              color: papel,
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: onOpen ?? () => onSelect(local),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 7, 11, 7),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 27,
                        color: Color(0xFF5C6263),
                      ),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 132),
                        child: Text(
                          local.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: tinta),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Positioned(
      left: x,
      top: y,
      child: Tooltip(
        message: local.nome,
        child: Semantics(
          label: 'Marcador ${local.nome}',
          button: true,
          child: InkWell(
            onTap: () => onSelect(local),
            borderRadius: BorderRadius.circular(24),
            child: const SizedBox(
              width: 36,
              height: 40,
              child: Icon(
                Icons.location_on,
                size: 33,
                color: Color(0xFF5C6263),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StreetPainter extends CustomPainter {
  final bool contrast;
  _StreetPainter(this.contrast);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 390, size.height / 680);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 390, 680),
      Paint()
        ..color = contrast ? const Color(0xFFD5D9D9) : const Color(0xFFE5E8E7),
    );
    final p = Paint();
    // Quadras pequenas, com ruas claras e orientação semelhante à referência.
    canvas.save();
    canvas.translate(195, 340);
    canvas.rotate(-.62);
    final rng = math.Random(391);
    for (var x = -750; x < 750; x += 32) {
      for (var y = -750; y < 750; y += 44) {
        p.color = Color.lerp(
          const Color(0xFFD9DEDC),
          const Color(0xFFE8EBE9),
          rng.nextDouble(),
        )!;
        canvas.drawRect(Rect.fromLTWH(x + 3.0, y + 3.0, 25, 37), p);
        p.color = const Color(0xFFEFF1EF);
        canvas.drawRect(
          Rect.fromLTWH(
            x + 6.0,
            y + 7.0,
            8 + rng.nextDouble() * 10,
            10 + rng.nextDouble() * 14,
          ),
          p,
        );
      }
    }
    p
      ..color = const Color(0xFFFAFBFA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.3;
    for (var x = -750; x < 750; x += 32) {
      canvas.drawLine(Offset(x.toDouble(), -750), Offset(x.toDouble(), 750), p);
    }
    for (var y = -750; y < 750; y += 44) {
      canvas.drawLine(Offset(-750, y.toDouble()), Offset(750, y.toDouble()), p);
    }
    canvas.restore();
    p
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFD8E2DC);
    canvas.drawPath(
      Path()
        ..moveTo(25, 427)
        ..lineTo(62, 449)
        ..lineTo(73, 499)
        ..lineTo(36, 536)
        ..lineTo(1, 505)
        ..close(),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(277, 384)
        ..lineTo(330, 400)
        ..lineTo(350, 453)
        ..lineTo(310, 468)
        ..lineTo(272, 432)
        ..close(),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(260, 579)
        ..lineTo(310, 561)
        ..lineTo(338, 603)
        ..lineTo(307, 650)
        ..lineTo(262, 630)
        ..close(),
      p,
    );
    canvas.drawOval(const Rect.fromLTWH(67, 555, 61, 85), p);
    void road(Path path, double width) {
      p
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFD4DAD7)
        ..strokeWidth = width + 2;
      canvas.drawPath(path, p);
      p
        ..color = const Color(0xFFFCFDFC)
        ..strokeWidth = width;
      canvas.drawPath(path, p);
    }

    road(
      Path()
        ..moveTo(-30, 58)
        ..cubicTo(80, 150, 117, 238, 196, 354)
        ..cubicTo(260, 447, 330, 530, 426, 610),
      9,
    );
    road(
      Path()
        ..moveTo(18, -30)
        ..cubicTo(81, 118, 168, 86, 231, 24)
        ..cubicTo(292, -22, 344, 15, 416, 94),
      6,
    );
    road(
      Path()
        ..moveTo(410, 128)
        ..cubicTo(289, 187, 212, 226, 143, 331)
        ..cubicTo(69, 454, 16, 555, -20, 682),
      8,
    );
    road(
      Path()
        ..moveTo(-20, 278)
        ..cubicTo(100, 248, 219, 357, 407, 344),
      5,
    );
    road(
      Path()
        ..moveTo(100, 720)
        ..cubicTo(215, 593, 290, 538, 416, 497),
      6,
    );
    road(
      Path()
        ..moveTo(-30, 534)
        ..cubicTo(98, 475, 179, 508, 260, 581)
        ..cubicTo(309, 625, 358, 646, 410, 665),
      10,
    );
    // A avenida mais larga corta a parte inferior do mapa.
    final avenue = Path()
      ..moveTo(-25, 424)
      ..cubicTo(91, 492, 232, 571, 415, 651);
    p
      ..color = const Color(0xFFBFC6C3)
      ..strokeWidth = 22;
    canvas.drawPath(avenue, p);
    p
      ..color = const Color(0xFFE2E6E3)
      ..strokeWidth = 12;
    canvas.drawPath(avenue, p);
    p
      ..color = const Color(0xFFF8FAF7)
      ..strokeWidth = 1.6;
    canvas.drawPath(avenue, p);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StreetPainter old) => contrast != old.contrast;
}
