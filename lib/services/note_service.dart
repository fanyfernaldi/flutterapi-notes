import 'dart:convert';
import 'package:notes/models/api_response.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/note_for_listing.dart';
import 'package:http/http.dart' as http;
import 'package:notes/models/note_insert.dart';

class NoteService {

  static const API = 'http://api.notes.programmingaddict.com';
  static const headers = {
    'apiKey': '9215d558-6ed9-44c1-bb56-95e81e399c6d',
    'Content-Type': 'application/json'
  };

  Future<APIResponse<List<NoteForListing>>> getNotesList(){
    return http.get(API + '/notes', headers: headers).then((data) { //make the request
      if (data.statusCode == 200) {   
        final jsonData = json.decode(data.body);  //convert a raw body which is just a string to a map/list of map. Di kasus ini list of map karena dia get tanpa menyertakan id
        final notes = <NoteForListing>[];     //variabel notes nantinya digunakan u/ menyimpan convertan list of map di variabel jsonData ke list of objek
        for (var item in jsonData) {    //item is individual map
          // CARA 1, tanpa menggunakan factoy constructor
          // final note = NoteForListing(
          //   noteID: item['noteId'],
          //   noteTitle: item['noteTitle'],
          //   createDateTime: DateTime.parse(item['createDateTime']),
          //   latestEditDateTime: item['latestEditDateTime'] != null 
          //       ? DateTime.parse(item['latestEditDateTime'])
          //       : null,
          // );
          // notes.add(note);

          // CARA 2, menggunakan factory constructor, lebih rapi. Bingung? liat kodingan manualnya di atas
          // decoding our map into an actual dart object
          notes.add(NoteForListing.fromJson(item));
        }
        return APIResponse<List<NoteForListing>>(data: notes);
      }
      return APIResponse<List<NoteForListing>>(error: true, errorMessage: 'An error occured');
    })
    .catchError((_) => APIResponse<List<NoteForListing>>(error: true, errorMessage: 'An error occured'));
  }

  Future<APIResponse<Note>> getNote(String noteID){
    return http.get(API + '/notes/' + noteID, headers: headers).then((data){
      if(data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        // CARA 1, tanpa menggunakan factory constructor
        // final note = Note(
        //   noteID: jsonData['noteId'],
        //   noteTitle: jsonData['noteTitle'],
        //   noteContent: jsonData['noteContent'],
        //   createDateTime: DateTime.parse(jsonData['createDateTime']),
        //   latestEditDateTime: jsonData['latestEditDateTime'] != null
        //       ? DateTime.parse(jsonData['latestEditDateTime'])
        //       : null,
        // );
        // return APIResponse<Note>(data: note);

        // CARA 2, menggunakan factory constructor, lebih rapi. Bingung? liat kodingan manualnya di atas
        // decoding our map into an actual dart object
        return APIResponse<Note>(data: Note.fromJson(jsonData));
      }
      return APIResponse<Note>(error: true, errorMessage: 'An error occured');
    })
    .catchError((_) => APIResponse<Note>(error: true, errorMessage: 'An error occured'));
  }

  Future<APIResponse<bool>> createNote(NoteManipulation item){
    return http.post(API + '/notes', headers: headers, body: json.encode(item.toJson())).then((data){ //.toJson merupakan method yang saya buat di dalam class NoteManipulation, loc: models/note_insert.dart biar lebih rapi
      if(data.statusCode == 201){   //if successfull post | created
        return APIResponse<bool>(data: true);
      }
      return APIResponse<bool>(error: true, errorMessage: 'An error occured');
    })
    .catchError((_) => APIResponse<bool>(error: true, errorMessage: 'Anerror occured'));
  }

  Future<APIResponse<bool>> updateNote(String noteID, NoteManipulation item){
    return http.put(API + '/notes/' + noteID, headers: headers, body: json.encode(item.toJson())).then((data){
      if (data.statusCode == 204) {   //no content, doesnt return anything in the body. | biasa digunakan di method .update dan .delete jika request has succeded
        return APIResponse<bool>(data: true);
      }
      return APIResponse<bool>(error: true, errorMessage: 'An error occured');
    })
    .catchError((_) => APIResponse<bool>(error: true, errorMessage: 'An error occured'));
  }

  Future<APIResponse<bool>> deleteNote(String noteID){
    return http.delete(API + '/notes/' + noteID, headers: headers).then((data){
      if (data.statusCode == 204) {   //no content, doesnt return anything in the body. | biasa digunakan di method .update dan .delete jika request has succeded
        return APIResponse<bool>(data: true);
      }
      return APIResponse<bool>(error: true, errorMessage: 'An error occured');
    })
    .catchError((_) => APIResponse<bool>(error: true, errorMessage: 'An error occured'));
  }

}