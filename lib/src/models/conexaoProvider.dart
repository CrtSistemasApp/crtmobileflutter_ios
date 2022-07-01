import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';

class ConexaoProvider extends ChangeNotifier {
  Conexao conexao;

  void conexaoGet(Conexao conexao) {
    this.conexao = conexao;
    notifyListeners();
  }
}
