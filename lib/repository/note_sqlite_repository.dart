import 'dart:developer';

import 'package:note_app/models/entity/note.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

abstract class NoteSqliteRepository {
  Future<List<Note>?> getNotes();

  Future<Note?> getNote({required num noteId});

  Future<bool> addNote({required Note note});

  Future<bool> updateNote({required Note note, required num id});

  Future<bool> deleteNote({required num id});
}

class NoteSqliteRepositoryImpl implements NoteSqliteRepository {
  Future<void> initDatabase() async {
    _createDatabase(await _getDatabase());
  }

  Future<void> _createDatabase(sql.Database database) async {
    await database.execute(
        "CREATE TABLE IF NOT EXISTS note (id integer PRIMARY KEY AUTOINCREMENT NOT NULL, title text, content text, color text )");
    log("SQLite database created!");
  }

  Future<sql.Database> _getDatabase() async {
    var databasePath = path.join(await sql.getDatabasesPath(), "note.db");
    return sql.openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await _createDatabase(db);
      },
    );
  }

  @override
  Future<bool> addNote({required Note note}) async {
    var database = await _getDatabase();
    int result = await database.rawInsert(
      "insert into note values(?, ?, ?, ?) ",
      [null, note.title, note.content, note.color],
    );

    return result > 0;
  }

  @override
  Future<bool> deleteNote({required num id}) async {
    var database = await _getDatabase();
    int result =
        await database.rawDelete("delete from note where id = ?", [id]);
    return result > 0;
  }

  @override
  Future<Note?> getNote({required num noteId}) async {
    var database = await _getDatabase();
    Map<String, Object?> note = (await database.rawQuery(
            "select id, title, content, color from note where id = ?",
            [noteId]))
        .first;
    String title = note["title"].toString();
    int id = int.parse(note["id"].toString());
    String content = note["content"].toString();
    String color = note["color"].toString();
    return Note(id: id, title: title, content: content, color: color);
  }

  @override
  Future<List<Note>?> getNotes() async {
    log("Getting notes ...");
    var database = await _getDatabase();
    List<Map<String, Object?>> notes =
        (await database.rawQuery("select id, title, content, color from note"));
    log("Notes: ${notes.length}");
    List<Note> result = [];

    for (var note in notes) {
      String title = note["title"].toString();
      int id = int.parse(note["id"].toString());
      String content = note["content"].toString();
      String color = note["color"].toString();

      result.add(Note(id: id, title: title, content: content, color: color));
    }

    return result;
  }

  @override
  Future<bool> updateNote({required Note note, required num id}) async {
    var database = await _getDatabase();
    int result = await database.rawUpdate(
        "update note set title = ?, content = ?, color = ? where id = ?",
        [note.title, note.content, note.color, id]);
    if (result > 0) {
      log("Updated at $id, value: $note");
    }
    return result > 0;
  }
}
