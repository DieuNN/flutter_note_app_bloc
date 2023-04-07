import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int? id;
  final String title;
  final dynamic content;
  final String color;

  const Note(
      {required this.id,
      required this.title,
      required this.content,
      required this.color});

  @override
  List<Object?> get props => [id, title, content, color];

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is Note && id == other.id;
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "title": title, "content": content, "color": color};
  }
}
