import 'package:note_app/models/entity/note.dart';
import 'package:note_app/repository/note_repository.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'dart:developer';
import 'package:path/path.dart' as path;

class NoteSqliteRepositoryImpl implements NoteRepository {
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
    try {
      var database = await _getDatabase();
      Map<String, Object?> note = (await database.rawQuery(
              "select id, title, content, color from note where id = ?",
              [noteId]))
          .first;

      String title = note["title"].toString();
      int id = int.parse(note["id"].toString());
      String content = note["content"].toString();
      String color = note["color"].toString();
      log("${note}");
      return Note(id: id, title: title, content: content, color: color);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  @override
  Future<List<Note>> getNotes() async {
    try {
      log("Getting notes ...");
      var database = await _getDatabase();
      List<Map<String, Object?>> notes = (await database
          .rawQuery("select id, title, content, color from note"));
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
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  @override
  Future<bool> updateNote({required Note newNote, required num id}) async {
    var database = await _getDatabase();
    log("In NoteSqlite, color is: ${newNote.color}");
    int result = await database.rawUpdate(
        "update note set title = ?, content = ?, color = ? where id = ?",
        [newNote.title, newNote.content, newNote.color, id]);
    if (result > 0) {
      log("Update note result: $result");
      log("Updated at $id, value: $newNote");
    }
    return result > 0;
  }

  @override
  Future<List<Note>> searchNote({required String keyword}) async {
    var database = await _getDatabase();
    List<Map<String, Object?>> notes = (await database.rawQuery(
        "select id, title, content, color from note where title like '%$keyword%'"));

    List<Note> result = [];

    for (var note in notes) {
      String title = note["title"].toString();
      int id = int.parse(note["id"].toString());
      String content = note["content"].toString();
      String color = note["color"].toString();

      result.add(Note(id: id, title: title, content: content, color: color));
    }
    log(result.length.toString());

    return result;
  }
}
