import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/note_insert.dart';
import 'package:notes/services/note_service.dart';

class NoteModify extends StatefulWidget {
 
  final String noteID;
  NoteModify({this.noteID});

  @override
  _NoteModifyState createState() => _NoteModifyState();
}

class _NoteModifyState extends State<NoteModify> {
  bool get isEditing => widget.noteID != null;

  //kaya provider.of banget nih si GetIt :v,
  NoteService get noteService => GetIt.I<NoteService>();

  String errorMessage;
  Note note;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (isEditing){
      setState(() {
        _isLoading = true;
      });
      noteService.getNote(widget.noteID)
        .then((response){   //bebas mau namanya response atau apa, response disini alias objek dari class Note 
          setState(() {
            _isLoading = false;
          });  

          if(response.error) {
            errorMessage = response.errorMessage ?? 'An error occured';
          }
          note = response.data;
          _titleController.text = note.noteTitle;
          _contentController.text = note.noteContent;
        }); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit note' : 'Create note')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _isLoading ? Center(child: CircularProgressIndicator()) : Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Note title'
              ),
            ),

            Container(height: 8),

            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: 'Note content'
              ),
            ),

            Container(height: 16),

            SizedBox(
              width: double.infinity,
              height: 35,
              child: RaisedButton(
                child: Text('Submit', style: TextStyle(color: Colors.white)),
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  if(isEditing){
                    // update note
                    setState(() {
                      _isLoading = true;
                    });
                    final note = NoteManipulation(
                      noteTitle: _titleController.text,   //.text itu bawaan controller yg berarti dia ngambil text yang ada di textfieldnya controller tsb | FANY haruse udah paham
                      noteContent: _contentController.text,
                    );
                    final result = await noteService.updateNote(widget.noteID, note);

                    setState(() {
                      _isLoading = false;
                    });
                    final title = "Done";
                    final text = result.error ? (result.errorMessage ?? 'An error occured') : 'Your note was updated';

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(title),
                        content: Text(text),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Ok'),
                            onPressed: (){
                              Navigator.of(context).pop();  //pop showDialog
                            },
                          )
                        ],
                      )
                    )
                    .then((data){
                      if(result.data) { //if(true)
                        Navigator.of(context).pop();    //pop  note_modify screen, sehingga balik ke note_list screen
                      }
                    });
                  } else {
                    // create note
                    setState(() {
                      _isLoading = true;
                    });
                    final note = NoteManipulation(
                      noteTitle: _titleController.text,   //.text itu bawaan controller yg berarti dia ngambil text yang ada di textfieldnya controller tsb | FANY haruse udah paham
                      noteContent: _contentController.text,
                    );
                    final result = await noteService.createNote(note);

                    setState(() {
                      _isLoading = false;
                    });
                    final title = "Done";
                    final text = result.error ? (result.errorMessage ?? 'An error occured') : 'Your note was created';

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(title),
                        content: Text(text),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Ok'),
                            onPressed: (){
                              Navigator.of(context).pop();  //pop showDialog
                            },
                          )
                        ],
                      )
                    )
                    .then((data){
                      if(result.data) { //if(true)
                        Navigator.of(context).pop();    //pop  note_modify screen, sehingga balik ke note_list screen
                      }
                    });
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}