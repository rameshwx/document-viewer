import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

import 'package:aeroslate/domain/entities/document.dart';
import '../../l10n/app_localizations.dart';
import '../providers/drawing_provider.dart';
import '../providers/pdf_viewer_provider.dart';
import '../widgets/drawing_overlay.dart';
import '../widgets/saved_elements_painter.dart';
import '../../core/utils/document_download.dart';

class PdfDocumentView extends ConsumerStatefulWidget {
  final Document document;
  final String paneId;
  final void Function(int page, int pageCount)? onPageChanged;
  final void Function(double scale)? onScaleChanged;
  final void Function(int current, int total)? onFindResult;
  final int initialPageNumber;

  const PdfDocumentView({
    super.key,
    required this.document,
    required this.paneId,
    this.onPageChanged,
    this.onScaleChanged,
    this.onFindResult,
    this.initialPageNumber = 1,
  });

  @override
  ConsumerState<PdfDocumentView> createState() => PdfDocumentViewState();
}

class PdfDocumentViewState extends ConsumerState<PdfDocumentView> {
  final PdfViewerController _controller = PdfViewerController();
  late final PdfTextSearcher _searcher = PdfTextSearcher(_controller);
  final TransformationController _drawingTransform = TransformationController();

  Uint8List? _pdfBytes;
  bool _loading = true;
  String? _error;
  double _lastReportedScale = 1.0;

  PdfScrollMode _scrollMode = PdfScrollMode.vertical;
  PdfSpreadMode _spreadMode = PdfSpreadMode.none;
  bool _handToolEnabled = false;

  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _searcher.addListener(_onSearchChanged);
    _loadFile();
  }

  @override
  void didUpdateWidget(covariant PdfDocumentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.id != widget.document.id) {
      _loadFile();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _searcher.removeListener(_onSearchChanged);
    _searcher.dispose();
    _drawingTransform.dispose();
    super.dispose();
  }

  Future<void> _loadFile() async {
    final loc = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
      _pdfBytes = null;
    });
    try {
      final bytes = await _loadAssetBytes(widget.document.path);
      final elements = await ref
          .read(drawingRepositoryProvider)
          .loadDrawingElements(widget.document.id);
      ref
          .read(drawingProviderFamily(widget.paneId).notifier)
          .loadElements(elements);
      if (!mounted) return;
      setState(() {
        _pdfBytes = bytes;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('[PdfDocumentView] Error loading PDF: $e\n$st');
      if (mounted) {
        setState(() {
          _loading = false;
          _error = loc.nmx_failedLoadPdfWithError;
        });
      }
    }
  }

  Future<Uint8List> _loadAssetBytes(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return Uint8List.fromList(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }

  Future<void> downloadDocument() async {
    final bytes = _pdfBytes;
    if (bytes == null) return;
    final filename = widget.document.path.split('/').last;
    await downloadFileBytes(bytes, filename);
  }

  Future<void> _persistDrawings() async {
    try {
      final repo = ref.read(drawingRepositoryProvider);
      final elements = ref.read(drawingProviderFamily(widget.paneId)).elements;
      await repo.saveDrawingElements(widget.document.id, elements);
    } catch (_) {
      // Persistence failures should not block drawing interactions.
    }
  }

  Future<void> saveDrawings() async {
    final loc = AppLocalizations.of(context)!;
    final repo = ref.read(drawingRepositoryProvider);
    final elements = ref.read(drawingProviderFamily(widget.paneId)).elements;
    try {
      await repo.saveDrawingElements(widget.document.id, elements);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.nmx_svg_drawingsSaved(elements.length)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('[PdfDocumentView] Save drawings failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.nmx_svg_drawingsSaveFailed),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // === Public API for toolbar ===
  void zoomBy(double factor) {
    if (!_controller.isReady) return;
    final zoom = (_controller.currentZoom * factor)
        .clamp(_controller.minScale, _controller.params.maxScale);
    final center = _controller.visibleRect.center;
    _controller.value = _controller.calcMatrixFor(center, zoom: zoom);
  }

  void resetZoom() {
    if (!_controller.isReady) return;
    final targetPage = _controller.pageNumber ?? widget.initialPageNumber;
    final matrix = _controller.calcMatrixForFit(pageNumber: targetPage);
    if (matrix != null) {
      _controller.value = matrix;
    }
  }

  void nextPage() {
    if (!_controller.isReady) return;
    goToPage((_controller.pageNumber ?? 1) + 1);
  }

  void previousPage() {
    if (!_controller.isReady) return;
    goToPage((_controller.pageNumber ?? 1) - 1);
  }

  void firstPage() {
    goToPage(1);
  }

  void lastPage() {
    if (!_controller.isReady) return;
    goToPage(_controller.pageCount);
  }

  void goToPage(int page) {
    if (!_controller.isReady) return;
    final clamped = page.clamp(1, _controller.pageCount);
    _controller.goToPage(pageNumber: clamped);
  }

  void rotate(int deltaDegrees) {
    // Rotation is not currently supported in pdfrx viewer; no-op to keep API compatible.
  }

  void setScrollMode(String mode) {
    setState(() {
      if (mode.toLowerCase() == 'horizontal') {
        _scrollMode = PdfScrollMode.horizontal;
      } else if (mode.toLowerCase() == 'wrapped') {
        _scrollMode = PdfScrollMode.wrapped;
      } else {
        _scrollMode = PdfScrollMode.vertical;
      }
    });
    _controller.invalidate();
  }

  void setSpreadMode(String mode) {
    setState(() {
      switch (mode.toLowerCase()) {
        case 'odd':
          _spreadMode = PdfSpreadMode.odd;
          break;
        case 'even':
          _spreadMode = PdfSpreadMode.even;
          break;
        default:
          _spreadMode = PdfSpreadMode.none;
          break;
      }
    });
    _controller.invalidate();
  }

  void setHandTool(bool enabled) {
    setState(() {
      _handToolEnabled = enabled;
    });
  }

  Future<void> showOutline(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    if (!_controller.isReady) return;
    final outline = await _controller.useDocument((doc) => doc.loadOutline());
    if (!context.mounted) return;
    if (outline == null || outline.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.nmx_noOutlineAvailable)),
      );
      return;
    }
    final items = <({PdfOutlineNode node, int depth})>[];
    void walk(List<PdfOutlineNode> nodes, int depth) {
      for (final n in nodes) {
        items.add((node: n, depth: depth));
        if (n.children.isNotEmpty) walk(n.children, depth + 1);
      }
    }

    walk(outline, 0);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final item = items[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.only(
                    left: 12.0 + item.depth * 16,
                    right: 12,
                  ),
                  title: Text(
                    item.node.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: item.node.dest == null
                      ? null
                      : () {
                          Navigator.of(ctx).pop();
                          _controller.goToDest(item.node.dest!);
                        },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> showThumbnails(BuildContext context) async {
    if (!_controller.isReady) return;
    final doc = await _controller.useDocument((d) => d);
    if (!context.mounted || doc == null) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.55,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemCount: doc.pages.length,
              itemBuilder: (context, index) {
                final pageNum = index + 1;
                return InkWell(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _controller.goToPage(pageNumber: pageNum);
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: PdfPageView(
                            document: doc,
                            pageNumber: pageNum,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$pageNum',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void find({
    required String query,
    bool highlightAll = true,
    bool caseSensitive = false,
    bool matchDiacritics = false,
    bool entireWord = false,
    bool findPrevious = false,
  }) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      _lastSearchQuery = '';
      _searcher.resetTextSearch();
      widget.onFindResult?.call(0, 0);
      return;
    }

    final pattern = entireWord
        ? RegExp('\\b${RegExp.escape(normalizedQuery)}\\b',
            caseSensitive: caseSensitive)
        : RegExp(RegExp.escape(normalizedQuery), caseSensitive: caseSensitive);

    final isNewQuery = normalizedQuery != _lastSearchQuery;
    _lastSearchQuery = normalizedQuery;
    _searcher.startTextSearch(
      pattern,
      caseInsensitive: !caseSensitive,
      searchImmediately: true,
      goToFirstMatch: !findPrevious,
    );

    if (!isNewQuery) {
      if (findPrevious) {
        _searcher.goToPrevMatch();
      } else {
        _searcher.goToNextMatch();
      }
    }
    // highlightAll, matchDiacritics are not supported explicitly; kept for API parity.
  }
  // ==============================

  void _onControllerChanged() {
    if (!_controller.isReady) return;
    final scale = _controller.currentZoom;
    if ((scale - _lastReportedScale).abs() > 0.001) {
      _lastReportedScale = scale;
      widget.onScaleChanged?.call(scale);
    }
  }

  void _onSearchChanged() {
    final total = _searcher.matches.length;
    final current =
        _searcher.currentIndex != null ? _searcher.currentIndex! + 1 : 0;
    widget.onFindResult?.call(current, total);
  }

  PdfPageLayout _layoutPages(List<PdfPage> pages, PdfViewerParams params) {
    switch (_scrollMode) {
      case PdfScrollMode.horizontal:
        return _layoutHorizontal(pages, params.margin);
      case PdfScrollMode.wrapped:
      case PdfScrollMode.vertical:
        return _layoutVertical(pages, params.margin);
    }
  }

  PdfPageLayout _layoutVertical(List<PdfPage> pages, double margin) {
    final rects = <Rect>[];
    double y = margin;
    double width = 0;

    if (_spreadMode == PdfSpreadMode.none) {
      for (final page in pages) {
        rects.add(Rect.fromLTWH(margin, y, page.width, page.height));
        y += page.height + margin;
        width = math.max(width, page.width + margin * 2);
      }
    } else {
      int index = 0;
      while (index < pages.length) {
        if (_spreadMode == PdfSpreadMode.odd && index == 0) {
          final page = pages[index];
          rects.add(Rect.fromLTWH(margin, y, page.width, page.height));
          y += page.height + margin;
          width = math.max(width, page.width + margin * 2);
          index += 1;
          continue;
        }
        final left = pages[index];
        final right = index + 1 < pages.length ? pages[index + 1] : null;
        final rowHeight = math.max(left.height, right?.height ?? 0);
        double x = margin;
        rects.add(Rect.fromLTWH(x, y, left.width, left.height));
        x += left.width + margin;
        if (right != null) {
          rects.add(Rect.fromLTWH(x, y, right.width, right.height));
          x += right.width + margin;
        }
        width = math.max(width, x);
        y += rowHeight + margin;
        index += 2;
      }
    }

    return PdfPageLayout(pageLayouts: rects, documentSize: Size(width, y));
  }

  PdfPageLayout _layoutHorizontal(List<PdfPage> pages, double margin) {
    final rects = <Rect>[];
    double x = margin;
    double height = 0;
    for (final page in pages) {
      rects.add(Rect.fromLTWH(x, margin, page.width, page.height));
      x += page.width + margin;
      height = math.max(height, page.height + margin * 2);
    }
    return PdfPageLayout(pageLayouts: rects, documentSize: Size(x, height));
  }

  DrawingElement _scaleElementToPageSpace(
    DrawingElement element,
    Rect pageRect,
    PdfPage page,
  ) {
    final scaleX = (pageRect.width == 0 || page.width == 0)
        ? 1.0
        : page.width / pageRect.width;
    final scaleY = (pageRect.height == 0 || page.height == 0)
        ? 1.0
        : page.height / pageRect.height;
    final radiusScale = (scaleX + scaleY) / 2;

    dynamic scaledData = element.data;

    if (element.type == 'path' && element.data is String) {
      final buffer = StringBuffer();
      final segments = (element.data as String).split(RegExp(r'(?=[ML])'));
      for (final seg in segments) {
        if (seg.isEmpty) continue;
        final cmd = seg[0];
        final nums = seg.substring(1).trim().split(RegExp(r'\s+'));
        if (nums.length >= 2) {
          final x = (double.tryParse(nums[0]) ?? 0.0) * scaleX;
          final y = (double.tryParse(nums[1]) ?? 0.0) * scaleY;
          if (buffer.isNotEmpty) buffer.write(' ');
          buffer.write('$cmd$x $y');
        }
      }
      scaledData = buffer.toString();
    } else if (element.type == 'circle' && element.data is Map) {
      final m = Map<String, dynamic>.from(element.data);
      scaledData = {
        'cx': (m['cx'] as num).toDouble() * scaleX,
        'cy': (m['cy'] as num).toDouble() * scaleY,
        'r': (m['r'] as num).toDouble() * radiusScale,
      };
    } else if (element.type == 'rect' && element.data is Map) {
      final m = Map<String, dynamic>.from(element.data);
      scaledData = {
        'x': (m['x'] as num).toDouble() * scaleX,
        'y': (m['y'] as num).toDouble() * scaleY,
        'width': (m['width'] as num).toDouble() * scaleX,
        'height': (m['height'] as num).toDouble() * scaleY,
      };
    } else if (element.type == 'ellipse' && element.data is Map) {
      final m = Map<String, dynamic>.from(element.data);
      scaledData = {
        'cx': (m['cx'] as num).toDouble() * scaleX,
        'cy': (m['cy'] as num).toDouble() * scaleY,
        'rx': (m['rx'] as num).toDouble() * scaleX,
        'ry': (m['ry'] as num).toDouble() * scaleY,
      };
    } else if ((element.type == 'line' || element.type == 'arrow') &&
        element.data is Map) {
      final m = Map<String, dynamic>.from(element.data);
      scaledData = {
        'x1': (m['x1'] as num).toDouble() * scaleX,
        'y1': (m['y1'] as num).toDouble() * scaleY,
        'x2': (m['x2'] as num).toDouble() * scaleX,
        'y2': (m['y2'] as num).toDouble() * scaleY,
      };
    } else if ((element.type == 'polyline' || element.type == 'polygon') &&
        element.data is List) {
      scaledData = (element.data as List)
          .map((e) => Map<String, dynamic>.from(e))
          .map((m) => {
                'x': (m['x'] as num).toDouble() * scaleX,
                'y': (m['y'] as num).toDouble() * scaleY,
              })
          .toList();
    } else if (element.type == 'text' && element.data is Map) {
      final m = Map<String, dynamic>.from(element.data);
      scaledData = {
        'x': (m['x'] as num).toDouble() * scaleX,
        'y': (m['y'] as num).toDouble() * scaleY,
        'text': m['text'],
      };
    }

    return DrawingElement(
      type: element.type,
      color: element.color,
      data: scaledData,
      pageNumber: page.pageNumber,
    );
  }

  // Forward wheel/trackpad scrolls while the drawing overlay is active.
  void _scrollWhileDrawing(Offset scrollDelta) {
    if (!_controller.isReady) return;
    final params = _controller.params;
    final scrollFactor = params.scrollByMouseWheel;
    if (scrollFactor == null || scrollFactor == 0) return;

    final zoom = _controller.currentZoom;
    final dx = -scrollDelta.dx * scrollFactor / zoom;
    final dy = -scrollDelta.dy * scrollFactor / zoom;

    final next = _controller.value.clone();
    if (params.scrollHorizontallyByMouseWheel) {
      next.translate(dy, dx);
    } else {
      next.translate(dx, dy);
    }
    _controller.value = next;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _pdfBytes == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          _error ?? loc.nmx_failedLoadPdf,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final drawingState = ref.watch(drawingProviderFamily(widget.paneId));
    final drawingNotifier =
        ref.read(drawingProviderFamily(widget.paneId).notifier);

    return PdfViewer.data(
      _pdfBytes!,
      sourceName: widget.document.path,
      controller: _controller,
      initialPageNumber: widget.initialPageNumber,
      params: PdfViewerParams(
        backgroundColor: Colors.grey.shade200,
        margin: 8,
        layoutPages: _layoutPages,
        panEnabled: !drawingState.isEnabled,
        scaleEnabled: !drawingState.isEnabled,
        textSelectionParams: PdfTextSelectionParams(
          enabled: !_handToolEnabled && !drawingState.isEnabled,
        ),
        onPageChanged: (page) =>
            _reportPageChanged(page ?? widget.initialPageNumber),
        onViewerReady: (doc, controller) => _reportPageChanged(
            controller.pageNumber ?? widget.initialPageNumber),
        viewerOverlayBuilder: (context, size, handleLinkTap) => const [],
        pageOverlaysBuilder: (context, pageRect, page) {
          final paintScaleX = (page.width == 0 || pageRect.width == 0)
              ? 1.0
              : pageRect.width / page.width;
          final paintScaleY = (page.height == 0 || pageRect.height == 0)
              ? 1.0
              : pageRect.height / page.height;

          final pageElements = drawingState.elements
              .where((el) =>
                  el.pageNumber == null || el.pageNumber == page.pageNumber)
              .toList();

          final overlays = <Widget>[
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: CustomPaint(
                  painter: SavedElementsPainter(
                    elements: pageElements,
                    targetPageNumber: page.pageNumber,
                    scaleX: paintScaleX,
                    scaleY: paintScaleY,
                  ),
                ),
              ),
            ),
          ];

          if (drawingState.isEnabled) {
            overlays.add(
              Positioned.fill(
                child: DrawingOverlay(
                  drawingState: drawingState,
                  onElementComplete: (el) {
                    final scaled = _scaleElementToPageSpace(el, pageRect, page);
                    drawingNotifier.addElement(scaled);
                    _persistDrawings();
                  },
                  transformationController: _drawingTransform,
                  onScroll: _scrollWhileDrawing,
                ),
              ),
            );
          }

          return overlays;
        },
        pagePaintCallbacks: [_searcher.pageTextMatchPaintCallback],
      ),
    );
  }

  void _reportPageChanged(int page) {
    final pageCount = _controller.isReady ? _controller.pageCount : 0;
    widget.onPageChanged?.call(page, pageCount);
  }
}
