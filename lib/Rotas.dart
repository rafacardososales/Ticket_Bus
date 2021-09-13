import 'package:flutter/material.dart';
import 'package:meus_testes/telas/Cadastro.dart';
import 'package:meus_testes/telas/Home.dart';
import 'package:meus_testes/telas/PainelMotorista.dart';
import 'package:meus_testes/telas/PainelPassageiro.dart';

class Rotas{
  static Route<dynamic>? gerarRotas(RouteSettings settings){
    switch(settings.name){
      case "/" :
        return MaterialPageRoute(
          builder: (_)=> Home()
        );
      case "/Cadastro" :
        return MaterialPageRoute(
          builder: (_)=> Cadastro()
        );
      case "/painel-motorista" :
        return MaterialPageRoute(
            builder: (_)=> PainelMotorista()
        );
      case "/painel-passageiro" :
        return MaterialPageRoute(
            builder: (_)=> PainelPassageiro()
        );
      default: _erroRota();
    }
  }
  static Route<dynamic>? _erroRota(){
    return MaterialPageRoute(
      builder: (_){
        return Scaffold(
          appBar: AppBar(title: Text("Tela não encontrada"),),
          body: Center(
            child: Text("Tela não encontrada"),
          ),
        );
      }
    );
  }
}