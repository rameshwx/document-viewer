import 'package:aeroslate/domain/entities/document.dart';

class DocumentTab {
  final String id;
  final List<Document> documents;
  final bool isSplitView;
  final String title;
  // Per-tab navigation history
  final List<Document> history;
  final int historyIndex;
  // Per-pane navigation history for split view
  final List<Document> leftHistory;
  final int leftHistoryIndex;
  final List<Document> rightHistory;
  final int rightHistoryIndex;

  DocumentTab({
    required this.id,
    required this.documents,
    this.isSplitView = false,
    String? title,
    List<Document>? history,
    int? historyIndex,
    List<Document>? leftHistory,
    int? leftHistoryIndex,
    List<Document>? rightHistory,
    int? rightHistoryIndex,
  })  : title = title ?? (documents.isNotEmpty ? documents.first.pageBlock : 'Empty Tab'),
        history = history ?? (documents.isNotEmpty ? List<Document>.from(documents) : <Document>[]),
        historyIndex = historyIndex ?? ((documents.isNotEmpty) ? 0 : -1),
        leftHistory = leftHistory ?? (documents.isNotEmpty ? [documents[0]] : <Document>[]),
        leftHistoryIndex = leftHistoryIndex ?? ((documents.isNotEmpty) ? 0 : -1),
        rightHistory = rightHistory ?? (documents.length > 1 ? [documents[1]] : <Document>[]),
        rightHistoryIndex = rightHistoryIndex ?? ((documents.length > 1) ? 0 : -1);

  DocumentTab copyWith({
    String? id,
    List<Document>? documents,
    bool? isSplitView,
    String? title,
    List<Document>? history,
    int? historyIndex,
    List<Document>? leftHistory,
    int? leftHistoryIndex,
    List<Document>? rightHistory,
    int? rightHistoryIndex,
  }) {
    return DocumentTab(
      id: id ?? this.id,
      documents: documents ?? this.documents,
      isSplitView: isSplitView ?? this.isSplitView,
      title: title ?? this.title,
      history: history ?? this.history,
      historyIndex: historyIndex ?? this.historyIndex,
      leftHistory: leftHistory ?? this.leftHistory,
      leftHistoryIndex: leftHistoryIndex ?? this.leftHistoryIndex,
      rightHistory: rightHistory ?? this.rightHistory,
      rightHistoryIndex: rightHistoryIndex ?? this.rightHistoryIndex,
    );
  }
}
