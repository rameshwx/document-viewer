import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../providers/drawing_provider.dart';
import '../../l10n/app_localizations.dart';

typedef OnElementComplete = void Function(DrawingElement element);

class DrawingOverlay extends StatefulWidget {
  final DrawingState drawingState;
  final OnElementComplete onElementComplete;
  final TransformationController transformationController;
  final ValueChanged<Offset>? onScroll;

  const DrawingOverlay({
    super.key,
    required this.drawingState,
    required this.onElementComplete,
    required this.transformationController,
    this.onScroll,
  });

  @override
  State<DrawingOverlay> createState() => _DrawingOverlayState();
}

class _DrawingOverlayState extends State<DrawingOverlay> {
  List<Offset> _points = [];
  Offset? _startPoint;
  Offset? _currentPoint;
  final TextEditingController _textController = TextEditingController();
  bool _isEditingText = false;
  Offset? _textPosition;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addTextAnnotation(String text) {
    if (text.trim().isNotEmpty && _textPosition != null) {
      widget.onElementComplete(DrawingElement(
        type: 'text',
        color: widget.drawingState.selectedColor,
        data: {
          'x': _textPosition!.dx,
          'y': _textPosition!.dy,
          'text': text.trim(),
        },
      ));
    }
    setState(() {
      _isEditingText = false;
      _textPosition = null;
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.drawingState.isEnabled) return const SizedBox.shrink();

    final shape = widget.drawingState.selectedShape;
    final color = widget.drawingState.selectedColor;
    final isTextMode = widget.drawingState.isTextMode;

    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          widget.onScroll?.call(event.scrollDelta);
        }
      },
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              if (isTextMode) {
                setState(() {
                  _textPosition = details.localPosition;
                  _isEditingText = true;
                });
              }
            },
            onPanStart: (details) {
              if (!isTextMode) {
                setState(() {
                  _points = [details.localPosition];
                  _startPoint = details.localPosition;
                  _currentPoint = null;
                });
              }
            },
            onPanUpdate: (details) {
              if (!isTextMode) {
                setState(() {
                  if (shape == 'freehand' ||
                      shape == 'polyline' ||
                      shape == 'polygon') {
                    _points = [..._points, details.localPosition];
                  } else {
                    _currentPoint = details.localPosition;
                  }
                });
              }
            },
            onPanEnd: (details) {
              if (!isTextMode) {
                if ((shape == 'freehand' ||
                        shape == 'polyline' ||
                        shape == 'polygon') &&
                    _points.isNotEmpty) {
                  if (shape == 'freehand') {
                    final buf = StringBuffer(
                        'M${_points.first.dx} ${_points.first.dy}');
                    for (var pt in _points.skip(1)) {
                      buf.write(' L${pt.dx} ${pt.dy}');
                    }
                    widget.onElementComplete(DrawingElement(
                      type: 'path',
                      color: color,
                      data: buf.toString(),
                    ));
                  } else {
                    final pts =
                        _points.map((p) => {'x': p.dx, 'y': p.dy}).toList();
                    if (shape == 'polygon' && pts.length >= 3) {
                      final first = pts.first;
                      final last = pts.last;
                      final fx = (first['x'] as num).toDouble();
                      final fy = (first['y'] as num).toDouble();
                      final lx = (last['x'] as num).toDouble();
                      final ly = (last['y'] as num).toDouble();
                      if (fx != lx || fy != ly) {
                        pts.add({'x': fx, 'y': fy});
                      }
                    }
                    widget.onElementComplete(DrawingElement(
                      type: shape,
                      color: color,
                      data: pts,
                    ));
                  }
                } else if (_startPoint != null && _currentPoint != null) {
                  final s = _startPoint!;
                  final c = _currentPoint!;
                  if (shape == 'circle') {
                    final dx = c.dx - s.dx, dy = c.dy - s.dy;
                    final r = math.sqrt(dx * dx + dy * dy) / 2;
                    widget.onElementComplete(DrawingElement(
                      type: 'circle',
                      color: color,
                      data: {
                        'cx': (s.dx + c.dx) / 2,
                        'cy': (s.dy + c.dy) / 2,
                        'r': r,
                      },
                    ));
                  } else if (shape == 'square' ||
                      shape == 'rect' ||
                      shape == 'rectangle') {
                    final left = math.min(s.dx, c.dx);
                    final top = math.min(s.dy, c.dy);
                    final w = (s.dx - c.dx).abs();
                    final h = (s.dy - c.dy).abs();
                    widget.onElementComplete(DrawingElement(
                      type: 'rect',
                      color: color,
                      data: {'x': left, 'y': top, 'width': w, 'height': h},
                    ));
                  } else if (shape == 'ellipse') {
                    final left = math.min(s.dx, c.dx);
                    final top = math.min(s.dy, c.dy);
                    final w = (s.dx - c.dx).abs();
                    final h = (s.dy - c.dy).abs();
                    widget.onElementComplete(DrawingElement(
                      type: 'ellipse',
                      color: color,
                      data: {
                        'cx': left + w / 2,
                        'cy': top + h / 2,
                        'rx': w / 2,
                        'ry': h / 2,
                      },
                    ));
                  } else if (shape == 'line' || shape == 'arrow') {
                    widget.onElementComplete(DrawingElement(
                      type: shape,
                      color: color,
                      data: {
                        'x1': s.dx,
                        'y1': s.dy,
                        'x2': c.dx,
                        'y2': c.dy,
                      },
                    ));
                  }
                }
              }
              setState(() {
                _points = [];
                _startPoint = null;
                _currentPoint = null;
              });
            },
            child: CustomPaint(
              painter: _OverlayPainter(
                points: _points,
                startPoint: _startPoint,
                currentPoint: _currentPoint,
                shape: shape,
                color: color,
              ),
              size: Size.infinite,
            ),
          ),
          if (_isEditingText && _textPosition != null)
            Positioned(
              left: _textPosition!.dx,
              top: _textPosition!.dy - 20,
              child: _buildTextInput(),
            ),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    final loc = AppLocalizations.of(context)!;
    return Container(
      width: 200,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: loc.nmx_enterAnnotation),
            autofocus: true,
            onSubmitted: _addTextAnnotation,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() {
                  _isEditingText = false;
                  _textPosition = null;
                  _textController.clear();
                }),
                child:
                    Text(loc.nmx_cancel, style: const TextStyle(fontSize: 12)),
              ),
              TextButton(
                onPressed: () => _addTextAnnotation(_textController.text),
                child: Text(loc.nmx_add, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final List<Offset> points;
  final Offset? startPoint, currentPoint;
  final String shape, color;

  _OverlayPainter({
    required this.points,
    this.startPoint,
    this.currentPoint,
    required this.shape,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _colorFromName(color)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (shape == 'freehand' && points.isNotEmpty) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var pt in points.skip(1)) {
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, paint);
    }

    if (startPoint != null && currentPoint != null && shape != 'freehand') {
      final s = startPoint!, c = currentPoint!;
      if (shape == 'circle') {
        final dx = c.dx - s.dx, dy = c.dy - s.dy;
        final r = math.sqrt(dx * dx + dy * dy) / 2;
        final center = Offset((s.dx + c.dx) / 2, (s.dy + c.dy) / 2);
        canvas.drawCircle(center, r, paint);
      } else if (shape == 'square' || shape == 'rect' || shape == 'rectangle') {
        final left = math.min(s.dx, c.dx), top = math.min(s.dy, c.dy);
        final rect =
            Rect.fromLTWH(left, top, (s.dx - c.dx).abs(), (s.dy - c.dy).abs());
        canvas.drawRect(rect, paint);
      } else if (shape == 'ellipse') {
        final left = math.min(s.dx, c.dx), top = math.min(s.dy, c.dy);
        final w = (s.dx - c.dx).abs();
        final h = (s.dy - c.dy).abs();
        final rect = Rect.fromLTWH(left, top, w, h);
        canvas.drawOval(rect, paint);
      } else if (shape == 'line' || shape == 'arrow') {
        canvas.drawLine(s, c, paint);
        if (shape == 'arrow') {
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
        }
      }
    }

    if ((shape == 'polyline' || shape == 'polygon') && points.isNotEmpty) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final pt in points.skip(1)) {
        path.lineTo(pt.dx, pt.dy);
      }
      if (shape == 'polygon' && points.length > 2) {
        path.close();
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) {
    return old.points != points ||
        old.startPoint != startPoint ||
        old.currentPoint != currentPoint ||
        old.shape != shape ||
        old.color != color;
  }

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
