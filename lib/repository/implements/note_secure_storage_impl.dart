import 'dart:convert';
import 'dart:developer';

import 'package:note_app/models/entity/note.dart';
import 'package:note_app/repository/note_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NoteSecureStorageImpl extends NoteRepository {
  Future<FlutterSecureStorage> _getDatabase() async {
    var database = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
    (await database.read(key: "note_number")) ??
        (await database.write(key: "note_number", value: 0.toString()));
    (await database.read(key: "notes")) ??
        (await database.write(key: "notes", value: jsonEncode([])));

    return database;
  }

  Future<List<Note>> _getSavedNote(FlutterSecureStorage database) async {
    List<dynamic> notes =
        jsonDecode((await database.read(key: "notes")) ?? jsonEncode([]));

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
      var database = await _getDatabase();
      var id = await database.read(key: "note_number");
      var notes = await _getSavedNote(database);
      notes.add(
        Note(
            id: int.parse(id!),
            title: note.title,
            content: note.content,
            color: note.color),
      );

      var encodedNotes = jsonEncode(notes);
      await database.write(key: "notes", value: encodedNotes);
      id = (int.parse(id) + 1).toString();
      await database.write(key: "note_number", value: id.toString());
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
      await database.write(key: "notes", value: encodedNotes);
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
      database.write(key: "notes", value: encodedNotes);
      return true;
    } catch (e) {
      return false;
    }
  }
}
