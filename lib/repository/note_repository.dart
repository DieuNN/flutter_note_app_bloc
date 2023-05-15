
import 'package:note_app/models/entity/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes();

  Future<Note?> getNote({required num noteId});

  Future<bool> addNote({required Note note});

  Future<bool> updateNote({required Note newNote, required num id});

  Future<bool> deleteNote({required num id});

  Future<List<Note>> searchNote({required String keyword});
}

