import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/produtos.dart';

class ProdutoProvider extends ChangeNotifier {
  final List<Produto> _items = [];
  List<Produto> _produtos = [];
  bool result;
  double provalor = 0.0;
  List<Produto> _editList = [];

  Produto produto;

  double _totalPrice;
  double _totalPrice2;
  double _totalDesconto;

  UnmodifiableListView<Produto> get items => UnmodifiableListView(_items);
  UnmodifiableListView<Produto> get editItens =>
      UnmodifiableListView(_editList);

  UnmodifiableListView<Produto> get itemsProd =>
      UnmodifiableListView(_produtos);

  void addItem(Produto item) {
    _items.add(item);
    notifyListeners();
  }

  void setValorProd(double valor) {
    this.provalor = valor;
    notifyListeners();
  }

  double getValor() {
    return this.provalor;
  }

  void addItemIndex(int index, Produto item) {
    _items.removeAt(index);
    _items.insert(index, item);
    notifyListeners();
  }

  void setEditList(List<Produto> list) {
    this._editList = list;
    notifyListeners();
  }

  double total(double quantity, double valor) {
    return quantity * valor;
  }

  void addProd(Produto produto) {
    this.produto = Produto();

    this.produto = produto;
    notifyListeners();
  }

  void addItemProd(int id, Produto item) {
    _items.add(item);
    notifyListeners();
  }

  void addItemEditList(int id, Produto item) {
    _editList.add(item);
    notifyListeners();
  }

  void clearItemEdit(Produto prod) {
    _editList.remove(prod);
    notifyListeners();
  }

  void clearItem(Produto prod) {
    _items.remove(prod);
    notifyListeners();
  }

  bool buscarProd(int prodid, Produto prod) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].PROID == prodid) {
        if (items[i].corid != produto.corid) {
          return true;
        } else {
          return false;
        }
      }
    }
    notifyListeners();

    return false;
  }

  bool buscarProduto(Produto prod) {
    bool result;

    for (var item in _items) {
      if (item.corid == prod.corid && item.tamid == prod.tamid) {
        result = true;
        break;
      } else {
        result = false;
      }
    }

    return result;
  }

  bool produtoSemEstoque(Produto prod) {
    bool result;

    for (var item in _items) {
      if (item.PROID == prod.PROID) {
        result = true;
        break;
      } else {
        result = false;
      }
    }

    return result;
  }

  Produto buscarIndex(int index) {
    for (int i = 0; i < _items.length; i++) {
      return _items[index];
    }
  }

  double somarQtd(Produto prod) {
    double qtd = 0;

    for (int i = 0; i < items.length; i++) {
      if (items[i] == prod) {
        qtd += items[i].quantity;
      }
    }
    return qtd;
  }

  double somarQtdProd(Produto prod) {
    double qtd = 0;

    for (int i = 0; i < items.length; i++) {
      if (items[i] == prod) {
        qtd += items[i].quantity;
      }
    }
    return qtd + prod.quantity;
  }

  void clearList() {
    _items.clear();
    _produtos.clear();
    notifyListeners();
  }

  void clearListItems() {
    _items.clear();
    _produtos.clear();
    notifyListeners();
  }

  void limparProduto() {
    produto = null;
    notifyListeners();
  }

  void setResult(bool res) {
    result = res;
    notifyListeners();
  }

  double quantity(int id) {
    return _items[id].quantity;
  }

  double get totalPrice {
    double total = 0;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].PROVALORDESCONTO != null) {
        total += (_items[i].quantity * _items[i].PROVALOR) -
            _items[i].PROVALORDESCONTO;
      } else {
        total += _items[i].quantity * _items[i].PROVALOR;
      }
    }

    _totalPrice = total;

    return _totalPrice;
  }

  double get totalSemdesconto {
    double total = 0;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].PROVALORDESCONTO != null) {
        total += (_items[i].quantity * _items[i].PROVALOR);
      } else {
        total += _items[i].quantity * _items[i].PROVALOR;
      }
    }

    _totalPrice = total;

    return _totalPrice;
  }

  double get totalPrice2 {
    double total = 0;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].PROVALORDESCONTO != null) {
        total += (_items[i].quantity * _items[i].PROVALOR) -
            _items[i].PROVALORDESCONTO;
      } else {
        total += _items[i].quantity * _items[i].PROVALOR;
      }
    }

    _totalPrice2 = total;

    return _totalPrice2;
  }

  double get totalDesconto {
    double total = 0;
    for (int i = 0; i < _produtos.length; i++) {
      total += _produtos[i].PROVALORDESCONTO;
    }

    _totalPrice = total;

    return _totalDesconto;
  }

  double get totalDesconto2 {
    double total = 0;
    for (int i = 0; i < _items.length; i++) {
      total += _items[i].PROVALORDESCONTO;
    }
    _totalDesconto = total;
    return _totalDesconto;
  }

  double valorDesconto() {
    double total = 0;

    for (int i = 0; i < _produtos.length; i++) {
      total += _produtos[i].PROVALORDESCONTO;
    }

    return _totalDesconto = total;
  }
}

class Item {
  final int id;
  final String produto;
  final double preco;
  int quantity;

  Item(this.id, this.produto, this.preco, this.quantity);
}
