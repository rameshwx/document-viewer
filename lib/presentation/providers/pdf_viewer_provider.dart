import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PdfScrollMode { vertical, horizontal, wrapped }
enum PdfSpreadMode { none, odd, even }

class PdfViewerState {
  final int pageNumber;
  final int pageCount;
  final double scale;
  final String query;
  final bool highlightAll;
  final bool matchCase;
  final bool matchDiacritics;
  final bool wholeWords;
  final int matchCurrent;
  final int matchTotal;
  final PdfScrollMode scrollMode;
  final PdfSpreadMode spreadMode;
  final bool handToolEnabled;

  const PdfViewerState({
    this.pageNumber = 1,
    this.pageCount = 0,
    this.scale = 1.0,
    this.query = '',
    this.highlightAll = true,
    this.matchCase = false,
    this.matchDiacritics = false,
    this.wholeWords = false,
    this.matchCurrent = 0,
    this.matchTotal = 0,
    this.scrollMode = PdfScrollMode.vertical,
    this.spreadMode = PdfSpreadMode.none,
    this.handToolEnabled = false,
  });

  PdfViewerState copyWith({
    int? pageNumber,
    int? pageCount,
    double? scale,
    String? query,
    bool? highlightAll,
    bool? matchCase,
    bool? matchDiacritics,
    bool? wholeWords,
    int? matchCurrent,
    int? matchTotal,
    PdfScrollMode? scrollMode,
    PdfSpreadMode? spreadMode,
    bool? handToolEnabled,
  }) {
    return PdfViewerState(
      pageNumber: pageNumber ?? this.pageNumber,
      pageCount: pageCount ?? this.pageCount,
      scale: scale ?? this.scale,
      query: query ?? this.query,
      highlightAll: highlightAll ?? this.highlightAll,
      matchCase: matchCase ?? this.matchCase,
      matchDiacritics: matchDiacritics ?? this.matchDiacritics,
      wholeWords: wholeWords ?? this.wholeWords,
      matchCurrent: matchCurrent ?? this.matchCurrent,
      matchTotal: matchTotal ?? this.matchTotal,
      scrollMode: scrollMode ?? this.scrollMode,
      spreadMode: spreadMode ?? this.spreadMode,
      handToolEnabled: handToolEnabled ?? this.handToolEnabled,
    );
  }
}

class PdfViewerNotifier extends StateNotifier<PdfViewerState> {
  PdfViewerNotifier() : super(const PdfViewerState());

  void reset() {
    state = const PdfViewerState();
  }

  void setPage(int page, int count) {
    state = state.copyWith(pageNumber: page, pageCount: count);
  }

  void setScale(double scale) {
    state = state.copyWith(scale: scale);
  }

  void setFindQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setFindResult(int current, int total) {
    state = state.copyWith(matchCurrent: current, matchTotal: total);
  }

  void toggleHighlightAll() {
    state = state.copyWith(highlightAll: !state.highlightAll);
  }

  void toggleMatchCase() {
    state = state.copyWith(matchCase: !state.matchCase);
  }

  void toggleMatchDiacritics() {
    state = state.copyWith(matchDiacritics: !state.matchDiacritics);
  }

  void toggleWholeWords() {
    state = state.copyWith(wholeWords: !state.wholeWords);
  }

  void setScrollMode(PdfScrollMode mode) {
    state = state.copyWith(scrollMode: mode);
  }

  void setSpreadMode(PdfSpreadMode mode) {
    state = state.copyWith(spreadMode: mode);
  }

  void setHandTool(bool enabled) {
    state = state.copyWith(handToolEnabled: enabled);
  }
}

final pdfViewerProviderFamily =
    StateNotifierProvider.family<PdfViewerNotifier, PdfViewerState, String>(
        (ref, paneId) {
  return PdfViewerNotifier();
});
