import 'dart:convert';
import 'package:flutter/cupertino.dart';

class ConfigProvider extends ChangeNotifier {
  ConfigProvider config;
  int VENID;
  int USUID;
  int EMPID;
  int HABDESCONTO;
  int HABCONDPAGAMENTO;
  int CLIENTESDOVENDEDOR;
  int PRODUTOSZERADOS;
  int PRECODECUSTO;
  int ULTIMOVALORVENDA;
  int TIPODESCONTO;
  int ALTVALORPRODUTOVENDA;
  int TELAFORMAPAGAMENTO;
  ConfigProvider({
    this.VENID,
    this.USUID,
    this.EMPID,
    this.HABDESCONTO,
    this.HABCONDPAGAMENTO,
    this.CLIENTESDOVENDEDOR,
    this.PRODUTOSZERADOS,
    this.PRECODECUSTO,
    this.ULTIMOVALORVENDA,
    this.TIPODESCONTO,
    this.ALTVALORPRODUTOVENDA,
    this.TELAFORMAPAGAMENTO,
  });

  void setConfig(ConfigProvider con) {
    this.config = con;
    notifyListeners();
  }

  ConfigProvider copyWith({
    int VENID,
    int USUID,
    int EMPID,
    int HABDESCONTO,
    int HABCONDPAGAMENTO,
    int CLIENTESDOVENDEDOR,
    int PRODUTOSZERADOS,
    int PRECODECUSTO,
    int ULTIMOVALORVENDA,
    int TIPODESCONTO,
    int ALTVALORPRODUTOVENDA,
    int TELAFORMAPAGAMENTO,
  }) {
    return ConfigProvider(
      VENID: VENID ?? this.VENID,
      USUID: USUID ?? this.USUID,
      EMPID: EMPID ?? this.EMPID,
      HABDESCONTO: HABDESCONTO ?? this.HABDESCONTO,
      HABCONDPAGAMENTO: HABCONDPAGAMENTO ?? this.HABCONDPAGAMENTO,
      CLIENTESDOVENDEDOR: CLIENTESDOVENDEDOR ?? this.CLIENTESDOVENDEDOR,
      PRODUTOSZERADOS: PRODUTOSZERADOS ?? this.PRODUTOSZERADOS,
      PRECODECUSTO: PRECODECUSTO ?? this.PRECODECUSTO,
      ULTIMOVALORVENDA: ULTIMOVALORVENDA ?? this.ULTIMOVALORVENDA,
      TIPODESCONTO: TIPODESCONTO ?? this.TIPODESCONTO,
      ALTVALORPRODUTOVENDA: ALTVALORPRODUTOVENDA ?? this.ALTVALORPRODUTOVENDA,
      TELAFORMAPAGAMENTO: TELAFORMAPAGAMENTO ?? this.TELAFORMAPAGAMENTO,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'VENID': VENID,
      'USUID': USUID,
      'EMPID': EMPID,
      'HABDESCONTO': HABDESCONTO,
      'HABCONDPAGAMENTO': HABCONDPAGAMENTO,
      'CLIENTESDOVENDEDOR': CLIENTESDOVENDEDOR,
      'PRODUTOSZERADOS': PRODUTOSZERADOS,
      'PRECODECUSTO': PRECODECUSTO,
      'ULTIMOVALORVENDA': ULTIMOVALORVENDA,
      'TIPODESCONTO': TIPODESCONTO,
      'ALTVALORPRODUTOVENDA': ALTVALORPRODUTOVENDA,
      'TELAFORMAPAGAMENTO': TELAFORMAPAGAMENTO,
    };
  }

  factory ConfigProvider.fromMap(Map<String, dynamic> map) {
    return ConfigProvider(
      VENID: int.parse(map['VENID']) ?? 0,
      USUID: int.parse(map['USUID']) ?? 0,
      EMPID: int.parse(map['EMPID']) ?? 0,
      HABDESCONTO: int.parse(map['HABDESCONTO']) ?? 0,
      HABCONDPAGAMENTO: int.parse(map['HABCONDPAGAMENTO']) ?? 0,
      CLIENTESDOVENDEDOR: int.parse(map['CLIENTESDOVENDEDOR']) ?? 0,
      PRODUTOSZERADOS: int.parse(map['PRODUTOSZERADOS']) ?? 0,
      PRECODECUSTO: int.parse(map['PRECODECUSTO']) ?? 0,
      ULTIMOVALORVENDA: int.parse(map['ULTIMOVALORVENDA']) ?? 0,
      TIPODESCONTO: int.parse(map['TIPODESCONTO']) ?? 0,
      ALTVALORPRODUTOVENDA: int.parse(map['ALTVALORPRODUTOVENDA']) ?? 0,
      TELAFORMAPAGAMENTO: int.parse(map['TELAFORMAPAGAMENTO']) ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ConfigProvider.fromJson(String source) =>
      ConfigProvider.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ConfigProvider(VENID: $VENID, USUID: $USUID, EMPID: $EMPID, HABDESCONTO: $HABDESCONTO, HABCONDPAGAMENTO: $HABCONDPAGAMENTO, CLIENTESDOVENDEDOR: $CLIENTESDOVENDEDOR, PRODUTOSZERADOS: $PRODUTOSZERADOS, PRECODECUSTO: $PRECODECUSTO, ULTIMOVALORVENDA: $ULTIMOVALORVENDA, TIPODESCONTO: $TIPODESCONTO, ALTVALORPRODUTOVENDA: $ALTVALORPRODUTOVENDA, TELAFORMAPAGAMENTO: $TELAFORMAPAGAMENTO)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConfigProvider &&
        other.VENID == VENID &&
        other.USUID == USUID &&
        other.EMPID == EMPID &&
        other.HABDESCONTO == HABDESCONTO &&
        other.HABCONDPAGAMENTO == HABCONDPAGAMENTO &&
        other.CLIENTESDOVENDEDOR == CLIENTESDOVENDEDOR &&
        other.PRODUTOSZERADOS == PRODUTOSZERADOS &&
        other.PRECODECUSTO == PRECODECUSTO &&
        other.ULTIMOVALORVENDA == ULTIMOVALORVENDA &&
        other.TIPODESCONTO == TIPODESCONTO &&
        other.ALTVALORPRODUTOVENDA == ALTVALORPRODUTOVENDA &&
        other.TELAFORMAPAGAMENTO == TELAFORMAPAGAMENTO;
  }

  @override
  int get hashCode {
    return VENID.hashCode ^
        USUID.hashCode ^
        EMPID.hashCode ^
        HABDESCONTO.hashCode ^
        HABCONDPAGAMENTO.hashCode ^
        CLIENTESDOVENDEDOR.hashCode ^
        PRODUTOSZERADOS.hashCode ^
        PRECODECUSTO.hashCode ^
        ULTIMOVALORVENDA.hashCode ^
        TIPODESCONTO.hashCode ^
        ALTVALORPRODUTOVENDA.hashCode ^
        TELAFORMAPAGAMENTO.hashCode;
  }
}
