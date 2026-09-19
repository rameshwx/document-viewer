
import 'package:aeroslate/presentation/providers/drawing_provider.dart';

abstract class DrawingRepository {
  /// Saves drawing elements for a document
  Future<void> saveDrawingElements(String documentId, List<DrawingElement> elements);

  /// Loads drawing elements for a document
  Future<List<DrawingElement>> loadDrawingElements(String documentId);

  /// Clears all drawing elements for a document
  Future<void> clearDrawingElements(String documentId);
}