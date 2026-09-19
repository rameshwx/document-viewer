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
    final scheme = Theme.of(context).colorScheme;

    Widget toolButton({
      required IconData icon,
      required String tooltip,
      required VoidCallback? onPressed,
      bool isSelected = false,
    }) {
      return Tooltip(
        message: tooltip,
        child: IconButton(
          icon: Icon(icon, size: 20),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            foregroundColor: scheme.onSurface,
            backgroundColor:
                isSelected ? scheme.secondaryContainer : Colors.transparent,
          ),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
        ),
      );
    }

    Color colorFromName(String name) {
      switch (name) {
        case 'red':
          return Colors.red;
        case 'green':
          return Colors.green;
        case 'yellow':
          return Colors.yellow;
        default:
          return Colors.black;
      }
    }

    String colorLabel(String name) {
      switch (name) {
        case 'red':
          return loc.nmx_svg_color_red;
        case 'green':
          return loc.nmx_svg_color_green;
        case 'yellow':
          return loc.nmx_svg_color_yellow;
        default:
          return loc.nmx_svg_color_black;
      }
    }

    PopupMenuEntry<String> colorOption(String name) {
      return PopupMenuItem<String>(
        value: name,
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colorFromName(name),
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outline),
              ),
            ),
            const SizedBox(width: 10),
            Text(colorLabel(name)),
          ],
        ),
      );
    }

    Widget colorButton() {
      return Tooltip(
        message: loc.nmx_svg_tooltip_color,
        child: PopupMenuButton<String>(
          tooltip: loc.nmx_svg_tooltip_color,
          initialValue: drawingState.selectedColor,
          onSelected: drawingNotifier.setColor,
          color: scheme.surfaceContainer,
          icon: Icon(
            Icons.palette_outlined,
            size: 20,
            color: colorFromName(drawingState.selectedColor),
          ),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
          itemBuilder: (_) => [
            colorOption('black'),
            colorOption('red'),
            colorOption('green'),
            colorOption('yellow'),
          ],
        ),
      );
    }

    return Container(
      color: scheme.surfaceContainer,
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
          if (drawingState.isEnabled) colorButton(),
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
