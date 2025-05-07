// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_collection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookmarkCollectionAdapter extends TypeAdapter<BookmarkCollection> {
  @override
  final int typeId = 1;

  @override
  BookmarkCollection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookmarkCollection(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      articleLinks: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, BookmarkCollection obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.articleLinks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkCollectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
