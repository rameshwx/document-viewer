import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../providers/pdf_viewer_provider.dart';

class PdfToolbar extends StatelessWidget {
  final PdfViewerState state;
  final TextEditingController pageController;
  final TextEditingController findController;
  final VoidCallback? onFirstPage;
  final VoidCallback? onPrevPage;
  final VoidCallback? onNextPage;
  final VoidCallback? onLastPage;
  final ValueChanged<String>? onPageSubmitted;
  final VoidCallback? onRotateLeft;
  final VoidCallback? onRotateRight;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onFindPrev;
  final VoidCallback? onFindNext;
  final VoidCallback? onToggleHighlightAll;
  final VoidCallback? onToggleMatchCase;
  final VoidCallback? onToggleMatchDiacritics;
  final VoidCallback? onToggleWholeWords;
  final ValueChanged<PdfScrollMode>? onScrollMode;
  final ValueChanged<PdfSpreadMode>? onSpreadMode;
  final ValueChanged<bool>? onHandTool;
  final VoidCallback? onShowOutline;
  final VoidCallback? onShowThumbnails;

  const PdfToolbar({
    super.key,
    required this.state,
    required this.pageController,
    required this.findController,
    this.onFirstPage,
    this.onPrevPage,
    this.onNextPage,
    this.onLastPage,
    this.onPageSubmitted,
    this.onRotateLeft,
    this.onRotateRight,
    this.onZoomIn,
    this.onZoomOut,
    this.onFindPrev,
    this.onFindNext,
    this.onToggleHighlightAll,
    this.onToggleMatchCase,
    this.onToggleMatchDiacritics,
    this.onToggleWholeWords,
    this.onScrollMode,
    this.onSpreadMode,
    this.onHandTool,
    this.onShowOutline,
    this.onShowThumbnails,
  });

  @override
  Widget build(BuildContext context) {
    final total = state.pageCount;
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    Widget iconButton({
      required IconData icon,
      String? tooltip,
      VoidCallback? onPressed,
      bool active = false,
    }) {
      return Tooltip(
        message: tooltip ?? '',
        child: IconButton(
          icon: Icon(icon, size: 18),
          onPressed: onPressed,
          color: active ? scheme.primary : scheme.onSurface,
          splashRadius: 20,
        ),
      );
    }

    Widget toggleChip(String label, bool selected, VoidCallback? onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected
                ? scheme.secondaryContainer
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? scheme.secondary : scheme.outline,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected
                  ? scheme.onSecondaryContainer
                  : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 52,
      color: scheme.surfaceContainer,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconButton(
              icon: Icons.first_page,
              tooltip: loc.nmx_firstPage,
              onPressed: onFirstPage,
            ),
            iconButton(
              icon: Icons.keyboard_arrow_up,
              tooltip: loc.nmx_previousPage,
              onPressed: onPrevPage,
            ),
            SizedBox(
              width: 70,
              child: TextField(
                controller: pageController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onSubmitted: onPageSubmitted,
                style: TextStyle(color: scheme.onSurface, fontSize: 13),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: scheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: scheme.primary),
                  ),
                  hintText: '1',
                  hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '/ ${total == 0 ? '-' : total}',
                style: TextStyle(
                    color: scheme.onSurfaceVariant, fontSize: 13),
              ),
            ),
            iconButton(
              icon: Icons.keyboard_arrow_down,
              tooltip: loc.nmx_nextPage,
              onPressed: onNextPage,
            ),
            iconButton(
              icon: Icons.last_page,
              tooltip: loc.nmx_lastPage,
              onPressed: onLastPage,
            ),
            VerticalDivider(
                color: scheme.outlineVariant, thickness: 1, width: 12),
            iconButton(
              icon: Icons.rotate_left,
              tooltip: loc.nmx_rotateLeft,
              onPressed: onRotateLeft,
            ),
            iconButton(
              icon: Icons.rotate_right,
              tooltip: loc.nmx_rotateRight,
              onPressed: onRotateRight,
            ),
            iconButton(
              icon: Icons.zoom_in,
              tooltip: loc.nmx_zoomIn,
              onPressed: onZoomIn,
            ),
            iconButton(
              icon: Icons.zoom_out,
              tooltip: loc.nmx_zoomOut,
              onPressed: onZoomOut,
            ),
            VerticalDivider(
                color: scheme.outlineVariant, thickness: 1, width: 12),
            iconButton(
              icon: Icons.list_alt,
              tooltip: loc.nmx_showOutline,
              onPressed: onShowOutline,
            ),
            iconButton(
              icon: Icons.grid_view,
              tooltip: loc.nmx_thumbnails,
              onPressed: onShowThumbnails,
            ),
            VerticalDivider(
                color: scheme.outlineVariant, thickness: 1, width: 12),
            SizedBox(
              width: 190,
              child: TextField(
                controller: findController,
                style: TextStyle(color: scheme.onSurface, fontSize: 13),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: loc.nmx_findInDocument,
                  hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: scheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: scheme.primary),
                  ),
                ),
                onSubmitted: (_) => onFindNext?.call(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                state.matchTotal > 0
                    ? '${state.matchCurrent == 0 ? 1 : state.matchCurrent} / ${state.matchTotal}'
                    : '',
                style: TextStyle(
                    color: scheme.onSurfaceVariant, fontSize: 12),
              ),
            ),
            iconButton(
              icon: Icons.keyboard_arrow_up,
              tooltip: loc.nmx_previousMatch,
              onPressed: onFindPrev,
            ),
            iconButton(
              icon: Icons.keyboard_arrow_down,
              tooltip: loc.nmx_nextMatch,
              onPressed: onFindNext,
            ),
            toggleChip(
                loc.nmx_highlight, state.highlightAll, onToggleHighlightAll),
            toggleChip(loc.nmx_matchCase, state.matchCase, onToggleMatchCase),
            toggleChip(loc.nmx_matchDiacritics, state.matchDiacritics,
                onToggleMatchDiacritics),
            toggleChip(
                loc.nmx_wholeWords, state.wholeWords, onToggleWholeWords),
            VerticalDivider(
                color: scheme.outlineVariant, thickness: 1, width: 12),
            PopupMenuButton<PdfScrollMode>(
              initialValue: state.scrollMode,
              color: scheme.surfaceContainer,
              onSelected: onScrollMode,
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: PdfScrollMode.vertical,
                  child: Text(loc.nmx_verticalScrolling),
                ),
                PopupMenuItem(
                  value: PdfScrollMode.horizontal,
                  child: Text(loc.nmx_horizontalScrolling),
                ),
                PopupMenuItem(
                  value: PdfScrollMode.wrapped,
                  child: Text(loc.nmx_wrappedScrolling),
                ),
              ],
              child: Row(
                children: [
                  Icon(Icons.swap_vert, color: scheme.onSurface, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    _scrollLabel(state.scrollMode, loc),
                    style: TextStyle(color: scheme.onSurface, fontSize: 12),
                  ),
                  Icon(Icons.arrow_drop_down, color: scheme.onSurface),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<PdfSpreadMode>(
              initialValue: state.spreadMode,
              color: scheme.surfaceContainer,
              onSelected: onSpreadMode,
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: PdfSpreadMode.none,
                  child: Text(loc.nmx_noSpreads),
                ),
                PopupMenuItem(
                  value: PdfSpreadMode.odd,
                  child: Text(loc.nmx_oddSpreads),
                ),
                PopupMenuItem(
                  value: PdfSpreadMode.even,
                  child: Text(loc.nmx_evenSpreads),
                ),
              ],
              child: Row(
                children: [
                  Icon(Icons.view_week, color: scheme.onSurface, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    _spreadLabel(state.spreadMode, loc),
                    style: TextStyle(color: scheme.onSurface, fontSize: 12),
                  ),
                  Icon(Icons.arrow_drop_down, color: scheme.onSurface),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilterChip(
              selected: state.handToolEnabled,
              onSelected: onHandTool,
              label: Text(loc.nmx_handTool),
              labelStyle: TextStyle(color: scheme.onSurface),
              selectedColor: scheme.secondaryContainer,
              backgroundColor: scheme.surfaceContainerHighest,
              side: BorderSide(color: scheme.outline),
              checkmarkColor: scheme.onSecondaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  String _scrollLabel(PdfScrollMode mode, AppLocalizations loc) {
    switch (mode) {
      case PdfScrollMode.horizontal:
        return loc.nmx_horizontalScrolling;
      case PdfScrollMode.wrapped:
        return loc.nmx_wrappedScrolling;
      case PdfScrollMode.vertical:
        return loc.nmx_verticalScrolling;
    }
  }

  String _spreadLabel(PdfSpreadMode mode, AppLocalizations loc) {
    switch (mode) {
      case PdfSpreadMode.odd:
        return loc.nmx_oddSpreads;
      case PdfSpreadMode.even:
        return loc.nmx_evenSpreads;
      case PdfSpreadMode.none:
        return loc.nmx_noSpreads;
    }
  }
}
