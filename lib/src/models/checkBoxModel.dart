import 'package:flutter/material.dart';


class CheckBoxModel extends ChangeNotifier {
  CheckBoxModel({this.checked = false, this.texto});

  String texto;
  bool checked;

  String desconto;
  String valorProdVenda;
  String formasPagamentoPedido;
  String obsPedido;
  String precoCusto;
  String opcaoDesconto;

  void setOpcao(String valor) {
    this.opcaoDesconto = valor;
    notifyListeners();
  }

  void setDesconto(String valor) {
    this.desconto = valor;
    notifyListeners();
  }

  void setValor(String valor) {
    this.valorProdVenda = valor;
    notifyListeners();
  }

  void setFormas(String valor) {
    this.formasPagamentoPedido = valor;
    notifyListeners();
  }

  void setObs(String valor) {
    this.obsPedido = valor;
    notifyListeners();
  }

  void setCusto(String valor) {
    this.precoCusto = valor;
    notifyListeners();
  }
}

class CheckboxWidget extends StatefulWidget {
  const CheckboxWidget({Key key, this.item}) : super(key: key);

  final CheckBoxModel item;

  @override
  _CheckboxWidgetState createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  @override
  void initState() {


    super.initState();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
  }


  TextEditingController clienteCNPJ = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
            value: widget.item.checked,
            onChanged: (bool value) {
              setState(() {
                widget.item.checked = value;
              });
              if (widget.item.checked == true) {}
            },
            title: Text(widget.item.texto),
            selected: widget.item.checked,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4)),
      ],
    );
  }
}
