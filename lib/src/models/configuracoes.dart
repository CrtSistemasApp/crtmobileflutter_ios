// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/cupertino.dart';

class ConfiguracoesModel extends ChangeNotifier {
  String CFGNOME;
  int EMPID;
  int CFGVALOR;
  ConfiguracoesModel({
    this.CFGNOME,
    this.EMPID,
    this.CFGVALOR,
  });

  ConfiguracoesModel config;

  void setConfig(ConfiguracoesModel con) {
    this.config = con;
    notifyListeners();
  }

  ConfiguracoesModel copyWith({
    String CFGNOME,
    int EMPID,
    int CFPVALOR,
  }) {
    return ConfiguracoesModel(
      CFGNOME: CFGNOME ?? this.CFGNOME,
      EMPID: EMPID ?? this.EMPID,
      CFGVALOR: CFPVALOR ?? this.CFGVALOR,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'CFGNOME': CFGNOME,
      'EMPID': EMPID,
      'CFPVALOR': CFGVALOR,
    };
  }

  factory ConfiguracoesModel.fromMap(Map<String, dynamic> map) {
    return ConfiguracoesModel(
      CFGNOME: map['CFGNOME'],
      EMPID: int.parse(map['EMPID']),
      CFGVALOR: int.parse(map['CFGVALOR']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ConfiguracoesModel.fromJson(String source) =>
      ConfiguracoesModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ConfiguracoesModel(CFGNOME: $CFGNOME, EMPID: $EMPID, CFGVALOR: $CFGVALOR)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConfiguracoesModel &&
        other.CFGNOME == CFGNOME &&
        other.EMPID == EMPID &&
        other.CFGVALOR == CFGVALOR;
  }

  @override
  int get hashCode => CFGNOME.hashCode ^ EMPID.hashCode ^ CFGVALOR.hashCode;
}
