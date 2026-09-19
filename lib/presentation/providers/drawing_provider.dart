import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aeroslate/data/repositories/drawing_repository_impl.dart';

import '../../data/repositories/drawing_repository.dart';

// Define a simple DrawingElement entity to store shape data
class DrawingElement {
  final String type; // 'path', 'circle', 'square'/'rect', 'text'
  final String color;
  final dynamic data; // SVG path string, coordinates map, or text data for annotations
  final int? pageNumber;

  DrawingElement({
    required this.type,
    required this.color,
    required this.data,
    this.pageNumber,
  });

  Map<String, dynamic> toMap() => {
    'type': type,
    'color': color,
    'data': data is String ? data : data,
    'page': pageNumber,
  };

  factory DrawingElement.fromMap(Map<String, dynamic> map) => DrawingElement(
    type: map['type'],
    color: map['color'],
    data: map['data'],
    pageNumber: map['page'] as int?,
  );
}

class DrawingState {
  final bool isEnabled;
  final bool isTextMode; // New field for text annotation mode
  final String selectedShape;
  final String selectedColor;
  final List<DrawingElement> elements;
  final List<List<DrawingElement>> undoHistory;
  final List<List<DrawingElement>> redoHistory;

  // Independent toggles for TR / SD toolbar states
  final bool trEnabled;
  final bool sdEnabled;

  DrawingState({
    this.isEnabled = false,
    this.isTextMode = false, // Default is false
    this.selectedShape = 'freehand',
    this.selectedColor = 'black',
    this.elements = const [],
    this.undoHistory = const [],
    this.redoHistory = const [],
    this.trEnabled = false,
    this.sdEnabled = false,
  });

  bool get canUndo => undoHistory.isNotEmpty;
  bool get canRedo => redoHistory.isNotEmpty;

  DrawingState copyWith({
    bool? isEnabled,
    bool? isTextMode,
    String? selectedShape,
    String? selectedColor,
    List<DrawingElement>? elements,
    List<List<DrawingElement>>? undoHistory,
    List<List<DrawingElement>>? redoHistory,
    bool? trEnabled,
    bool? sdEnabled,
  }) {
    return DrawingState(
      isEnabled: isEnabled ?? this.isEnabled,
      isTextMode: isTextMode ?? this.isTextMode,
      selectedShape: selectedShape ?? this.selectedShape,
      selectedColor: selectedColor ?? this.selectedColor,
      elements: elements ?? this.elements,
      undoHistory: undoHistory ?? this.undoHistory,
      redoHistory: redoHistory ?? this.redoHistory,
      trEnabled: trEnabled ?? this.trEnabled,
      sdEnabled: sdEnabled ?? this.sdEnabled,
    );
  }
}

class DrawingNotifier extends StateNotifier<DrawingState> {
  DrawingNotifier() : super(DrawingState());

  void toggleDrawing() {
    // When disabling drawing, also disable text mode
    if (state.isEnabled) {
      state = state.copyWith(isEnabled: false, isTextMode: false);
    } else {
      state = state.copyWith(isEnabled: true);
    }
  }

  void toggleTextMode() {
    // When enabling text mode, also enable drawing
    if (state.isTextMode) {
      state = state.copyWith(isTextMode: false);
    } else {
      state = state.copyWith(isEnabled: true, isTextMode: true);
    }
  }

  void setShape(String shape) {
    state = state.copyWith(selectedShape: shape);
  }

  void setColor(String color) {
    state = state.copyWith(selectedColor: color);
  }

  void addElement(DrawingElement element) {
    // Save current state to undo history
    final updatedUndoHistory = [...state.undoHistory, [...state.elements]];

    // Add new element
    final updatedElements = [...state.elements, element];

    // Clear redo history when a new action is performed
    state = state.copyWith(
      elements: updatedElements,
      undoHistory: updatedUndoHistory,
      redoHistory: [],
    );
  }

  void undo() {
    if (!state.canUndo) return;

    // Get last state from undo history
    final lastUndoState = state.undoHistory.last;
    final updatedUndoHistory =
    List<List<DrawingElement>>.from(state.undoHistory)..removeLast();

    // Add current state to redo history
    final updatedRedoHistory = [...state.redoHistory, [...state.elements]];

    // Restore state
    state = state.copyWith(
      elements: lastUndoState,
      undoHistory: updatedUndoHistory,
      redoHistory: updatedRedoHistory,
    );
  }

  void redo() {
    if (!state.canRedo) return;

    // Get last state from redo history
    final lastRedoState = state.redoHistory.last;
    final updatedRedoHistory =
    List<List<DrawingElement>>.from(state.redoHistory)..removeLast();

    // Add current state to undo history
    final updatedUndoHistory = [...state.undoHistory, [...state.elements]];

    // Restore state
    state = state.copyWith(
      elements: lastRedoState,
      undoHistory: updatedUndoHistory,
      redoHistory: updatedRedoHistory,
    );
  }

  void clearElements() {
    // Save current state to undo history
    final updatedUndoHistory = [...state.undoHistory, [...state.elements]];

    // Clear elements and redo history
    state = state.copyWith(
      elements: [],
      undoHistory: updatedUndoHistory,
      redoHistory: [],
    );
  }

  void loadElements(List<DrawingElement> loadedElements) {
    // When loading elements, we don't want to add to undo history
    state = state.copyWith(
      elements: loadedElements,
      undoHistory: [], // Reset history when loading
      redoHistory: [],
    );
  }

  void replaceAllElements(List<DrawingElement> newElements) {
    // Replace all elements and reset history
    state = state.copyWith(
      elements: newElements,
      undoHistory: [], // Reset undo history
      redoHistory: [], // Reset redo history
    );
  }

  // ---- Implemented independent toggles ----
  void toggleTR() {
    state = state.copyWith(trEnabled: !state.trEnabled);
  }

  void toggleSD() {
    state = state.copyWith(sdEnabled: !state.sdEnabled);
  }
}
// Family provider: each pane (single tab, split-left, split-right) can have
// independent drawing state keyed by a paneId string.
final drawingProviderFamily = StateNotifierProvider.family<
    DrawingNotifier, DrawingState, String>((ref, paneId) {
  return DrawingNotifier();
});

// Repository provider
final drawingRepositoryProvider = Provider<DrawingRepository>((ref) {
  return DrawingRepositoryImpl();
});
