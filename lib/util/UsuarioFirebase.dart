import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meus_testes/model/Usuario.dart';


class UsuarioFirebase {

  static Future<User> getUsuarioAtual() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    return await auth.currentUser!;
  }
  static Future<Usuario> getDadosUsuarioLogado() async{
    User user = await getUsuarioAtual();
    String idUsuario = user.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot = await db.collection("usuarios")
        .doc(idUsuario)
        .get();
    Map<Object?, dynamic>? dados = snapshot.data() as Map<Object?, dynamic>?;
    String tipoUsuario = dados!["tipoUsuario"];
    String email = dados["email"];
    String nome = dados["nome"];

    Usuario usuario = Usuario();
    usuario.idUsuario = idUsuario;
    usuario.tipoUsuario = tipoUsuario;
    usuario.email = email;
    usuario.nome = nome;

    return usuario;
  }

}