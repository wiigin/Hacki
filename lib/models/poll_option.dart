import 'dart:convert';

import 'package:hacki/models/item.dart';

class PollOption extends Item {
  const PollOption({
    required super.id,
    required super.score,
    required super.time,
    required super.parent,
    required super.by,
    required super.title,
    required super.text,
    required super.type,
    required super.url,
    required super.kids,
    required super.parts,
    required this.ratio,
  }) : super(
          descendants: 0,
          dead: false,
          deleted: false,
        );

  PollOption.empty()
      : ratio = 0,
        super.empty();

  PollOption.fromJson(super.json)
      : ratio = 0,
        super.fromJson();

  final double ratio;

  PollOption copyWith({double? ratio}) {
    return PollOption(
      id: id,
      score: score,
      time: time,
      parent: parent,
      by: by,
      title: title,
      text: text,
      type: type,
      url: url,
      kids: kids,
      parts: parts,
      ratio: ratio ?? this.ratio,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'descendants': descendants,
      'id': id,
      'score': score,
      'time': time,
      'by': by,
      'title': title,
      'url': url,
      'kids': kids,
      'text': text,
      'dead': dead,
      'deleted': deleted,
      'type': type,
      'parts': parts,
      'ratio': ratio,
    };
  }

  @override
  String toString() {
    final String prettyString =
        const JsonEncoder.withIndent('  ').convert(this);
    return 'PollOption $prettyString';
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        score,
        descendants,
        time,
        by,
        title,
        url,
        kids,
        dead,
        parts,
        deleted,
        parent,
        text,
        type,
      ];
}
