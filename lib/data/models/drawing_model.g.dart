// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrawingModelAdapter extends TypeAdapter<DrawingModel> {
  @override
  final int typeId = 3;

  @override
  DrawingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrawingModel(
      documentId: fields[0] as String,
      shapes: (fields[1] as List).cast<DrawingShape>(),
    );
  }

  @override
  void write(BinaryWriter writer, DrawingModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.documentId)
      ..writeByte(1)
      ..write(obj.shapes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DrawingShapeAdapter extends TypeAdapter<DrawingShape> {
  @override
  final int typeId = 4;

  @override
  DrawingShape read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrawingShape(
      type: fields[0] as String,
      color: fields[1] as String,
      coordinates: (fields[2] as List)
          .map((dynamic e) => (e as Map).cast<String, double>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, DrawingShape obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.color)
      ..writeByte(2)
      ..write(obj.coordinates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingShapeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
