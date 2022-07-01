import 'dart:async';
import 'dart:convert' as convert;

import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/checkBoxModel.dart';

import 'package:flutteraplicativo/src/models/clienteProvider.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/conexaoProvider.dart';
import 'package:flutteraplicativo/src/models/configuracoesModel.dart';
import 'package:flutteraplicativo/src/models/sequencialProvider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

enum SingingCharacter { DescontoPorItem, DescontoValortotal }

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

SingingCharacter _character = SingingCharacter.DescontoPorItem;

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController slqtxt = TextEditingController();
  TextEditingController controllerPedido = TextEditingController(text: "");
  TextEditingController controllerCliente = TextEditingController(text: "");
  TextEditingController clienteCNPJ = TextEditingController(text: "");
  TextEditingController controllerHost = TextEditingController(text: "");
  TextEditingController controllerBdname = TextEditingController(text: "");
  TextEditingController controllerUsuario = TextEditingController(text: "");
  TextEditingController controllerSenha = TextEditingController(text: "");
  bool isChecked = false;
  CheckBoxModel checkBoxItem = CheckBoxModel(texto: "Desconto Por Item");
  CheckBoxModel checkBoxTotal = CheckBoxModel(texto: "Desconto Valor total");

  List<CheckBoxModel> itens = [
    CheckBoxModel(texto: "Alterar valor Produto na venda"),
    CheckBoxModel(
      texto: "Mostra Tela de Formas de Pagamento Pedido",
    ),
    CheckBoxModel(texto: "Desabilita Obs do Pedido"),
    CheckBoxModel(texto: "Mostra preço custo"),
  ];

  List<String> itensConfi = ["Desconto Por Item", "Desconto Valor total"];

  GroupController multipleCheckController = GroupController(
    isMultipleSelection: true,
    initSelectedItem: List.generate(10, (index) => index),
  );
  Sequencial sequencial = Sequencial();
  String desconto = "Habilita Desconto";
  String valorProdVenda = "Alterar valor Produto na venda";
  String formasPagamentoPedido = "Mostra Tela de Formas de Pagamento Pedido";
  String obsPedido = "Desabilita Obs do Pedido";
  String precoCusto = "Mostra preço custo";
  String _mensagemErro = "";

  List resultConsulta = [];
  int pedido;
  int cliente;

  Conexao c = Conexao();
  ConfigModel conf = ConfigModel();
  var dados;
  List list = [];

  var msg;

  @override
  void dispose() {
    super.dispose();
  }

  void recuperarConexao() async {
    List list = await DBProvider.db.getAllConexaos();

    if (list.isNotEmpty) {
      c = await DBProvider.db.getConexao(1);

      if (c != null) {
        controllerHost = TextEditingController(text: c.host);
        controllerBdname = TextEditingController(text: c.bdname);
        controllerUsuario = TextEditingController(text: c.user);
        controllerSenha = TextEditingController(text: c.pass);
      }
    }
  }

  @override
  void initState() {
    recuperarConexao();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text('Configurações'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DefaultTabController(
                    length: 1, // length of tabs
                    initialIndex: 0,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            color: Colors.indigo[400],
                            child: TabBar(
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.black,
                              tabs: [
                                Tab(
                                  child: Center(
                                    child: Text(
                                      "CONEXÃO",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            child: Container(
                                height: 500, //height of TabBarView
                                decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            color: Colors.black, width: 0.5))),
                                child: TabBarView(children: <Widget>[
                                  _conexao(),
                                  //_consultSql(),
                                ])),
                          )
                        ])),
              ]),
        ),
      ), // Create body view
    );
  }

  // Http post request to create new data
  Future<String> _conectarBanco(Conexao conexao) async {
    final result = await http.post(
      'http://crtsistemas.com.br/crt_mobile_flutter/apis/conexao.php?usuario=${conexao.user}&senha=${conexao.pass}&bdname=${conexao.bdname}&host=${conexao.host}',
      body: conexao.toJson(),
    );

    if (result.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var obj = convert.json.decode(result.body);

      Provider.of<ConexaoProvider>(context, listen: false).conexaoGet(conexao);

      msg = obj["message"];

      return result.body;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
  }

  void MensagemDadosIncorretos() {
    var alert = new AlertDialog(
      contentPadding: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
      backgroundColor: Colors.red,
      title: new Text(
        "Dados incorretos do banco de dados",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: new Text("Verifique os campos e tente novamente!",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  conectar(Conexao conexao) async {
    await _conectarBanco(conexao).then((sucess) => {
          if (msg != "Conectado ao banco")
            {MensagemDadosIncorretos()}
          else
            {
              print("Conectado ao banco!"),
              Navigator.pushNamedAndRemoveUntil(
                  context, "/login", (route) => false)
            },
        });
  }

  _conexao() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: controllerHost,
              decoration: InputDecoration(
                  labelText: "HOST",
                  contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 50),
                  hintStyle: TextStyle(fontSize: 20)),
            ),
            Padding(padding: EdgeInsets.all(8.0)),
            TextField(
              controller: controllerBdname,
              decoration: InputDecoration(
                  labelText: "BDNAME",
                  contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 50),
                  hintStyle: TextStyle(fontSize: 20)),
            ),
            Padding(padding: EdgeInsets.all(8.0)),
            TextField(
              controller: controllerUsuario,
              decoration: InputDecoration(
                  labelText: "USUARIO",
                  contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 50),
                  hintStyle: TextStyle(fontSize: 20)),
            ),
            TextField(
              controller: controllerSenha,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: "SENHA",
                  contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 50),
                  hintStyle: TextStyle(fontSize: 20)),
            ),
            ElevatedButton(
              child: Text(
                'CONECTAR',
                textAlign: TextAlign.center,
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue[900],
                onPrimary: Colors.white,
                shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2))),
              ),
              onPressed: () async {
                Conexao conexao = Conexao(
                    host: controllerHost.text,
                    bdname: controllerBdname.text,
                    user: controllerUsuario.text,
                    pass: controllerSenha.text);

                DBProvider.db.deleteAll();
                await DBProvider.db.newConexao(conexao);
                DBProvider.db.getAllConexaos();

                conexao = await DBProvider.db.getConexao(1);

                if (conexao != null) {
                  conectar(conexao);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
