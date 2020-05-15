class APIResponse<T>{ //bebas mau T atau apa, parameter T disini nantinya akan digunakan sebagai tipe dari body yang direturn dari API
  T data;     //data akan menyimpan data2 yang direturn dari API, T merupakan generic type
  bool error;   
  String errorMessage;

  APIResponse({this.data, this.errorMessage, this.error=false});
}