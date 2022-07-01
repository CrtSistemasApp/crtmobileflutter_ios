import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/vendedor.dart';

class VendedorProvider extends ChangeNotifier {
  Vendedor vendedor;

  void vendedorGet(Vendedor vendedor) {
    this.vendedor = vendedor;
    notifyListeners();
  }
}
