

import 'package:flutter/material.dart';

class SequancialProvider extends ChangeNotifier {
  int cliente;
  int orcamento;

  void SequencialGet(int cliente, int orcamento) {
    this.cliente = cliente;
    this.orcamento = orcamento;
    notifyListeners();
  }
}

class Sequencial {
  String sequenCliente;
  String sequenOrc;
  Sequencial({
     this.sequenCliente,
  this.sequenOrc,
  });

  Sequencial copyWith({
    String sequenCliente,
    String sequenOrc,
  }) {
    return Sequencial(
      sequenCliente: sequenCliente ?? this.sequenCliente,
      sequenOrc: sequenOrc ?? this.sequenOrc,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sequenCliente': sequenCliente,
      'sequenOrc': sequenOrc,
    };
  }

  factory Sequencial.fromMap(Map<String, dynamic> map) {
    return Sequencial(
      sequenCliente: map['sequenCliente'] ?? '',
      sequenOrc: map['sequenOrc'] ?? '',
    );
  }

  @override
  String toString() =>
      'Sequencial(sequenCliente: $sequenCliente, sequenOrc: $sequenOrc)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Sequencial &&
        other.sequenCliente == sequenCliente &&
        other.sequenOrc == sequenOrc;
  }

  @override
  int get hashCode => sequenCliente.hashCode ^ sequenOrc.hashCode;
}
