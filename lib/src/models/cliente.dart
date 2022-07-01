class Cliente {
  int tipoPessoa;
  int id, munid;
  String razao,
      cpf_cnpj,
      nomeFantasia,
      rg_ie,
      tel1,
      tel2,
      email,
      site,
      obs,
      logradouro,
      cidade,
      bairro,
      cep,
      uf;

  Cliente(
      {this.id,
      this.munid,
      this.razao,
      this.cpf_cnpj,
      this.nomeFantasia,
      this.rg_ie,
      this.tel1,
      this.tel2,
      this.email,
      this.site,
      this.obs,
      this.tipoPessoa,
      this.logradouro,
      this.cidade,
      this.bairro,
      this.cep,
      this.uf});

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
        razao: json['razaosocial'],
        munid: int.parse(json['munid']),
        cpf_cnpj: json['cpf_cnpj'],
        nomeFantasia: json['nomeFantasia'],
        rg_ie: json['rg_ie'],
        tel1: json['tel1'],
        tel2: json['tel2'],
        email: json['email'],
        site: json['site'],
        obs: json['obs'],
        tipoPessoa: int.parse(json['tipoPessoa']),
        logradouro: json['logradouro'],
        cidade: json['cidade'],
        bairro: json['bairro'],
        cep: json['cep'],
        uf: json['uf']);
  }

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'nomeFantasia': nomeFantasia,
        'munid': munid.toString(),
        'razaosocial': razao,
        'cpf_cnpj': cpf_cnpj,
        'tipoPessoa': tipoPessoa.toString(),
        'rg_ie': rg_ie,
        'email': email,
        'tel1': tel1,
        'tel2': tel2,
        'logradouro': logradouro,
        'cidade': cidade,
        'bairro': bairro,
        'cep': cep,
        'uf': uf,
        'site': site,
        'obs': obs,
      };

  @override
  String toString() {
    return 'Cliente{id: $id, razao: $razao, cpf_cnpj: $cpf_cnpj, munid: $munid, nomeFantasia: $nomeFantasia, email: $email, logradouro: $logradouro, cidade: $cidade, uf: $uf}';
  }
}
