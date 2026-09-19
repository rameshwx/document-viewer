import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aeroslate/presentation/providers/drawing_provider.dart';
import 'package:aeroslate/core/constants/app_constants.dart';

import 'drawing_repository.dart';

class DrawingRepositoryImpl implements DrawingRepository {
  Future<Box<dynamic>> _openBox() async {
    if (!Hive.isBoxOpen(AppConstants.drawingsBoxName)) {
      return await Hive.openBox(AppConstants.drawingsBoxName);
    }
    return Hive.box(AppConstants.drawingsBoxName);
  }

  @override
  Future<void> saveDrawingElements(
      String documentId, List<DrawingElement> elements) async {
    try {
      final box = await _openBox();

      // Convert elements to Map for storage
      final elementsMap = elements.map((e) => e.toMap()).toList();

      // Save the data
      await box.put(documentId, elementsMap);

      // Explicitly flush for web persistence
      await box.flush();

      debugPrint('Saved ${elements.length} drawings for document $documentId');
    } catch (e) {
      debugPrint('Error saving drawing elements: $e');
      rethrow;
    }
  }

  @override
  Future<List<DrawingElement>> loadDrawingElements(String documentId) async {
    try {
      final box = await _openBox();

      // Get stored elements, default to empty list
      final elementsData = box.get(documentId);

      if (elementsData == null) {
        debugPrint('No drawings found for document $documentId');
        return [];
      }

      // Convert stored data back to DrawingElement objects
      final List<dynamic> elementsMap = elementsData as List;

      final elements = elementsMap.map((e) {
        return DrawingElement.fromMap(Map<String, dynamic>.from(e));
      }).toList();

      debugPrint('Loaded ${elements.length} drawings for document $documentId');
      return elements;
    } catch (e) {
      debugPrint('Error loading drawing elements: $e');
      return [];
    }
  }

  @override
  Future<void> clearDrawingElements(String documentId) async {
    try {
      final box = await _openBox();
      await box.delete(documentId);
      await box.flush(); // Explicitly flush for web persistence
      debugPrint('Cleared all drawings for document $documentId');
    } catch (e) {
      debugPrint('Error clearing drawing elements: $e');
      rethrow;
    }
  }
}
