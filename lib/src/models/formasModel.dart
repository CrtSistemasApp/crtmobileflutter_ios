import 'package:flutter/material.dart';

class FormasProvider extends ChangeNotifier {
  String forma;
  int id;

  void formaGet(String forma) {
    this.forma = forma;
    notifyListeners();
  }

  void reset() {
    this.forma = null;
    notifyListeners();
  }

  void idForma(int id) {
    this.id = id;
    notifyListeners();
  }
}
