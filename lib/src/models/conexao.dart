class Conexao {
  int id;

  String host, bdname, user, pass;

  Conexao({this.id, this.host, this.bdname, this.user, this.pass});

  Map<String, dynamic> toJson() => {
        //'id': id,
        'host': host,
        'bdname': bdname,
        'usuario': user,
        'senha': pass,
      };

  factory Conexao.fromMap(Map<String, dynamic> json) {
    return Conexao(
      id: json['id'].toInt(),
      host: json['host'],
      bdname: json["bdname"],
      user: json["usuario"],
      pass: json["senha"],
    );
  }

  @override
  String toString() {
    return 'Conexao{id:$id, host: $host, bdname: $bdname, user: $user, pass: $pass}';
  }
}
