import 'dart:convert';

import 'package:flutter/material.dart';

class Empresa extends ChangeNotifier {
  Empresa empresa;
  int EMPID;
  String EMPRAZAOSOCIAL;
  String EMPNOMEFANTASIA;
  String EMPENDERECO;
  String EMPBAIRRO;
  String EMPCIDADE;
  String EMPCEP;
  String EMPUF;
  String EMPCNPJ;
  String EMPFONE01;
  String EMPFONE02;
  String EMPEMAIL;
  String LOGOMARCA;
  Empresa({
    this.EMPID,
    this.EMPRAZAOSOCIAL,
    this.EMPNOMEFANTASIA,
    this.EMPENDERECO,
    this.EMPBAIRRO,
    this.EMPCIDADE,
    this.EMPCEP,
    this.EMPUF,
    this.EMPCNPJ,
    this.EMPFONE01,
    this.EMPFONE02,
    this.EMPEMAIL,
    this.LOGOMARCA,
  });

  Empresa copyWith({
    int EMPID,
    String EMPRAZAOSOCIAL,
    String EMPNOMEFANTASIA,
    String EMPENDERECO,
    String EMPBAIRRO,
    String EMPCIDADE,
    String EMPCEP,
    String EMPUF,
    String EMPCNPJ,
    String EMPFONE01,
    String EMPFONE02,
    String EMPEMAIL,
    String LOGOMARCA,
  }) {
    return Empresa(
      EMPID: EMPID ?? this.EMPID,
      EMPRAZAOSOCIAL: EMPRAZAOSOCIAL ?? this.EMPRAZAOSOCIAL,
      EMPNOMEFANTASIA: EMPNOMEFANTASIA ?? this.EMPNOMEFANTASIA,
      EMPENDERECO: EMPENDERECO ?? this.EMPENDERECO,
      EMPBAIRRO: EMPBAIRRO ?? this.EMPBAIRRO,
      EMPCIDADE: EMPCIDADE ?? this.EMPCIDADE,
      EMPCEP: EMPCEP ?? this.EMPCEP,
      EMPUF: EMPUF ?? this.EMPUF,
      EMPCNPJ: EMPCNPJ ?? this.EMPCNPJ,
      EMPFONE01: EMPFONE01 ?? this.EMPFONE01,
      EMPFONE02: EMPFONE02 ?? this.EMPFONE02,
      EMPEMAIL: EMPEMAIL ?? this.EMPEMAIL,
      LOGOMARCA: LOGOMARCA ?? this.LOGOMARCA,
    );
  }

  void empSet(Empresa emp) {
    this.empresa = emp;
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'EMPID': EMPID,
      'EMPRAZAOSOCIAL': EMPRAZAOSOCIAL,
      'EMPNOMEFANTASIA': EMPNOMEFANTASIA,
      'EMPENDERECO': EMPENDERECO,
      'EMPBAIRRO': EMPBAIRRO,
      'EMPCIDADE': EMPCIDADE,
      'EMPCEP': EMPCEP,
      'EMPUF': EMPUF,
      'EMPCNPJ': EMPCNPJ,
      'EMPFONE01': EMPFONE01,
      'EMPFONE02': EMPFONE02,
      'EMPEMAIL': EMPEMAIL,
      'LOGOMARCA': LOGOMARCA,
    };
  }

  factory Empresa.fromMap(Map<String, dynamic> map) {
    return Empresa(
      EMPID: int.parse(map['EMPID']) ?? 0,
      EMPRAZAOSOCIAL: map['EMPRAZAOSOCIAL'] ?? '',
      EMPNOMEFANTASIA: map['EMPNOMEFANTASIA'] ?? '',
      EMPENDERECO: map['EMPENDERECO'] ?? '',
      EMPBAIRRO: map['EMPBAIRRO'] ?? '',
      EMPCIDADE: map['EMPCIDADE'] ?? '',
      EMPCEP: map['EMPCEP'] ?? '',
      EMPUF: map['EMPUF'] ?? '',
      EMPCNPJ: map['EMPCNPJ'] ?? '',
      EMPFONE01: map['EMPFONE01'] ?? '',
      EMPFONE02: map['EMPFONE02'] ?? '',
      EMPEMAIL: map['EMPEMAIL'] ?? '',
      LOGOMARCA: map['LOGOMARCA'] ?? '',
    );
  }
  factory Empresa.fromMapDB(Map<String, dynamic> map) {
    return Empresa(
        EMPID: map['id'].toInt() ?? 0, EMPCNPJ: map['cnpjEMP'] ?? '');
  }

  String toJson() => json.encode(toMap());

  factory Empresa.fromJson(String source) =>
      Empresa.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Empresa(EMPID: $EMPID, EMPRAZAOSOCIAL: $EMPRAZAOSOCIAL, EMPNOMEFANTASIA: $EMPNOMEFANTASIA, EMPENDERECO: $EMPENDERECO, EMPBAIRRO: $EMPBAIRRO, EMPCIDADE: $EMPCIDADE, EMPCEP: $EMPCEP, EMPUF: $EMPUF, EMPCNPJ: $EMPCNPJ, EMPFONE01: $EMPFONE01, EMPFONE02: $EMPFONE02, EMPEMAIL: $EMPEMAIL, LOGOMARCA: $LOGOMARCA)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Empresa &&
        other.EMPID == EMPID &&
        other.EMPRAZAOSOCIAL == EMPRAZAOSOCIAL &&
        other.EMPNOMEFANTASIA == EMPNOMEFANTASIA &&
        other.EMPENDERECO == EMPENDERECO &&
        other.EMPBAIRRO == EMPBAIRRO &&
        other.EMPCIDADE == EMPCIDADE &&
        other.EMPCEP == EMPCEP &&
        other.EMPUF == EMPUF &&
        other.EMPCNPJ == EMPCNPJ &&
        other.EMPFONE01 == EMPFONE01 &&
        other.EMPFONE02 == EMPFONE02 &&
        other.EMPEMAIL == EMPEMAIL &&
        other.LOGOMARCA == LOGOMARCA;
  }

  @override
  int get hashCode {
    return EMPID.hashCode ^
        EMPRAZAOSOCIAL.hashCode ^
        EMPNOMEFANTASIA.hashCode ^
        EMPENDERECO.hashCode ^
        EMPBAIRRO.hashCode ^
        EMPCIDADE.hashCode ^
        EMPCEP.hashCode ^
        EMPUF.hashCode ^
        EMPCNPJ.hashCode ^
        EMPFONE01.hashCode ^
        EMPFONE02.hashCode ^
        EMPEMAIL.hashCode ^
        LOGOMARCA.hashCode;
  }
}
