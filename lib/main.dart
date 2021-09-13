import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meus_testes/Rotas.dart';
import 'package:meus_testes/telas/Home.dart';

final ThemeData temaPadrao = ThemeData(
  primaryColor: Colors.blueGrey,
  accentColor: Colors.blueAccent
);

void main() async{

  //Inicialização do Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore db = FirebaseFirestore.instance;

  runApp(MaterialApp(
    title: "BUS FOR TOU",
    theme: temaPadrao,
    initialRoute: "/",
    onGenerateRoute: Rotas.gerarRotas,
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

