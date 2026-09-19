import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';

/// Generic controls shared by the single and split PDF viewers.
class DocumentMainToolbar extends StatelessWidget {
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final bool drawingEnabled;
  final VoidCallback? onToggleDrawing;
  final bool sdEnabled;
  final VoidCallback? onToggleSD;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onResetView;
  final VoidCallback? onShareUrl;
  final VoidCallback? onExportPdf;
  final VoidCallback? onPrint;
  final VoidCallback? onCloseToolbar;
  final bool showDrawingControls;
  final bool showPdfToolsButton;
  final bool pdfToolsEnabled;
  final VoidCallback? onTogglePdfTools;

  const DocumentMainToolbar({
    super.key,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
    required this.drawingEnabled,
    required this.onToggleDrawing,
    required this.sdEnabled,
    required this.onToggleSD,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetView,
    required this.onShareUrl,
    required this.onExportPdf,
    required this.onPrint,
    required this.onCloseToolbar,
    this.showDrawingControls = true,
    this.showPdfToolsButton = true,
    this.pdfToolsEnabled = false,
    this.onTogglePdfTools,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    Widget button({
      required Widget child,
      required String tooltip,
      required VoidCallback? onPressed,
      bool enabled = true,
      Color? color,
    }) {
      return Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: enabled ? onPressed : null,
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: color ?? Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(child: child),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(
          child: const Icon(Icons.arrow_back, size: 20),
          tooltip: loc.nmx_backward,
          onPressed: onBack,
          enabled: canGoBack,
        ),
        button(
          child: const Icon(Icons.arrow_forward, size: 20),
          tooltip: loc.nmx_forward,
          onPressed: onForward,
          enabled: canGoForward,
        ),
        if (showDrawingControls)
          button(
            child: SvgPicture.asset(
              'assets/tab_toolbar/tab-toolbar-graphics-draw.svg',
              width: 20,
              height: 20,
            ),
            tooltip: drawingEnabled
                ? loc.nmx_svg_tooltip_disableDrawing
                : loc.nmx_svg_tooltip_enableDrawing,
            onPressed: onToggleDrawing,
            color: drawingEnabled ? Colors.yellow.shade100 : null,
          ),
        button(
          child: const Icon(Icons.layers_outlined, size: 20),
          tooltip: 'Drawing layer',
          onPressed: onToggleSD,
          color: sdEnabled ? Colors.grey.shade100 : null,
        ),
        if (showPdfToolsButton)
          button(
            child: const Icon(Icons.picture_as_pdf, size: 20),
            tooltip: loc.nmx_pdfTools,
            onPressed: onTogglePdfTools,
            color: pdfToolsEnabled ? Colors.grey.shade200 : null,
          ),
        button(
          child: SvgPicture.asset(
            'assets/tab_toolbar/tab-toolbar-graphics-zoom-in.svg',
            width: 20,
            height: 20,
          ),
          tooltip: loc.nmx_zoomIn,
          onPressed: onZoomIn,
        ),
        button(
          child: SvgPicture.asset(
            'assets/tab_toolbar/tab-toolbar-graphics-toolbar-zoom-out.svg',
            width: 20,
            height: 20,
          ),
          tooltip: loc.nmx_zoomOut,
          onPressed: onZoomOut,
        ),
        button(
          child: SvgPicture.asset(
            'assets/tab_toolbar/tab-toolbar-graphics-reset.svg',
            width: 20,
            height: 20,
          ),
          tooltip: loc.nmx_resetView,
          onPressed: onResetView,
        ),
        button(
          child: SvgPicture.asset(
            'assets/tab_toolbar/tab-toolbar-share-url.svg',
            width: 20,
            height: 20,
          ),
          tooltip: 'Share document',
          onPressed: onShareUrl,
        ),
        button(
          child: SvgPicture.asset(
            'assets/tab_toolbar/tab-toolbar-pdf-download.svg',
            width: 20,
            height: 20,
          ),
          tooltip: loc.nmx_svg_tooltip_exportPdf,
          onPressed: onExportPdf,
        ),
        button(
          child: SvgPicture.asset(
            'assets/tab_toolbar/tab-toolbar-graphics-print.svg',
            width: 20,
            height: 20,
          ),
          tooltip: loc.nmx_printDoc,
          onPressed: onPrint,
        ),
        button(
          child: const Icon(Icons.close, size: 20),
          tooltip: loc.nmx_closePanel,
          onPressed: onCloseToolbar,
        ),
      ],
    );
  }
}
