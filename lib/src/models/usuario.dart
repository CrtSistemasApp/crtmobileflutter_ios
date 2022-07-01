class Usuario {
  int id;
  String _nome, _usuario, _cpf, _telefone, _senha, _nivel;



  get nivel => _nivel;

  set nivel(value) {
    _nivel = value;
  }

  @override
  String toString() {
    return 'Usuario{nome: $_nome, usuario: $_usuario, cpf: $_cpf, telefone: $_telefone}';
  }

  get senha => _senha;

  set senha(value) {
    _senha = value;
  }

  get telefone => _telefone;

  set telefone(value) {
    _telefone = value;
  }

  get cpf => _cpf;

  set cpf(value) {
    _cpf = value;
  }

  get usuario => _usuario;

  set usuario(value) {
    _usuario = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }
}
