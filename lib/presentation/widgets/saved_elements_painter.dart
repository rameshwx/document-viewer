import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../providers/drawing_provider.dart';

class SavedElementsPainter extends CustomPainter {
  final List<DrawingElement> elements;
  final int? targetPageNumber;
  final double scaleX;
  final double scaleY;

  const SavedElementsPainter({
    required this.elements,
    this.targetPageNumber,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radiusScale = (scaleX + scaleY) / 2;
    for (final el in elements) {
      if (targetPageNumber != null &&
          el.pageNumber != null &&
          el.pageNumber != targetPageNumber) {
        continue;
      }

      final paint = Paint()
        ..color = _colorFromName(el.color)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      if (el.type == 'path' && el.data is String) {
        final path = Path();
        final segments = (el.data as String).split(RegExp(r'(?=[ML])'));
        for (var seg in segments) {
          if (seg.isEmpty) continue;
          final cmd = seg[0];
          final nums = seg.substring(1).trim().split(RegExp(r'\s+'));
          if (nums.length >= 2) {
            final x = (double.tryParse(nums[0]) ?? 0.0) * scaleX;
            final y = (double.tryParse(nums[1]) ?? 0.0) * scaleY;
            if (cmd == 'M') path.moveTo(x, y);
            if (cmd == 'L') path.lineTo(x, y);
          }
        }
        canvas.drawPath(path, paint);
      } else if (el.type == 'circle' && el.data is Map) {
        final m = Map<String, dynamic>.from(el.data);
        canvas.drawCircle(
          Offset(
            (m['cx'] as num).toDouble() * scaleX,
            (m['cy'] as num).toDouble() * scaleY,
          ),
          (m['r'] as num).toDouble() * radiusScale,
          paint,
        );
      } else if (el.type == 'rect' && el.data is Map) {
        final m = Map<String, dynamic>.from(el.data);
        canvas.drawRect(
          Rect.fromLTWH(
            (m['x'] as num).toDouble() * scaleX,
            (m['y'] as num).toDouble() * scaleY,
            (m['width'] as num).toDouble() * scaleX,
            (m['height'] as num).toDouble() * scaleY,
          ),
          paint,
        );
      } else if (el.type == 'ellipse' && el.data is Map) {
        final m = Map<String, dynamic>.from(el.data);
        final cx = (m['cx'] as num).toDouble() * scaleX;
        final cy = (m['cy'] as num).toDouble() * scaleY;
        final rx = (m['rx'] as num).toDouble() * scaleX;
        final ry = (m['ry'] as num).toDouble() * scaleY;
        final rect = Rect.fromCenter(
          center: Offset(cx, cy),
          width: rx * 2,
          height: ry * 2,
        );
        canvas.drawOval(rect, paint);
      } else if (el.type == 'line' && el.data is Map) {
        final m = Map<String, dynamic>.from(el.data);
        final p1 = Offset(
          (m['x1'] as num).toDouble() * scaleX,
          (m['y1'] as num).toDouble() * scaleY,
        );
        final p2 = Offset(
          (m['x2'] as num).toDouble() * scaleX,
          (m['y2'] as num).toDouble() * scaleY,
        );
        canvas.drawLine(p1, p2, paint);
      } else if (el.type == 'polyline' && el.data is List) {
        final pts = (el.data as List)
            .map((e) => Map<String, dynamic>.from(e))
            .map((m) => Offset(
                  (m['x'] as num).toDouble() * scaleX,
                  (m['y'] as num).toDouble() * scaleY,
                ))
            .toList();
        if (pts.length >= 2) {
          final path = Path()..moveTo(pts.first.dx, pts.first.dy);
          for (final pt in pts.skip(1)) {
            path.lineTo(pt.dx, pt.dy);
          }
          canvas.drawPath(path, paint);
        }
      } else if (el.type == 'polygon' && el.data is List) {
        final pts = (el.data as List)
            .map((e) => Map<String, dynamic>.from(e))
            .map((m) => Offset(
                  (m['x'] as num).toDouble() * scaleX,
                  (m['y'] as num).toDouble() * scaleY,
                ))
            .toList();
        if (pts.length >= 3) {
          final path = Path()..moveTo(pts.first.dx, pts.first.dy);
          for (final pt in pts.skip(1)) {
            path.lineTo(pt.dx, pt.dy);
          }
          path.close();
          canvas.drawPath(path, paint);
        }
      } else if (el.type == 'arrow' && el.data is Map) {
        final m = Map<String, dynamic>.from(el.data);
        final s = Offset(
          (m['x1'] as num).toDouble() * scaleX,
          (m['y1'] as num).toDouble() * scaleY,
        );
        final c = Offset(
          (m['x2'] as num).toDouble() * scaleX,
          (m['y2'] as num).toDouble() * scaleY,
        );
        canvas.drawLine(s, c, paint);

        final angle = math.atan2(c.dy - s.dy, c.dx - s.dx);
        const arrowLength = 12.0;
        const arrowAngle = 0.5; // radians (~28.6 degrees)
        final p1 = Offset(
          c.dx - arrowLength * math.cos(angle - arrowAngle),
          c.dy - arrowLength * math.sin(angle - arrowAngle),
        );
        final p2 = Offset(
          c.dx - arrowLength * math.cos(angle + arrowAngle),
          c.dy - arrowLength * math.sin(angle + arrowAngle),
        );
        canvas.drawLine(c, p1, paint);
        canvas.drawLine(c, p2, paint);
      } else if (el.type == 'text' && el.data is Map) {
        final m = Map<String, dynamic>.from(el.data);
        final fontScale = (scaleX + scaleY) / 2;
        final tp = TextPainter(
          text: TextSpan(
            text: m['text'] as String,
            style: TextStyle(
              color: _colorFromName(el.color),
              fontSize: 14 * fontScale,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(
            (m['x'] as num).toDouble() * scaleX,
            (m['y'] as num).toDouble() * scaleY,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SavedElementsPainter old) {
    return old.elements != elements ||
        old.targetPageNumber != targetPageNumber ||
        old.scaleX != scaleX ||
        old.scaleY != scaleY;
  }

  @override
  bool hitTest(Offset position) => false;

  Color _colorFromName(String name) {
    switch (name) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'white':
        return Colors.white;
      default:
        return Colors.black;
    }
  }
}
