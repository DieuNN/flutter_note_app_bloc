import 'dart:convert';
import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_app/models/entity/note.dart';
import 'package:note_app/repository/note_repository.dart';
import 'package:hive/hive.dart';

class NoteHiveRepositoryImpl extends NoteRepository {
  Future<LazyBox> _getDatabase() async {
    var database = await Hive.openLazyBox("note_db");
    var noteNumber = (await database.get("note_number") as int?) ?? 0;
    await database.put("note_number", noteNumber);
    ((await database.get("notes")) as String?) ??
        database.put("notes", jsonEncode([]));
    return database;
  }

  Future<List<Note>> _getSavedNote(LazyBox database) async {
    List<dynamic> notes = await jsonDecode(
        (await database.get("notes") as String?) ?? jsonEncode([]));
    List<Note> result = [];
    for (var note in notes) {
      result.add(Note(
          id: note["id"],
          title: note["title"],
          content: note["content"],
          color: note["color"]));
    }
    return result;
  }

  @override
  Future<bool> addNote({required Note note}) async {
    try {
      log("start adding note");
      var database = await _getDatabase();
      var id = await (database.get("note_number")) as int;
      log(id.toString());
      var notes = await _getSavedNote(database);
      log(jsonEncode(notes));
      notes.add(Note(
          id: id, title: note.title, content: note.content, color: note.color));

      var encodedNotes = jsonEncode(notes);
      await database.put("notes", encodedNotes);
      log("Note added");
      id = id + 1;
      await database.put("note_number", id);
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  @override
  Future<bool> deleteNote({required num id}) async {
    try {
      var start = DateTime.now().millisecondsSinceEpoch;
      log("Deleting note!");
      var database = await _getDatabase();
      var notes = await _getSavedNote(database);
      notes.removeWhere((element) => element.id == id);
      var encodedNotes = jsonEncode(notes);
      database.put("notes", encodedNotes);
      var end = DateTime.now().millisecondsSinceEpoch;
      log("Note deleted, in ${end - start}ms");
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Note?> getNote({required num noteId}) async {
    try {
      var database = await _getDatabase();
      var notes = await _getSavedNote(database);
      return notes.firstWhere((element) => element.id == noteId);
    } catch (e) {
      return null;
    }
  }

  int count = 0;

  @override
  Future<List<Note>> getNotes() async {
    count++;
    log("called $count time");
    try {
      var start = DateTime.now().millisecondsSinceEpoch;
      var database = await _getDatabase();
      log("getting notes");
      log("getting notes");
      var notes = await _getSavedNote(database);
      log("get ${notes.length}");
      log("notes is: ${jsonEncode(notes)}");
      var end = DateTime.now().millisecondsSinceEpoch;
      log("getting notes took ${end - start}ms");
      return notes;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  @override
  Future<List<Note>> searchNote({required String keyword}) async {
    try {
      var database = await _getDatabase();
      var notes = await _getSavedNote(database);
      List<Note> result = [];
      for (var note in notes) {
        if (note.title.toLowerCase().contains(keyword.toLowerCase())) {
          result.add(note);
        }
      }
      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> updateNote({required Note newNote, required num id}) async {
    try {
      var database = await _getDatabase();
      var notes = await _getSavedNote(database);

      // First, find which note should be update, then update with new note
      var noteToUpdate = notes.firstWhere((element) => element.id == id);
      for (int i = 0; i < notes.length; i++) {
        if (notes[i] == noteToUpdate) {
          notes[i] = newNote..id = noteToUpdate.id;
        }
      }

      var encodedNotes = jsonEncode(notes);
      database.put("notes", encodedNotes);
      return true;
    } catch (e) {
      return false;
    }
  }
}
