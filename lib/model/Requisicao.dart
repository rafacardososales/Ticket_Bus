
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meus_testes/model/Destino.dart';
import 'package:meus_testes/model/Usuario.dart';

class Requisicao{
  String? _id;
  String? _status;
  Usuario? _passageiro;
  Usuario? _motorista;
  Destino? _destino;

  Requisicao(){
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference ref  = db.collection("requisicoes").doc();
    this.id = ref.id;
  }

  Map<String, dynamic> toMap(){
    Map <String, dynamic> dadosPassageiro ={
      "nome" : this.passageiro!.nome,
      "email" : this.passageiro!.email,
      "tipoUsuario" : this.passageiro!.tipoUsuario,
      "idUsuario" : this.passageiro!.idUsuario,

    };
    Map <String, dynamic> dadosDestino ={
      "destino" : this.destino!.destino,
      "localPartida" : this.destino!.local,
      "data" : this.destino!.data,
      "assento" : this.destino!.assento,
      "telefone" : this.destino!.telefone,

    };

    Map <String, dynamic> dadosRequisicao ={
      "id" : this.id,
      "status" : this.status,
      "passageiro" : dadosPassageiro,
      "motorista" : null,
      "destino" : dadosDestino,

    };
    return dadosRequisicao;
  }


  Destino? get destino => _destino;

  set destino(Destino? value) {
    _destino = value;
  }

  Usuario? get motorista => _motorista;

  set motorista(Usuario? value) {
    _motorista = value;
  }

  Usuario? get passageiro => _passageiro;

  set passageiro(Usuario? value) {
    _passageiro = value;
  }

  String? get status => _status;

  set status(String? value) {
    _status = value;
  }

  String? get id => _id;

  set id(String? value) {
    _id = value;
  }
}