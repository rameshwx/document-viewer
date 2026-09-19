import 'package:hive/hive.dart';

part 'drawing_model.g.dart';

@HiveType(typeId: 3) // Make sure this ID doesn't conflict with existing adapters
class DrawingModel extends HiveObject {
  @HiveField(0)
  final String documentId;

  @HiveField(1)
  final List<DrawingShape> shapes;

  DrawingModel({
    required this.documentId,
    required this.shapes,
  });
}

@HiveType(typeId: 4)
class DrawingShape extends HiveObject {
  @HiveField(0)
  final String type; // 'circle', 'square', 'freehand'

  @HiveField(1)
  final String color; // 'red', 'green', 'yellow', 'black', 'white'

  @HiveField(2)
  final List<Map<String, double>> coordinates; // List of points for the shape

  DrawingShape({
    required this.type,
    required this.color,
    required this.coordinates,
  });
}