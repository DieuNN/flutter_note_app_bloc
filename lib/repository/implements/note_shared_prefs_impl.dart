import 'dart:convert';
import 'dart:developer';

import 'package:note_app/models/entity/note.dart';
import 'package:note_app/repository/note_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteSharedPreferencesRepositoryImpl extends NoteRepository {
  // Using "notes" as key and json encoded saved notes to store as key and value

  Future<SharedPreferences> _getDatabase() async {
    log("Using shared Preferences!");
    var database = await SharedPreferences.getInstance();
    // init note id and note list
    database.getInt("note_number") ?? database.setInt("note_number", 0);
    database.get("notes") ?? database.setString("notes", jsonEncode([]));
    return database;
  }

  Future<List<Note>> _getSavedNote(SharedPreferences database) async {
    List<dynamic> notes =
        await jsonDecode(database.getString("notes") ?? jsonEncode([]));

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
      var id =  database.getInt("note_number");
      var notes = await _getSavedNote(database);
      log(jsonEncode(notes));
      notes.add(
        Note(
            id: id,
            title: note.title,
            content: note.content,
            color: note.color),
      );

      var encodedNotes = jsonEncode(notes);
      await database.setString("notes", encodedNotes);
      log("Note added: ${note.id}, ${note.title}, ${note.content}, ${note.color}");
      id = id! + 1;
     await  database.setInt("note_number", id);
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
      var encodedNotes =  jsonEncode(notes);
      await database.setString("notes", encodedNotes);
      var end = DateTime.now().millisecondsSinceEpoch;
      log("Note deleted, in ${end - start}ms");
      return true;
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
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

  @override
  Future<List<Note>> getNotes() async {
    try {
      var start = DateTime.now().millisecondsSinceEpoch;
      var database = await _getDatabase();
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
  Future<bool> updateNote({required var newNote, required num id}) async {
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
      database.setString("notes", encodedNotes);
      return true;
    } catch (e) {
      return false;
    }
  }
}
