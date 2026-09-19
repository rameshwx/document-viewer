import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/document_print.dart';
import '../../core/utils/document_share_util.dart';
import '../../domain/entities/document.dart';
import '../../l10n/app_localizations.dart';
import '../providers/drawing_provider.dart';
import '../providers/pdf_viewer_provider.dart';
import '../providers/tabs_provider.dart';
import '../screens/pdf_document_view.dart';
import 'document_main_toolbar.dart';
import 'pdf_toolbar.dart';
import 'svg_drawing_toolbar.dart';

class DocumentViewController {
  VoidCallback? zoomIn;
  VoidCallback? zoomOut;
  VoidCallback? resetZoom;
  VoidCallback? exportToPdf;
  VoidCallback? saveDrawings;
}

class DocumentView extends ConsumerStatefulWidget {
  final Document? document;
  final String paneId;
  final bool showToolbar;
  final DocumentViewController? controller;

  const DocumentView({
    super.key,
    this.document,
    required this.paneId,
    this.showToolbar = true,
    this.controller,
  });

  @override
  ConsumerState<DocumentView> createState() => _DocumentViewState();
}

class _DocumentViewState extends ConsumerState<DocumentView> {
  final GlobalKey<PdfDocumentViewState> _pdfKey =
      GlobalKey<PdfDocumentViewState>();
  final TextEditingController _pageController =
      TextEditingController(text: '1');
  final TextEditingController _findController = TextEditingController();
  bool _toolbarOpen = true;
  bool _pdfToolsVisible = false;
  bool _highlightAll = true;
  bool _matchCase = false;
  bool _matchDiacritics = false;
  bool _wholeWords = false;

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  @override
  void didUpdateWidget(covariant DocumentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) _attachController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _findController.dispose();
    super.dispose();
  }

  void _attachController() {
    final controller = widget.controller;
    if (controller == null) return;
    controller.zoomIn = _zoomIn;
    controller.zoomOut = _zoomOut;
    controller.resetZoom = _resetZoom;
    controller.exportToPdf = () => _pdfKey.currentState?.downloadDocument();
    controller.saveDrawings = () => _pdfKey.currentState?.saveDrawings();
  }

  void _zoomIn() => _pdfKey.currentState?.zoomBy(1.2);
  void _zoomOut() => _pdfKey.currentState?.zoomBy(1 / 1.2);
  void _resetZoom() => _pdfKey.currentState?.resetZoom();

  void _onPageChanged(int page, int count) {
    _pageController.text = '$page';
    ref
        .read(pdfViewerProviderFamily(widget.paneId).notifier)
        .setPage(page, count);
  }

  void _onScaleChanged(double scale) {
    ref.read(pdfViewerProviderFamily(widget.paneId).notifier).setScale(scale);
  }

  void _onFindResult(int current, int total) {
    ref
        .read(pdfViewerProviderFamily(widget.paneId).notifier)
        .setFindResult(current, total);
  }

  void _sendFind({bool previous = false}) {
    final query = _findController.text;
    final notifier = ref.read(pdfViewerProviderFamily(widget.paneId).notifier);
    notifier.setFindQuery(query);
    _pdfKey.currentState?.find(
      query: query,
      highlightAll: _highlightAll,
      caseSensitive: _matchCase,
      matchDiacritics: _matchDiacritics,
      entireWord: _wholeWords,
      findPrevious: previous,
    );
  }

  Future<void> _shareDocument() async {
    final document = widget.document;
    if (document == null) return;
    await shareBundledDocument(
      assetPath: document.path,
      title: document.pageBlock,
    );
  }

  Widget _buildPdfToolbar(PdfViewerState state) {
    return PdfToolbar(
      state: state,
      pageController: _pageController,
      findController: _findController,
      onFirstPage: () => _pdfKey.currentState?.firstPage(),
      onPrevPage: () => _pdfKey.currentState?.previousPage(),
      onNextPage: () => _pdfKey.currentState?.nextPage(),
      onLastPage: () => _pdfKey.currentState?.lastPage(),
      onPageSubmitted: (value) {
        final page = int.tryParse(value);
        if (page != null) _pdfKey.currentState?.goToPage(page);
      },
      onRotateLeft: () => _pdfKey.currentState?.rotate(-90),
      onRotateRight: () => _pdfKey.currentState?.rotate(90),
      onZoomIn: _zoomIn,
      onZoomOut: _zoomOut,
      onFindPrev: () => _sendFind(previous: true),
      onFindNext: _sendFind,
      onToggleHighlightAll: () {
        setState(() => _highlightAll = !_highlightAll);
        _sendFind();
      },
      onToggleMatchCase: () {
        setState(() => _matchCase = !_matchCase);
        _sendFind();
      },
      onToggleMatchDiacritics: () {
        setState(() => _matchDiacritics = !_matchDiacritics);
        _sendFind();
      },
      onToggleWholeWords: () {
        setState(() => _wholeWords = !_wholeWords);
        _sendFind();
      },
      onScrollMode: (mode) {
        ref
            .read(pdfViewerProviderFamily(widget.paneId).notifier)
            .setScrollMode(mode);
        _pdfKey.currentState?.setScrollMode(mode.name);
      },
      onSpreadMode: (mode) {
        ref
            .read(pdfViewerProviderFamily(widget.paneId).notifier)
            .setSpreadMode(mode);
        _pdfKey.currentState?.setSpreadMode(mode.name);
      },
      onHandTool: (enabled) {
        ref
            .read(pdfViewerProviderFamily(widget.paneId).notifier)
            .setHandTool(enabled);
        _pdfKey.currentState?.setHandTool(enabled);
      },
      onShowOutline: () => _pdfKey.currentState?.showOutline(context),
      onShowThumbnails: () => _pdfKey.currentState?.showThumbnails(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final document = widget.document;
    if (document == null) {
      return Center(child: Text(loc.nmx_noDocumentSelected));
    }

    final drawingState = ref.watch(drawingProviderFamily(widget.paneId));
    final drawingNotifier =
        ref.read(drawingProviderFamily(widget.paneId).notifier);
    final pdfState = ref.watch(pdfViewerProviderFamily(widget.paneId));

    final content = PdfDocumentView(
      key: _pdfKey,
      paneId: widget.paneId,
      document: document,
      initialPageNumber: pdfState.pageNumber,
      onPageChanged: _onPageChanged,
      onScaleChanged: _onScaleChanged,
      onFindResult: _onFindResult,
    );

    if (!widget.showToolbar) return content;

    final tabsState = ref.watch(tabsProvider);
    final currentTab = tabsState.tabs.isNotEmpty
        ? tabsState.tabs[tabsState.currentTabIndex]
        : null;
    final canGoBack = currentTab != null && currentTab.historyIndex > 0;
    final canGoForward = currentTab != null &&
        currentTab.historyIndex >= 0 &&
        currentTab.historyIndex < currentTab.history.length - 1;

    final toolbar = DocumentMainToolbar(
      canGoBack: canGoBack,
      canGoForward: canGoForward,
      onBack: canGoBack
          ? () => ref.read(tabsProvider.notifier).goBackInCurrentTab()
          : null,
      onForward: canGoForward
          ? () => ref.read(tabsProvider.notifier).goForwardInCurrentTab()
          : null,
      drawingEnabled: drawingState.isEnabled,
      onToggleDrawing: drawingNotifier.toggleDrawing,
      sdEnabled: drawingState.sdEnabled,
      onToggleSD: drawingNotifier.toggleSD,
      onZoomIn: _zoomIn,
      onZoomOut: _zoomOut,
      onResetView: _resetZoom,
      onShareUrl: _shareDocument,
      onExportPdf: () => _pdfKey.currentState?.downloadDocument(),
      onPrint: printDocument,
      onCloseToolbar: () => setState(() => _toolbarOpen = false),
      showDrawingControls: true,
      showPdfToolsButton: true,
      pdfToolsEnabled: _pdfToolsVisible,
      onTogglePdfTools: () =>
          setState(() => _pdfToolsVisible = !_pdfToolsVisible),
    );

    final drawingToolbar = (drawingState.isEnabled || drawingState.isTextMode)
        ? SvgDrawingToolbar(
            drawingState: drawingState,
            drawingNotifier: drawingNotifier,
            onSave: () => _pdfKey.currentState?.saveDrawings(),
          )
        : null;

    return Column(
      children: [
        if (_toolbarOpen)
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: toolbar,
            ),
          )
        else
          Align(
            alignment: Alignment.topCenter,
            child: IconButton(
              tooltip: 'Show viewer toolbar',
              onPressed: () => setState(() => _toolbarOpen = true),
              icon: const Icon(Icons.expand_more),
            ),
          ),
        if (drawingToolbar != null) drawingToolbar,
        if (_pdfToolsVisible) _buildPdfToolbar(pdfState),
        Expanded(
          child: Theme(
            data: ThemeData.light(),
            child: Container(color: Colors.white, child: content),
          ),
        ),
      ],
    );
  }
}
