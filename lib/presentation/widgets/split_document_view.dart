import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/document_print.dart';
import '../../core/utils/document_share_util.dart';
import '../../domain/entities/document.dart';
import '../providers/drawing_provider.dart';
import '../providers/tabs_provider.dart';
import 'document_main_toolbar.dart';
import 'document_view.dart';
import 'svg_drawing_toolbar.dart';

class SplitDocumentView extends ConsumerStatefulWidget {
  final String tabId;
  final Document leftDocument;
  final Document? rightDocument;

  const SplitDocumentView({
    super.key,
    required this.tabId,
    required this.leftDocument,
    this.rightDocument,
  });

  @override
  ConsumerState<SplitDocumentView> createState() => _SplitDocumentViewState();
}

class _SplitDocumentViewState extends ConsumerState<SplitDocumentView> {
  double _dividerPosition = 0.5;
  bool _isHovering = false;
  bool _toolbarOpen = true;
  String _activePane = 'L';
  late final DocumentViewController _leftController;
  late final DocumentViewController _rightController;

  @override
  void initState() {
    super.initState();
    _leftController = DocumentViewController();
    _rightController = DocumentViewController();
  }

  Document get _activeDocument =>
      _activePane == 'L' || widget.rightDocument == null
          ? widget.leftDocument
          : widget.rightDocument!;

  String get _activePaneId => '${widget.tabId}::$_activePane';

  Future<void> _shareActiveDocument() => shareBundledDocument(
        assetPath: _activeDocument.path,
        title: _activeDocument.pageBlock,
      );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;
    final drawingState = ref.watch(drawingProviderFamily(_activePaneId));
    final drawingNotifier =
        ref.read(drawingProviderFamily(_activePaneId).notifier);
    final paneIndex = _activePane == 'L' ? 0 : 1;
    final tabsNotifier = ref.read(tabsProvider.notifier);
    final canBack = tabsNotifier.canGoBackInSplitPane(paneIndex);
    final canForward = tabsNotifier.canGoForwardInSplitPane(paneIndex);
    final activeController =
        _activePane == 'L' ? _leftController : _rightController;

    final toolbar = _toolbarOpen
        ? Container(
            color: Colors.grey.shade100,
            height: isSmallScreen ? 48 : 52,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DocumentMainToolbar(
                canGoBack: canBack,
                canGoForward: canForward,
                onBack: canBack
                    ? () => tabsNotifier.goBackInSplitPane(paneIndex)
                    : null,
                onForward: canForward
                    ? () => tabsNotifier.goForwardInSplitPane(paneIndex)
                    : null,
                drawingEnabled: drawingState.isEnabled,
                onToggleDrawing: drawingNotifier.toggleDrawing,
                sdEnabled: drawingState.sdEnabled,
                onToggleSD: drawingNotifier.toggleSD,
                onZoomIn: activeController.zoomIn,
                onZoomOut: activeController.zoomOut,
                onResetView: activeController.resetZoom,
                onShareUrl: _shareActiveDocument,
                onExportPdf: activeController.exportToPdf,
                onPrint: printDocument,
                onCloseToolbar: () => setState(() => _toolbarOpen = false),
                showDrawingControls: true,
                showPdfToolsButton: true,
                onTogglePdfTools: () {},
              ),
            ),
          )
        : SizedBox(
            height: 36,
            child: IconButton(
              tooltip: 'Show viewer toolbar',
              onPressed: () => setState(() => _toolbarOpen = true),
              icon: const Icon(Icons.expand_more),
            ),
          );

    final drawingToolbar = (drawingState.isEnabled || drawingState.isTextMode)
        ? SvgDrawingToolbar(
            drawingState: drawingState,
            drawingNotifier: drawingNotifier,
            onSave: () => activeController.saveDrawings?.call(),
          )
        : null;

    return Column(
      children: [
        toolbar,
        if (drawingToolbar != null) drawingToolbar,
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: (_dividerPosition * 1000).round(),
                child: _buildPane(
                  document: widget.leftDocument,
                  pane: 'L',
                  controller: _leftController,
                ),
              ),
              MouseRegion(
                onEnter: (_) => setState(() => _isHovering = true),
                onExit: (_) => setState(() => _isHovering = false),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: (details) => setState(() {
                    _dividerPosition =
                        (_dividerPosition + details.delta.dx / screenWidth)
                            .clamp(isSmallScreen ? 0.3 : 0.2,
                                isSmallScreen ? 0.7 : 0.8);
                  }),
                  child: Container(
                    width: 8,
                    color: _isHovering
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3)
                        : Colors.grey.shade300,
                    child: Center(
                      child: Container(
                        width: 3,
                        height: 50,
                        color: _isHovering
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: ((1 - _dividerPosition) * 1000).round(),
                child: widget.rightDocument == null
                    ? const Center(
                        child: Text('Choose a second document from the list.'))
                    : _buildPane(
                        document: widget.rightDocument!,
                        pane: 'R',
                        controller: _rightController,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPane({
    required Document document,
    required String pane,
    required DocumentViewController controller,
  }) {
    return Listener(
      onPointerDown: (_) => setState(() => _activePane = pane),
      child: Stack(
        children: [
          DocumentView(
            key: ValueKey('${widget.tabId}::$pane::${document.id}'),
            document: document,
            paneId: '${widget.tabId}::$pane',
            showToolbar: false,
            controller: controller,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 26,
            child: Container(
              color: _activePane == pane
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      document.pageBlock,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _activePane == pane
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    onPressed: () => ref
                        .read(tabsProvider.notifier)
                        .closeDocumentInSplitView(
                            widget.tabId, pane == 'L' ? 0 : 1),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
