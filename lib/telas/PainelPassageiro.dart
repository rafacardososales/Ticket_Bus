import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meus_testes/model/Destino.dart';
import 'package:meus_testes/model/Requisicao.dart';
import 'package:meus_testes/model/Usuario.dart';
import 'package:meus_testes/util/StatusRequisicao.dart';
import 'package:meus_testes/util/UsuarioFirebase.dart';

class PainelPassageiro extends StatefulWidget {
  const PainelPassageiro({Key? key}) : super(key: key);

  @override
  _PainelPassageiroState createState() => _PainelPassageiroState();
}

class _PainelPassageiroState extends State<PainelPassageiro> {
  TextEditingController _controllerLocal = TextEditingController();
  TextEditingController _controllerDestino = TextEditingController();
  TextEditingController _controllerData = TextEditingController();
  TextEditingController _controllerAssento = TextEditingController();
  TextEditingController _controllerTelefone = TextEditingController();

  Completer<GoogleMapController> _controller = Completer();

  List<String> itensMenu = ["Configurações", "Deslogar"];

  //controles para exibição na tela
  bool _exibirCaixasDeTextos = true;
  String _textoBotao = "Reservar";
  Color _corBotao = Colors.blueAccent;
  Function()? _funcaoBotao;
  String? _idRequisicao;

  _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, "/");
  }

  _escolhaMenuItem(String escolha) {
    switch (escolha) {
      case "Deslogar":
        _deslogarUsuario();
        break;
      case "Configurações":
        break;
    }
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _fazerReserva() async {
    Destino destino = Destino();
    destino.local = _controllerLocal.text;
    destino.destino = _controllerDestino.text;
    destino.data = _controllerData.text;
    destino.assento = _controllerAssento.text;
    destino.telefone = _controllerTelefone.text;

    String confirmacaoReserva;
    confirmacaoReserva = " Local: " + destino.local!;
    confirmacaoReserva += "\n Destino: " + destino.destino;
    confirmacaoReserva += "\n Data: " + destino.data!;
    confirmacaoReserva += "\n Assento do veiculo: " + destino.assento!;
    confirmacaoReserva += "\n Telefone de contato: " + destino.telefone!;

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Confirmar reserva?"),
            content: Text(confirmacaoReserva),
            contentPadding: EdgeInsets.all(30),
            actions: [
              FlatButton(
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                child: Text(
                  "Confirmar",
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () {
                  _salvarRequisicao(destino);

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  // metodo usado para salvar as reservas
  _salvarRequisicao(Destino destino) async {
    Usuario? passageiro = await UsuarioFirebase.getDadosUsuarioLogado();

    Requisicao requisicao = Requisicao();
    requisicao.destino = destino;
    requisicao.passageiro = passageiro;
    requisicao.status = StatusRequisicao.AGUARDANDO;

    // salva dados da requisicao
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("requisicoes").doc(requisicao.id).set(requisicao.toMap());

    //salva a requisição ativa no momento de cada passageiro
    Map<String, dynamic> dadosRequisicaoAtiva = {};
    dadosRequisicaoAtiva["id_requisicao"] = requisicao.id;
    dadosRequisicaoAtiva["id_usuario"] = passageiro.idUsuario;
    dadosRequisicaoAtiva["status"] = StatusRequisicao.AGUARDANDO;

    db
        .collection("requisicao_ativa")
        .doc(passageiro.idUsuario)
        .set(dadosRequisicaoAtiva);
  }

  _alterarBotaoPrincipal(String texto, Color cor, Function funcao) {
    setState(() {
      _textoBotao = texto;
      _corBotao = cor;
      _funcaoBotao = funcao as Function();
    });
  }

  _statusReservaNaoFeita() {
    _exibirCaixasDeTextos = true;
    _alterarBotaoPrincipal("Reservar", Colors.blueAccent, () {
      _fazerReserva();
    });
  }

  _statusAguardando() {
    _exibirCaixasDeTextos = false;
    _alterarBotaoPrincipal("Cancelar Reserva", Colors.red, () {
      _cancelarReserva();
    });
  }

  _cancelarReserva() async{
    User user = await UsuarioFirebase.getUsuarioAtual();
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("requisicoes")
        .doc(_idRequisicao)
        .update({
      "status" : StatusRequisicao.CANCELADA
    }).then((_){
      db.collection("requisicao_ativa")
          .doc(user.uid)
          .delete();
    });

  }

  _adicionarListenerRequisicaoAtiva() async {
    User firebaseUser = await UsuarioFirebase.getUsuarioAtual() as User;
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("requisicao_ativa")
        .doc(firebaseUser.uid)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.data() != null) {
            Map<String, dynamic>? dados = snapshot.data();
            String status = dados!["status"];
            _idRequisicao = dados["id_requisicao"];

            switch (status) {
              case StatusRequisicao.AGUARDANDO:
                _statusAguardando();
              break;
              case StatusRequisicao.A_CAMINHO:
                //_statusACaminho();
              break;
              case StatusRequisicao.VIAGEM:
              break;
              case StatusRequisicao.FINALIZADA:
              break;
        }
      }else {
            _statusReservaNaoFeita();
          }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // este metodo vai adicionar um ouvinte no requisiçao ativa
    _adicionarListenerRequisicaoAtiva();
    //_statusReservaNaoFeita();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel passageiro"),
        actions: [
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context) {
              return itensMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Container(
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(-18.895260137811253, -48.27780325679595),
                zoom: 16,
              ),
              onMapCreated: _onMapCreated,
              zoomControlsEnabled: false,
            ),
            Visibility(
              visible: _exibirCaixasDeTextos,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white),
                        child: TextField(
                          controller: _controllerLocal,
                          decoration: InputDecoration(
                              icon: Container(
                                margin: EdgeInsets.only(left: 20),
                                width: 15,
                                height: 25,
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                ),
                              ),
                              hintText: "Local de partida",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 5, top: 16, bottom: 15)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 55,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white),
                        child: TextField(
                          controller: _controllerDestino,
                          decoration: InputDecoration(
                              icon: Container(
                                margin: EdgeInsets.only(left: 20),
                                width: 15,
                                height: 25,
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                ),
                              ),
                              hintText: "Destino",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 5, top: 16, bottom: 15)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 110,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white),
                        child: TextField(
                          controller: _controllerData,
                          decoration: InputDecoration(
                              icon: Container(
                                margin: EdgeInsets.only(left: 20),
                                width: 15,
                                height: 25,
                                child: Icon(
                                  Icons.date_range,
                                  color: Colors.blue,
                                ),
                              ),
                              hintText: "Data da viagem",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 5, top: 16, bottom: 15)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 220,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white),
                        child: TextField(
                          controller: _controllerTelefone,
                          decoration: InputDecoration(
                              icon: Container(
                                margin: EdgeInsets.only(left: 20),
                                width: 15,
                                height: 25,
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.black,
                                ),
                              ),
                              hintText: "Telefone",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 5, top: 16, bottom: 15)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 165,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white),
                        child: TextField(
                          controller: _controllerAssento,
                          decoration: InputDecoration(
                              icon: Container(
                                margin: EdgeInsets.only(left: 20),
                                width: 15,
                                height: 25,
                                child: Icon(
                                  Icons.chair,
                                  color: Colors.deepOrangeAccent,
                                ),
                              ),
                              hintText: "Numero do assento",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 5, top: 16, bottom: 15)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: RaisedButton(
                  child: Text(
                    _textoBotao,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  color: _corBotao,
                  padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                  onPressed: _funcaoBotao,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
