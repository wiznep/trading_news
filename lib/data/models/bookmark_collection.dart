import 'package:hive/hive.dart';
part 'bookmark_collection.g.dart';

@HiveType(typeId: 1)
class BookmarkCollection {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String icon;

  @HiveField(3)
  final List<String> articleLinks;

  BookmarkCollection({
    required this.id,
    required this.name,
    required this.icon,
    this.articleLinks = const [],
  });
}
