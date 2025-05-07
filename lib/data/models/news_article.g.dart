// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_article.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NewsArticleAdapter extends TypeAdapter<NewsArticle> {
  @override
  final int typeId = 0;

  @override
  NewsArticle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NewsArticle(
      id: fields[0] as String,
      title: fields[1] as String,
      link: fields[2] as String,
      pubDate: fields[3] as String,
      description: fields[4] as String,
      categories: (fields[5] as List).cast<String>(),
      imageUrl: fields[6] as String?,
      source: fields[7] as String,
      isRead: fields[8] as bool,
      relatedStocks: (fields[9] as List?)?.cast<String>(),
      stockImpact: fields[10] as String?,
      sentimentScore: fields[11] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, NewsArticle obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.link)
      ..writeByte(3)
      ..write(obj.pubDate)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.categories)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.source)
      ..writeByte(8)
      ..write(obj.isRead)
      ..writeByte(9)
      ..write(obj.relatedStocks)
      ..writeByte(10)
      ..write(obj.stockImpact)
      ..writeByte(11)
      ..write(obj.sentimentScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
