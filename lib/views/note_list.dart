import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';    //package service locator, sebagai pengganti dari Provider/InheritedWidget
import 'package:notes/models/api_response.dart';
import 'package:notes/models/note_for_listing.dart';
import 'package:notes/views/note_delete.dart';
import 'package:notes/services/note_service.dart';

import 'note_modify.dart';

class NoteList extends StatefulWidget {

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  //kaya provider.of banget nih si GetIt :v,
  NoteService get service => GetIt.I<NoteService>();

  //property that going to represent the api response
  APIResponse<List<NoteForListing>> _apiResponse;
  bool _isLoading = false;

  String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  void initState() {
    _fetchNotes();
    super.initState();
  }

  _fetchNotes() async {
    setState(() {
      _isLoading = true;
    });

    _apiResponse = await service.getNotesList();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('List of notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => NoteModify()))  
            .then((_){  //berjalan hanya ketika si NoteModify screen sudah kembali/pop ke screen ini lagi, tujuan ditambah ini yaitu ketika NoteModify screennya sudah pop ke screen ini lagi maka dia akan merefresh halamannya
              _fetchNotes();  //cara merefreshnya yaitu dengan dipanggilnya method _fetchNotes() yg saya buat sebelumnya, karena didalamnya akan memanggil _apiResponse terbaru sehingga data yang di note_list screen pun terbaru juga
            });
        },
        child: Icon(Icons.add),
      ),
      body: Builder(
        builder: (_) {
          if(_isLoading){
            return Center(child: CircularProgressIndicator());
          }

          if(_apiResponse.error){
            return Center(child: Text(_apiResponse.errorMessage),);
          }

          return ListView.separated( //.separated itu biar bisa di divider/dibagi si itemnya dengan separatorBuilder
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.green),
            itemBuilder: (_, index) {
              return Dismissible(   //biar widget di dalamnya bisa dihapus, widget ini memang biasa di pakai di listview
                key: ValueKey(_apiResponse.data[index].noteID),  //tentu harus punya key yang unique, agar tau mana yang mau dihapus
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) {
                },
                confirmDismiss: (direction) async { //bool confirmDismiss, jika true maka terhapus, jika false maka tidak jadi terhapus
                  final result = await showDialog( //showDialog meampilkan popup diatas konten screen yg sedang berjalan
                    context: context,
                    builder: (_) => NoteDelete()
                  );
                  if (result) { //jika resultnya true
                    final deleteResult = await service.deleteNote(_apiResponse.data[index].noteID);

                    var message;
                    if (deleteResult != null && deleteResult.data == true) {
                      message = 'The note was deleted successfully';
                    } else {
                      //?. null safe operator.
                      //(deleteResult?.errorMessage) sama saja dengan (deleteResult !=null && deleteResult.errorMessage)
                      message = deleteResult?.errorMessage ?? 'An error occured';
                    }

                    showDialog(
                      context: context, builder: (_) => AlertDialog(
                        title: Text('Done'),
                        content: Text(message),
                        actions: <Widget>[
                          FlatButton(child: Text('Ok'), onPressed: (){
                            Navigator.of(context).pop();
                          })
                        ],
                      )
                    );

                    return deleteResult?.data ?? false;
                  }
                  print(result);
                  return result;
                },
                background: Container(  //ketika di dissmis/geser ke kanan widgetnya, maka backgroundnya warna merah dg icon sampah
                  color: Colors.red,
                  padding: EdgeInsets.only(left: 16),
                  child: Align(child: Icon(Icons.delete, color: Colors.white), alignment: Alignment.centerLeft,),
                ),
                child: ListTile(
                  title: Text(
                    _apiResponse.data[index].noteTitle,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  subtitle: Text('Last edited on ${formatDateTime(_apiResponse.data[index].latestEditDateTime ?? 
                  _apiResponse.data[index].createDateTime)}'),
                  onTap: () {
                    Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => NoteModify(noteID: _apiResponse.data[index].noteID))).then((data){
                        _fetchNotes();    //dikasi then agar setelah di .push dan kembali ke screen ini lagi maka akan memanggil _fetchNotes, dimana didalam fetchNotes ada setState untuk merefresh screen, sehingga data di screen ini menjadi data terbaru
                      });
                  },
                ),
              );
            },
            itemCount: _apiResponse.data.length,
          );
        },
      )
    );
  }
}