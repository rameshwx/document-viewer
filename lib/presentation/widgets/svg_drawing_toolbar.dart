import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../providers/drawing_provider.dart';

class SvgDrawingToolbar extends StatelessWidget {
  final DrawingState drawingState;
  final DrawingNotifier drawingNotifier;
  final VoidCallback onSave;

  const SvgDrawingToolbar({
    super.key,
    required this.drawingState,
    required this.drawingNotifier,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    Widget toolButton({
      required IconData icon,
      required String tooltip,
      required VoidCallback? onPressed,
      bool isSelected = false,
    }) {
      return Tooltip(
        message: tooltip,
        child: IconButton(
          icon: Icon(icon, size: 20, color: Colors.white),
          onPressed: onPressed,
          color: isSelected ? Colors.white24 : null,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
        ),
      );
    }

    return Container(
      color: Colors.black87,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drawing toggle
          toolButton(
            icon: drawingState.isEnabled ? Icons.brush : Icons.brush_outlined,
            tooltip: drawingState.isEnabled
                ? loc.nmx_svg_tooltip_disableDrawing
                : loc.nmx_svg_tooltip_enableDrawing,
            onPressed: drawingNotifier.toggleDrawing,
            isSelected: drawingState.isEnabled,
          ),
          // Text mode toggle
          toolButton(
            icon: Icons.text_fields,
            tooltip: drawingState.isTextMode
                ? loc.nmx_svg_tooltip_disableText
                : loc.nmx_svg_tooltip_enableText,
            onPressed: drawingNotifier.toggleTextMode,
            isSelected: drawingState.isTextMode,
          ),
          if (drawingState.isEnabled && !drawingState.isTextMode) ...[
            // Freehand path
            toolButton(
              icon: Icons.gesture,
              tooltip: loc.nmx_svg_tooltip_freehand,
              onPressed: () => drawingNotifier.setShape('freehand'),
              isSelected: drawingState.selectedShape == 'freehand',
            ),
            // Rectangle
            toolButton(
              icon: Icons.crop_square,
              tooltip: loc.nmx_svg_tooltip_rectangle,
              onPressed: () => drawingNotifier.setShape('rect'),
              isSelected: drawingState.selectedShape == 'rect',
            ),
            // Circle
            toolButton(
              icon: Icons.circle_outlined,
              tooltip: loc.nmx_svg_tooltip_circle,
              onPressed: () => drawingNotifier.setShape('circle'),
              isSelected: drawingState.selectedShape == 'circle',
            ),
            // Ellipse
            toolButton(
              icon: Icons.trip_origin,
              tooltip: loc.nmx_svg_tooltip_ellipse,
              onPressed: () => drawingNotifier.setShape('ellipse'),
              isSelected: drawingState.selectedShape == 'ellipse',
            ),
            // Line
            toolButton(
              icon: Icons.horizontal_rule,
              tooltip: loc.nmx_svg_tooltip_line,
              onPressed: () => drawingNotifier.setShape('line'),
              isSelected: drawingState.selectedShape == 'line',
            ),
            // Polyline
            toolButton(
              icon: Icons.show_chart,
              tooltip: loc.nmx_svg_tooltip_polyline,
              onPressed: () => drawingNotifier.setShape('polyline'),
              isSelected: drawingState.selectedShape == 'polyline',
            ),
            // Polygon
            toolButton(
              icon: Icons.change_history,
              tooltip: loc.nmx_svg_tooltip_polygon,
              onPressed: () => drawingNotifier.setShape('polygon'),
              isSelected: drawingState.selectedShape == 'polygon',
            ),
            // Arrow
            toolButton(
              icon: Icons.arrow_right_alt,
              tooltip: loc.nmx_svg_tooltip_arrow,
              onPressed: () => drawingNotifier.setShape('arrow'),
              isSelected: drawingState.selectedShape == 'arrow',
            ),
          ],
          if (drawingState.isEnabled) ...[
            toolButton(
              icon: Icons.undo,
              tooltip: loc.nmx_svg_tooltip_undo,
              onPressed: drawingState.canUndo
                  ? () {
                      drawingNotifier.undo();
                      onSave();
                    }
                  : null,
            ),
            toolButton(
              icon: Icons.redo,
              tooltip: loc.nmx_svg_tooltip_redo,
              onPressed: drawingState.canRedo
                  ? () {
                      drawingNotifier.redo();
                      onSave();
                    }
                  : null,
            ),
            toolButton(
              icon: Icons.save,
              tooltip: loc.nmx_svg_tooltip_saveDrawings,
              onPressed: onSave,
            ),
            toolButton(
              icon: Icons.delete_outline,
              tooltip: loc.nmx_svg_tooltip_clearDrawings,
              onPressed: () {
                drawingNotifier.clearElements();
                onSave();
              },
            ),
          ],
        ],
      ),
    );
  }
}
