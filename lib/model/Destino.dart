
class Destino {

  String? _destinoDestino;
  String? _localPartida;
  String? _data;
  String? _assento;
  String? _telefone;

  String get destino => _destinoDestino!;

  set destino(String value) {
    _destinoDestino = value;
  }

  Destino();

  String? get local => _localPartida;

  String? get telefone => _telefone;

  set telefone(String? value) {
    _telefone = value;
  }

  String? get assento => _assento;

  set assento(String? value) {
    _assento = value;
  }

  String? get data => _data;

  set data(String? value) {
    _data = value;
  }

  set local(String? value) {
    _localPartida = value;
  }
}