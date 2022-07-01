class ConfigModel {
  int id;
  String descontoItem;
  String descontoTotal;
  String formas;
  String custo;
  String obs;
  String valorVenda;
  String cnpjEmpresa;
  ConfigModel({
    this.id,
    this.descontoItem,
    this.descontoTotal,
    this.formas,
    this.custo,
    this.obs,
    this.valorVenda,
    this.cnpjEmpresa,
  });

  ConfigModel copyWith({
    int id,
    String descontoItem,
    String descontoTotal,
    String formas,
    String custo,
    String obs,
    String valorVenda,
    String cnpjEmpresa,
  }) {
    return ConfigModel(
      id: id ?? this.id,
      descontoItem: descontoItem ?? this.descontoItem,
      descontoTotal: descontoTotal ?? this.descontoTotal,
      formas: formas ?? this.formas,
      custo: custo ?? this.custo,
      obs: obs ?? this.obs,
      valorVenda: valorVenda ?? this.valorVenda,
      cnpjEmpresa: cnpjEmpresa ?? this.cnpjEmpresa,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descontoItem': descontoItem,
      'descontoTotal': descontoTotal,
      'formas': formas,
      'custo': custo,
      'obs': obs,
      'valorVenda': valorVenda,
      'cnpjEmpresa': cnpjEmpresa,
    };
  }

  factory ConfigModel.fromMap(Map<String, dynamic> map) {
    return ConfigModel(
      id: map['id']?.toInt(),
      descontoItem: map['descontoItem'],
      descontoTotal: map['descontoTotal'],
      formas: map['formas'],
      custo: map['custo'],
      obs: map['obs'],
      valorVenda: map['valorVenda'],
      cnpjEmpresa: map['cnpjEmpresa'],
    );
  }


  @override
  String toString() {
    return 'ConfigModel(id: $id, descontoItem: $descontoItem, descontoTotal: $descontoTotal, formas: $formas, custo: $custo, obs: $obs, valorVenda: $valorVenda, cnpjEmpresa: $cnpjEmpresa)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConfigModel &&
        other.id == id &&
        other.descontoItem == descontoItem &&
        other.descontoTotal == descontoTotal &&
        other.formas == formas &&
        other.custo == custo &&
        other.obs == obs &&
        other.valorVenda == valorVenda &&
        other.cnpjEmpresa == cnpjEmpresa;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        descontoItem.hashCode ^
        descontoTotal.hashCode ^
        formas.hashCode ^
        custo.hashCode ^
        obs.hashCode ^
        valorVenda.hashCode ^
        cnpjEmpresa.hashCode;
  }
}
