import 'dart:convert';

class Produto {
  int _PROID;
  String _PRONOME;
  String _PRODESCRICAO;
  String _PROIMAGEM;
  double _quantity;
  double _PROVALOR;
  String get PRONOME => _PRONOME;
  String _PROOBS;
  double _PRECOCUSTO;
  double _PROVALORDESCONTO;
  List _dados;

  List get dados => this._dados;

  set dados(List value) => this._dados = value;
  String _PROREFERENCIA;
  String _COR;
  String _TAMANHO;
  int _corid;
  int _tamid;
  bool edit;

  bool get getEdit => this.edit;

  set setEdit(bool edit) => this.edit = edit;

  int get corid => this._corid;

  set corid(int value) => this._corid = value;

  get tamid => this._tamid;

  set tamid(value) => this._tamid = value;

  get COR => this._COR;

  set COR(value) => this._COR = value;

  get TAMANHO => this._TAMANHO;

  set TAMANHO(value) => this._TAMANHO = value;

  get PROVALORDESCONTO => this._PROVALORDESCONTO;

  set PROVALORDESCONTO(value) => this._PROVALORDESCONTO = value;

  double get PRECOCUSTO => this._PRECOCUSTO;

  set PRECOCUSTO(double value) => this._PRECOCUSTO = value;

  double get quantity => _quantity;

  set quantity(double value) {
    _quantity = value;
  }

  String get PROOBS => this._PROOBS;

  set PROOBS(String value) => this._PROOBS = value;

  set PRONOME(String value) {
    _PRONOME = value;
  }

  int get PROID => _PROID;

  set PROID(int value) {
    _PROID = value;
  }

  get PRODESCRICAO => _PRODESCRICAO;

  set PRODESCRICAO(value) {
    _PRODESCRICAO = value;
  }

  get PROVALOR => _PROVALOR;

  set PROVALOR(value) {
    _PROVALOR = value;
  }

  get PROREFERENCIA => _PROREFERENCIA;

  set PROREFERENCIA(value) {
    _PROREFERENCIA = value;
  }

  get PROIMAGEM => _PROIMAGEM;

  set PROIMAGEM(value) {
    _PROIMAGEM = value;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Produto &&
        other._PROID == _PROID &&
        other._PRONOME == _PRONOME &&
        other._PROIMAGEM == _PROIMAGEM &&
        other._PROVALOR == _PROVALOR &&
        other._PROVALORDESCONTO == _PROVALORDESCONTO &&
        other._PROREFERENCIA == _PROREFERENCIA &&
        other._COR == _COR &&
        other._TAMANHO == _TAMANHO &&
        other._corid == _corid &&
        other._tamid == _tamid;
  }

  @override
  int get hashCode {
    return _PROID.hashCode ^
        _PRONOME.hashCode ^
        _PROIMAGEM.hashCode ^
        _PROVALOR.hashCode ^
        _PROVALORDESCONTO.hashCode ^
        _PROREFERENCIA.hashCode ^
        _COR.hashCode ^
        _TAMANHO.hashCode ^
        _corid.hashCode ^
        _tamid.hashCode;
  }

  @override
  String toString() {
    return 'Produto(_PROID: $_PROID, _PRONOME: $_PRONOME, _PRODESCRICAO: $_PRODESCRICAO, _PROIMAGEM: $_PROIMAGEM, _quantity: $_quantity, _PROVALOR: $_PROVALOR, _PROOBS: $_PROOBS, _PRECOCUSTO: $_PRECOCUSTO, _PROVALORDESCONTO: $_PROVALORDESCONTO, _dados: $_dados, _PROREFERENCIA: $_PROREFERENCIA, _COR: $_COR, _TAMANHO: $_TAMANHO, _corid: $_corid, _tamid: $_tamid, edit: $edit)';
  }
}
