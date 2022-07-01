import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/cliente.dart';

class ClienteProvider extends ChangeNotifier {
  Cliente cli;
  String cnpj;
  int id;
  int idCliente;

  String razao, fone, fone2, email, logradoudo, bairro, numero, cidade, cep, uf;

  void clienteGet(Cliente cliente) {
    this.cli = cliente;
    notifyListeners();
  }

  void setCNPJ(String cnpj) {
    this.cnpj = cnpj;
    notifyListeners();
  }

  void setIdCliente(int id) {
    this.idCliente = id;
    notifyListeners();
  }

  void setRazao(String valor) {
    this.razao = valor;
    notifyListeners();
  }

  void setFone(String valor) {
    this.fone = valor;
    notifyListeners();
  }

  void setFone2(String valor) {
    this.fone2 = valor;
    notifyListeners();
  }

  void setEmail(String valor) {
    this.email = valor;
    notifyListeners();
  }

  void setLogradouro(String valor) {
    this.logradoudo = valor;
    notifyListeners();
  }

  void setBairro(String valor) {
    this.bairro = valor;
    notifyListeners();
  }

  void setNumero(String valor) {
    this.numero = valor;
    notifyListeners();
  }

  void setCidade(String valor) {
    this.cidade = valor;
    notifyListeners();
  }

  void setCep(String valor) {
    this.cep = valor;
    notifyListeners();
  }

  void setUF(String valor) {
    this.uf = valor;
    notifyListeners();
  }

  void setID(int id) {
    this.id = id;
    notifyListeners();
  }

  void clienteReset() {
    this.cli = null;
    notifyListeners();
  }
}
