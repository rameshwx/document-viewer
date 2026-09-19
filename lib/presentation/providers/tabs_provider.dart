import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:aeroslate/domain/entities/document.dart';
import 'package:aeroslate/domain/entities/document_tab.dart';

class TabsState {
  final List<DocumentTab> tabs;
  final int currentTabIndex;
  // Recently closed tabs' documents list (for quick reopen)
  final List<Document> recentlyClosedDocuments;

  TabsState({
    this.tabs = const [],
    this.currentTabIndex = 0,
    this.recentlyClosedDocuments = const [],
  });

  TabsState copyWith({
    List<DocumentTab>? tabs,
    int? currentTabIndex,
    List<Document>? recentlyClosedDocuments,
  }) {
    return TabsState(
      tabs: tabs ?? this.tabs,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      recentlyClosedDocuments: recentlyClosedDocuments ?? this.recentlyClosedDocuments,
    );
  }
}

class TabsNotifier extends StateNotifier<TabsState> {
  final Uuid _uuid = const Uuid();
  static const int _recentLimit = 10;
  TabsNotifier(): super(TabsState());

  void changeTab(int i) {
    if (i >= 0 && i < state.tabs.length) {
      state = state.copyWith(currentTabIndex: i);
    }
  }

  void addTab(DocumentTab tab) {
    final updated = [...state.tabs, tab];
    state = state.copyWith(tabs: updated, currentTabIndex: updated.length - 1);
  }

  void openDocumentInNewTab(Document doc) {
    final newTab = DocumentTab(id: _uuid.v4(), documents: [doc], title: doc.pageBlock);
    state = state.copyWith(
      tabs: [...state.tabs, newTab],
      currentTabIndex: state.tabs.length,
    );
  }

  /// Insert the given document as a new tab immediately to the right of the
  /// current tab (or at index 0 if none), followed by the related documents.
  void openDocumentsToRight(Document primary, List<Document> related) {
    final tabs = [...state.tabs];
    int insertIndex = tabs.isEmpty ? 0 : state.currentTabIndex + 1;
    if (insertIndex < 0) insertIndex = 0;
    if (insertIndex > tabs.length) insertIndex = tabs.length;

    tabs.insert(
      insertIndex,
      DocumentTab(id: _uuid.v4(), documents: [primary], title: primary.pageBlock),
    );
    var nextIndex = insertIndex + 1;
    for (final doc in related) {
      tabs.insert(
        nextIndex,
        DocumentTab(id: _uuid.v4(), documents: [doc], title: doc.pageBlock),
      );
      nextIndex++;
    }

    state = state.copyWith(
      tabs: tabs,
      currentTabIndex: insertIndex,
    );
  }

  void openDocumentInCurrentTab(Document doc) {
    if (state.tabs.isEmpty) {
      openDocumentInNewTab(doc);
      return;
    }
    final updated = [...state.tabs];
    final current = updated[state.currentTabIndex];

    // Update per-tab history: truncate forward if any, then append new doc
    final List<Document> history = List<Document>.from(current.history);
    int index = current.historyIndex;

    // If user had navigated back and then opens a new doc, drop the forward history
    if (index >= 0 && index < history.length - 1) {
      history.removeRange(index + 1, history.length);
    }

    // Avoid duplicate push if the same doc is being opened consecutively
    if (history.isEmpty || history.last.id != doc.id) {
      history.add(doc);
      index = history.length - 1;
    } else {
      index = history.length - 1;
    }

    updated[state.currentTabIndex] = current.copyWith(
      documents: [doc],
      isSplitView: false,
      title: doc.pageBlock,
      history: history,
      historyIndex: index,
    );
    state = state.copyWith(tabs: updated);
  }

  void openDocumentInSplitView(Document doc) {
    if (state.tabs.isEmpty) {
      final newTab = DocumentTab(
        id: _uuid.v4(),
        documents: [doc],
        isSplitView: true,
        title: doc.pageBlock,
      );
      state = state.copyWith(tabs: [newTab], currentTabIndex: 0);
      return;
    }
    final current = state.tabs[state.currentTabIndex];
    final docs = current.documents;
    final newDocs = docs.isEmpty
        ? [doc]
        : docs.length == 1
        ? [...docs, doc]
        : [docs[0], doc];
    // Push to history (so Back/Forward can reach it), truncating forward history
    final List<Document> history = List<Document>.from(current.history);
    int index = current.historyIndex;
    if (index >= 0 && index < history.length - 1) {
      history.removeRange(index + 1, history.length);
    }
    if (history.isEmpty || history.last.id != doc.id) {
      history.add(doc);
      index = history.length - 1;
    } else {
      index = history.length - 1;
    }

    // Update per-pane history as well
    List<Document> leftH = List<Document>.from(current.leftHistory);
    int leftIdx = current.leftHistoryIndex;
    List<Document> rightH = List<Document>.from(current.rightHistory);
    int rightIdx = current.rightHistoryIndex;

    if (newDocs.length == 1) {
      // left only
      if (leftH.isEmpty || leftH.last.id != newDocs[0].id) {
        leftH.add(newDocs[0]);
      }
      leftIdx = leftH.length - 1;
    } else if (newDocs.length >= 2) {
      // right updated
      if (rightH.isEmpty || rightH.last.id != newDocs[1].id) {
        rightH.add(newDocs[1]);
      }
      rightIdx = rightH.length - 1;
    }

    final updated = [...state.tabs];
    updated[state.currentTabIndex] = current.copyWith(
      documents: newDocs,
      isSplitView: true,
      title: newDocs.isNotEmpty ? newDocs.first.pageBlock : current.title,
      history: history,
      historyIndex: index,
      leftHistory: leftH,
      leftHistoryIndex: leftIdx,
      rightHistory: rightH,
      rightHistoryIndex: rightIdx,
    );
    state = state.copyWith(tabs: updated);
  }

  /// Open/replace a document in a specific split pane (0 = left, 1 = right)
  void openDocumentInSplitPane(Document doc, int paneIndex) {
    if (paneIndex != 0 && paneIndex != 1) return;
    if (state.tabs.isEmpty) {
      // If no tabs exist, create a new split tab with this doc
      final newTab = DocumentTab(
        id: _uuid.v4(),
        documents: [doc],
        isSplitView: true,
        title: doc.pageBlock,
      );
      state = state.copyWith(tabs: [newTab], currentTabIndex: 0);
      return;
    }

    final updated = [...state.tabs];
    final current = updated[state.currentTabIndex];
    final docs = List<Document>.from(current.documents);

    List<Document> newDocs;
    if (paneIndex == 0) {
      if (docs.isEmpty) {
        newDocs = [doc];
      } else if (docs.length == 1) {
        newDocs = [doc];
      } else {
        newDocs = [doc, docs[1]];
      }
    } else {
      if (docs.isEmpty) {
        newDocs = [doc];
      } else if (docs.length == 1) {
        newDocs = [docs[0], doc];
      } else {
        newDocs = [docs[0], doc];
      }
    }

    // Push to history for global navigation
    final List<Document> history = List<Document>.from(current.history);
    int index = current.historyIndex;
    if (index >= 0 && index < history.length - 1) {
      history.removeRange(index + 1, history.length);
    }
    if (history.isEmpty || history.last.id != doc.id) {
      history.add(doc);
      index = history.length - 1;
    } else {
      index = history.length - 1;
    }

    // Update per-pane histories
    List<Document> leftH = List<Document>.from(current.leftHistory);
    int leftIdx = current.leftHistoryIndex;
    List<Document> rightH = List<Document>.from(current.rightHistory);
    int rightIdx = current.rightHistoryIndex;

    if (paneIndex == 0) {
      if (leftIdx >= 0 && leftIdx < leftH.length - 1) {
        leftH.removeRange(leftIdx + 1, leftH.length);
      }
      if (leftH.isEmpty || leftH.last.id != doc.id) {
        leftH.add(doc);
      }
      leftIdx = leftH.length - 1;
    } else {
      if (rightIdx >= 0 && rightIdx < rightH.length - 1) {
        rightH.removeRange(rightIdx + 1, rightH.length);
      }
      if (rightH.isEmpty || rightH.last.id != doc.id) {
        rightH.add(doc);
      }
      rightIdx = rightH.length - 1;
    }

    updated[state.currentTabIndex] = current.copyWith(
      documents: newDocs,
      isSplitView: newDocs.length > 1 || current.isSplitView,
      title: newDocs.isNotEmpty ? newDocs.first.pageBlock : current.title,
      history: history,
      historyIndex: index,
      leftHistory: leftH,
      leftHistoryIndex: leftIdx,
      rightHistory: rightH,
      rightHistoryIndex: rightIdx,
    );
    state = state.copyWith(tabs: updated);
  }

  bool canGoBackInSplitPane(int paneIndex) {
    if (state.tabs.isEmpty) return false;
    final t = state.tabs[state.currentTabIndex];
    if (!t.isSplitView) return false;
    if (paneIndex == 0) {
      return t.leftHistoryIndex > 0;
    } else {
      return t.rightHistoryIndex > 0;
    }
  }

  bool canGoForwardInSplitPane(int paneIndex) {
    if (state.tabs.isEmpty) return false;
    final t = state.tabs[state.currentTabIndex];
    if (!t.isSplitView) return false;
    if (paneIndex == 0) {
      return t.leftHistoryIndex >= 0 && t.leftHistoryIndex < t.leftHistory.length - 1;
    } else {
      return t.rightHistoryIndex >= 0 && t.rightHistoryIndex < t.rightHistory.length - 1;
    }
  }

  void goBackInSplitPane(int paneIndex) {
    if (!canGoBackInSplitPane(paneIndex)) return;
    final updated = [...state.tabs];
    final cur = updated[state.currentTabIndex];
    if (paneIndex == 0) {
      final newIdx = cur.leftHistoryIndex - 1;
      final doc = cur.leftHistory[newIdx];
      final docs = [...cur.documents];
      if (docs.isEmpty) {
        docs.add(doc);
      } else {
        if (docs.length == 1) {
          docs[0] = doc;
        } else {
          docs[0] = doc;
        }
      }
      updated[state.currentTabIndex] = cur.copyWith(
        documents: docs,
        leftHistoryIndex: newIdx,
        title: docs.isNotEmpty ? docs.first.pageBlock : cur.title,
        isSplitView: docs.length > 1,
      );
    } else {
      final newIdx = cur.rightHistoryIndex - 1;
      final doc = cur.rightHistory[newIdx];
      final docs = [...cur.documents];
      if (docs.isEmpty) {
        // create left as placeholder? Keep as left only doc
        docs.add(doc);
      } else if (docs.length == 1) {
        docs.add(doc);
      } else {
        docs[1] = doc;
      }
      updated[state.currentTabIndex] = cur.copyWith(
        documents: docs,
        rightHistoryIndex: newIdx,
        title: docs.isNotEmpty ? docs.first.pageBlock : cur.title,
        isSplitView: docs.length > 1,
      );
    }
    state = state.copyWith(tabs: updated);
  }

  void goForwardInSplitPane(int paneIndex) {
    if (!canGoForwardInSplitPane(paneIndex)) return;
    final updated = [...state.tabs];
    final cur = updated[state.currentTabIndex];
    if (paneIndex == 0) {
      final newIdx = cur.leftHistoryIndex + 1;
      final doc = cur.leftHistory[newIdx];
      final docs = [...cur.documents];
      if (docs.isEmpty) {
        docs.add(doc);
      } else {
        if (docs.length == 1) {
          docs[0] = doc;
        } else {
          docs[0] = doc;
        }
      }
      updated[state.currentTabIndex] = cur.copyWith(
        documents: docs,
        leftHistoryIndex: newIdx,
        title: docs.isNotEmpty ? docs.first.pageBlock : cur.title,
        isSplitView: docs.length > 1,
      );
    } else {
      final newIdx = cur.rightHistoryIndex + 1;
      final doc = cur.rightHistory[newIdx];
      final docs = [...cur.documents];
      if (docs.isEmpty) {
        docs.add(doc);
      } else if (docs.length == 1) {
        docs.add(doc);
      } else {
        docs[1] = doc;
      }
      updated[state.currentTabIndex] = cur.copyWith(
        documents: docs,
        rightHistoryIndex: newIdx,
        title: docs.isNotEmpty ? docs.first.pageBlock : cur.title,
        isSplitView: docs.length > 1,
      );
    }
    state = state.copyWith(tabs: updated);
  }

  // Method to enable split view without requiring a second document immediately
  void prepareSplitView() {
    if (state.tabs.isEmpty || state.currentTabIndex >= state.tabs.length) {
      return; // No tabs to split
    }

    final currentTab = state.tabs[state.currentTabIndex];

    // Only update if it's not already in split view and has a document
    if (!currentTab.isSplitView && currentTab.documents.isNotEmpty) {
      final updated = [...state.tabs];
      updated[state.currentTabIndex] = currentTab.copyWith(isSplitView: true);
      state = state.copyWith(tabs: updated);
    }
  }

  void closeAllTabs() {
    if (state.tabs.isEmpty) return;
    // Also clear recently closed list as requested
    state = TabsState(recentlyClosedDocuments: []);
  }

  void closeTab(String tabId) {
    final idx = state.tabs.indexWhere((t) => t.id == tabId);
    if (idx == -1) return;
    // Add current document of the tab to recently closed list
    final closingTab = state.tabs[idx];
    Document? closedDoc;
    if (closingTab.documents.isNotEmpty) {
      closedDoc = closingTab.documents.first;
    } else if (closingTab.historyIndex >= 0 && closingTab.history.isNotEmpty) {
      closedDoc = closingTab.history[closingTab.historyIndex];
    }

    final updated = [...state.tabs]..removeAt(idx);
    List<Document> recent = List<Document>.from(state.recentlyClosedDocuments);
    if (closedDoc != null) {
      // avoid consecutive duplicates
      if (recent.isEmpty || recent.first.id != closedDoc.id) {
        recent.insert(0, closedDoc);
        if (recent.length > _recentLimit) {
          recent = recent.sublist(0, _recentLimit);
        }
      }
    }
    if (updated.isEmpty) {
      state = TabsState(recentlyClosedDocuments: recent);
      return;
    }
    var newIndex = state.currentTabIndex;
    if (idx <= state.currentTabIndex) {
      newIndex = (state.currentTabIndex - 1).clamp(0, updated.length - 1);
    }
    state = state.copyWith(tabs: updated, currentTabIndex: newIndex, recentlyClosedDocuments: recent);
  }

  void closeDocumentInSplitView(String tabId, int paneIndex) {
    final idx = state.tabs.indexWhere((t) => t.id == tabId);
    if (idx == -1) return;
    final t = state.tabs[idx];
    final docs = [...t.documents];
    if (paneIndex < 0 || paneIndex >= docs.length) return;
    docs.removeAt(paneIndex);
    final updatedTab = t.copyWith(
      documents: docs,
      isSplitView: docs.length > 1,
    );
    final updated = [...state.tabs];
    updated[idx] = updatedTab;
    state = state.copyWith(tabs: updated);
  }

  void detachTab(String tabId) {
    debugPrint('detachTab called for $tabId');
    // TODO: implement real web/desktop detach
  }

  void refreshDocuments() {
    state = state.copyWith(tabs: [...state.tabs]);
  }

  void toSingleMode() {}

  // Navigation within a tab's document history
  bool canGoBackInCurrentTab() {
    if (state.tabs.isEmpty) return false;
    final t = state.tabs[state.currentTabIndex];
    return t.historyIndex > 0;
  }

  bool canGoForwardInCurrentTab() {
    if (state.tabs.isEmpty) return false;
    final t = state.tabs[state.currentTabIndex];
    return t.historyIndex >= 0 && t.historyIndex < t.history.length - 1;
  }

  void goBackInCurrentTab() {
    if (!canGoBackInCurrentTab()) return;
    final updated = [...state.tabs];
    final current = updated[state.currentTabIndex];
    final newIndex = current.historyIndex - 1;
    final doc = current.history[newIndex];
    updated[state.currentTabIndex] = current.copyWith(
      historyIndex: newIndex,
      documents: [doc],
      isSplitView: false,
      title: doc.pageBlock,
    );
    state = state.copyWith(tabs: updated);
  }

  void goForwardInCurrentTab() {
    if (!canGoForwardInCurrentTab()) return;
    final updated = [...state.tabs];
    final current = updated[state.currentTabIndex];
    final newIndex = current.historyIndex + 1;
    final doc = current.history[newIndex];
    updated[state.currentTabIndex] = current.copyWith(
      historyIndex: newIndex,
      documents: [doc],
      isSplitView: false,
      title: doc.pageBlock,
    );
    state = state.copyWith(tabs: updated);
  }

  // Reopen a document from recently closed list in a new tab
  void reopenRecentlyClosed(Document doc) {
    // Remove the doc from the recent list and open as a new tab
    final recent = List<Document>.from(state.recentlyClosedDocuments);
    final idx = recent.indexWhere((d) => d.id == doc.id);
    if (idx != -1) {
      recent.removeAt(idx);
    }
    final newTab = DocumentTab(id: _uuid.v4(), documents: [doc], title: doc.pageBlock);
    final tabs = [...state.tabs, newTab];
    state = state.copyWith(
      tabs: tabs,
      currentTabIndex: tabs.length - 1,
      recentlyClosedDocuments: recent,
    );
  }
}

final tabsProvider = StateNotifierProvider<TabsNotifier, TabsState>(
      (ref) => TabsNotifier(),
);
