


class Usuario{

  String? _idUsuario;
  String? _nome;
  String? _email;
  String? _senha;
  String? _telefone;
  String? _reserva;
  String? _data;
  String? _tipoUsuario;

  Usuario();

  Map<String, dynamic> toMap(){
    Map <String, dynamic> map ={
      "nome" : this.nome,
      "email" : this.email,
      "tipoUsuario" : this._tipoUsuario,
      "telefone" : this.telefone,
      "data" : this.data,
      "reserva" : this.reserva,
    };
    return map;
  }



  String verificaTipoUsuario (bool tipoUsuario){
    return tipoUsuario ? "motorista" : "passageiro";
  }


  String get tipoUsuario => _tipoUsuario!;

  set tipoUsuario(String value) {
    _tipoUsuario = value;
  }

  String? get data => _data;

  set data(String? value) {
    _data = value;
  }

  String? get reserva => _reserva;

  set reserva(String? value) {
    _reserva = value;
  }

  String? get telefone => _telefone;

  set telefone(String? value) {
    _telefone = value;
  }

  String? get senha => _senha!;

  set senha(String? value) {
    _senha = value;
  }

  String? get email => _email;

  set email(String? value) {
    _email = value;
  }

  String? get nome => _nome;

  set nome(String? value) {
    _nome = value;
  }

  String? get idUsuario => _idUsuario;

  set idUsuario(String? value) {
    _idUsuario = value;
  }
}