import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/cliente.dart';
import 'package:flutteraplicativo/src/models/clienteProvider.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/conexaoProvider.dart';
import 'package:flutteraplicativo/src/models/formasModel.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) =>
      this.toLowerCase().contains(secondString.toLowerCase());
}

class SelectFormas extends StatefulWidget {
  @override
  _SelectFormasState createState() => _SelectFormasState();
}

class _SelectFormasState extends State<SelectFormas> {
  Future _future;
  String razaosocial;
  String cpf_cnpj;
  Future _selectCliente;
  String searchString = "";
  TextEditingController searchController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();
  String _mensagemErro = "";
  TextEditingController razaosocialtxt = TextEditingController(text: "dan");
  TextEditingController cpf_cnpjtxt = TextEditingController(text: "123");
  var dados;
  String forma = "";
  int idFPG = 0;
  Conexao c = Conexao();
  List formas = [];
  @override
  void initState() {
    recuperarConexao();

    Timer(Duration(seconds: 1), () {
      _future = getData();
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void recuperarConexao() async {
    c = await DBProvider.db.getConexao(1);
  }

  void MensagemDadosIncorretos() {
    var alert = new AlertDialog(
      title: new Text("Dados Incorretos"),
      content: new Text("Usuário ou Senha incorretos"),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text("Selecionar Forma De Pagamento"),
        actions: <Widget>[],
      ),
      body: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(10.0)),
          TextField(
            onChanged: (value) {
              setState(() {
                searchString = value;
              });
            },
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Buscar Formas",
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Padding(padding: EdgeInsets.all(10.0)),
          Expanded(
            child: Container(
              child: FutureBuilder(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) print(snapshot.error);

                    return snapshot.hasData
                        ? ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              return formas[index]["FPGNOME"]
                                      .toString()
                                      .containsIgnoreCase(searchString)
                                  ? ListTile(
                                      title: Text(
                                        formas[index]["FPGNOME"],
                                        style: TextStyle(
                                            color: Colors.indigo[900],
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: GestureDetector(
                                        child: Icon(
                                          Icons.add_box,
                                          color: Colors.blue[900],
                                          size: 35,
                                        ),
                                        onTap: () async {
                                          buscarFormas(int.parse(
                                              formas[index]["FPGID"]));
                                        },
                                      ),
                                    )
                                  : Container(
                                      width: 10.0,
                                      height: 10.0,
                                    );
                            })
                        : Center(
                            child: Text(""),
                          );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> buscarFormas(int forma) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    };

    var response = await http.get(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/selectFormas.php?forma=${forma}&usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}"),
        headers: headers);

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (msg == "Dados incorretos!") {
      MensagemDadosIncorretos();
    } else {
      dados = obj['result'];

      this.forma = dados[0]['FPGNOME'];
      this.idFPG = int.parse(dados[0]['FPGID']);

      Provider.of<FormasProvider>(context, listen: false).reset();
      Provider.of<FormasProvider>(context, listen: false).formaGet(this.forma);
      Provider.of<FormasProvider>(context, listen: false).idForma(this.idFPG);
      Navigator.of(context).pop();
    }
  }

  Future getData() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Charset': 'utf-8'
    };

    try {
      var response = await http.get(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/formasPagamento.php?usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}"),
          headers: headers);

      var obj = convert.json.decode(response.body);

      formas = obj['result'];
      return obj['result'];
    } catch (e) {
      print("error");
    }
  }
}
