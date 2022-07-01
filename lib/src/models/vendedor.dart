class Vendedor {
  int _VENDID;

  String _VENDNOME;
  String _VENDEMAIL;
  String _VENDCPF;
  String _VENDTEL;
  int _USUID;

  int get USUID => this._USUID;

  set USUID(int value) => this._USUID = value;

  get VENDNOME => this._VENDNOME;

  set VENDNOME(value) => this._VENDNOME = value;

  get VENDEMAIL => this._VENDEMAIL;

  set VENDEMAIL(value) => this._VENDEMAIL = value;

  get VENDCPF => this._VENDCPF;

  set VENDCPF(value) => this._VENDCPF = value;

  get VENDID => this._VENDID;

  set VENDID(value) => this._VENDID = value;

  get VENDTEL => this._VENDTEL;

  set VENDTEL(value) => this._VENDTEL = value;

 

  @override
  String toString() {
    return 'Vendedor(_VENDID: $_VENDID, _VENDNOME: $_VENDNOME, _VENDEMAIL: $_VENDEMAIL, _VENDCPF: $_VENDCPF, _VENDTEL: $_VENDTEL, _USUID: $_USUID)';
  }
}
