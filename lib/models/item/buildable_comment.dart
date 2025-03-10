import 'package:hacki/models/item/buildable.dart';
import 'package:hacki/models/item/comment.dart';
import 'package:linkify/linkify.dart';

/// [BuildableComment] is a subtype of [Comment] which stores
/// the corresponding [LinkifyElement] for faster widget building.
class BuildableComment extends Comment with Buildable {
  BuildableComment({
    required super.id,
    required super.time,
    required super.parent,
    required super.score,
    required super.by,
    required super.text,
    required super.kids,
    required super.dead,
    required super.deleted,
    required super.level,
    required this.elements,
  });

  BuildableComment.fromComment(Comment comment, {required this.elements})
      : super(
          id: comment.id,
          time: comment.time,
          parent: comment.parent,
          score: comment.score,
          by: comment.by,
          text: comment.text,
          kids: comment.kids,
          dead: comment.dead,
          deleted: comment.deleted,
          level: comment.level,
        );

  @override
  final List<LinkifyElement> elements;
}
