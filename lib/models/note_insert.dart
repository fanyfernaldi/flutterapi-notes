import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

//model ini digunakan untuk create dan juga untuk update. Kenapa? karena di API, method POST dan PUT bodynya sama, sehingga bisa digunakan barengan
class NoteManipulation {
  String noteTitle;
  String noteContent;

  NoteManipulation({
    @required this.noteTitle,
    @required this.noteContent
  });

  Map<String, dynamic> toJson() {
    return {
      "noteTitle": noteTitle,     //keynya harus ssama dengan body yang diminta pada API
      "noteContent": noteContent
    };
  }
}

