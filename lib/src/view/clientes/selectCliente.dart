import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/cliente.dart';
import 'package:flutteraplicativo/src/models/clienteProvider.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/configProvider.dart';
import 'package:flutteraplicativo/src/models/empresaModel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) =>
      this.toLowerCase().contains(secondString.toLowerCase());
}

class ClientesBusca extends StatefulWidget {
  @override
  _ClientesBuscaState createState() => _ClientesBuscaState();
}

class _ClientesBuscaState extends State<ClientesBusca>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> itensMenu = ["Ajuda", "Sair"];
  Future _future;
  String razaosocial;
  String cpf_cnpj;
  List clientes;
  ConfigProvider config = ConfigProvider();
  Future _selectCliente;
  String searchString = "";
  TextEditingController searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();
  String _mensagemErro = "";
  TextEditingController razaosocialtxt = TextEditingController(text: "dan");
  TextEditingController cpf_cnpjtxt = TextEditingController(text: "123");
  var dados;
  Cliente cli = Cliente();
  Conexao c = Conexao();
  int empid = 0;
  bool buttonActive = false;

  @override
  void initState() {
    recuperarConexao();
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    //this.buscarCliente();
  }

  void recuperarConexao() async {
    List list = await DBProvider.db.getAllConexaos();

    if (list.isNotEmpty) {
      c = await DBProvider.db.getConexao(1);
    }
  }

  @override
  void didChangeDependencies() {
    recuperarEmpid();
    recuperarConfig();
    super.didChangeDependencies();
  }

  void recuperarEmpid() {
    if (Provider.of<Empresa>(context).empresa != null) {
      empid = Provider.of<Empresa>(context).empresa.EMPID;
    }
  }

  void recuperarConfig() {
    if (Provider.of<ConfigProvider>(context).config != null) {
      config = Provider.of<ConfigProvider>(context).config;
    }
  }

  Cliente _dadosCliente(dados) {
    Cliente cliente = Cliente(
        id: int.parse(dados[0]['CLIID']),
        razao: dados[0]["CLINOMERAZAO"],
        nomeFantasia: dados[0]["CLINOME"],
        cpf_cnpj: dados[0]["CLICPF"],
        rg_ie: dados[0]["CLIRG"],
        tel1: dados[0]["CLIFONE01"],
        tel2: dados[0]["CLIFONE02"],
        tipoPessoa: dados[0]["CLITIPOPESSOA"],
        cep: dados[0]["CLICEP"],
        cidade: dados[0]["CLICIDADE"],
        logradouro: dados[0]["CLIENDERECO"],
        uf: dados[0]["CLIUF"],
        bairro: dados[0]["CLIBAIRRO"],
        email: dados[0]["CLIEMAIL"],
        site: dados[0]["CLICONTATO"],
        obs: dados[0]["CLICOMENTARIO"]);

    return cliente;
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

  _deslogarUsuario() async {
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  _escolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case "Ajuda":
        Navigator.pushNamed(context, "/");
        break;
      case "Sair":
        _deslogarUsuario();
        break;
    }
    //print("Item escolhido: " + itemEscolhido );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue[900],
          title: Text("Selecionar Clientes"),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: _escolhaMenuItem,
              itemBuilder: (context) {
                return itensMenu.map((String item) {
                  return PopupMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList();
              },
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, right: 20.0, left: 20.0),
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(10.0)),
            Container(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Buscar Clientes',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: TextField(
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      searchString = value;
                    });
                  },
                  controller: searchController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: ElevatedButton(
                      style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blue[900]),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ))),
                      onPressed: () {
                        if (searchController.text.isNotEmpty) {
                          if (searchController.text
                              .contains(RegExp(r'[0-9]'))) {
                            setState(() {
                              _future =
                                  selectcliente(null, searchController.text);
                            });
                          } else {
                            setState(() {
                              _future =
                                  selectcliente(searchController.text, '');
                            });
                          }
                        }
                      },
                      child: Column(
                        children: [
                          Icon(Icons.search_sharp),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(10.0)),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.77,
                child: FutureBuilder(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) print(snapshot.error);

                      return snapshot.hasData
                          ? ListView.builder(
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Card(
                                    elevation: 5,
                                    color: Colors.grey[100],
                                    child: ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Código: " +
                                                "${clientes[index]['CLICODIGO'] == null ? clientes[index]['CLIID'] : clientes[index]['CLICODIGO']}",
                                            style: TextStyle(
                                                color: Colors.indigo[900],
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "Razão/Nome: " +
                                                clientes[index]["CLINOMERAZAO"],
                                            style: TextStyle(
                                                color: Colors.indigo[900],
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          clientes[index]["CLINOME"] == null ||
                                                  clientes[index]["CLINOME"] ==
                                                      ""
                                              ? Container()
                                              : Text(
                                                  "Nome Fantasia: " +
                                                      " ${clientes[index]["CLINOME"]}",
                                                  style: TextStyle(
                                                      color: Colors.indigo[900],
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                          Text(
                                            "CPF/CNPJ: " +
                                                clientes[index]["CLICPF"],
                                            style: TextStyle(
                                                color: Colors.indigo[900],
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "Rua: " +
                                                clientes[index]["CLIENDERECO"],
                                            style: TextStyle(
                                                color: Colors.indigo[900],
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "Bairro: " +
                                                clientes[index]["CLIBAIRRO"],
                                            style: TextStyle(
                                                color: Colors.indigo[900],
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.call_sharp,
                                                color: Colors.indigo[900],
                                                size: 23,
                                              ),
                                              Text(
                                                "(" +
                                                    clientes[index]
                                                        ["CLIFONE01"] +
                                                    "/" +
                                                    clientes[index]
                                                        ["CLIFONE02"] +
                                                    ")",
                                                style: TextStyle(
                                                    color: Colors.indigo[900],
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: GestureDetector(
                                        child: Icon(
                                          Icons.person_search_rounded,
                                          color: Colors.blue[900],
                                          size: 35,
                                        ),
                                        onTap: () {
                                          if (buttonActive == false) {
                                            buscarCliente(
                                                clientes[index]["CLINOMERAZAO"],
                                                clientes[index]["CLICPF"]);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                              itemCount: clientes.length,
                            )
                          : Center(
                              child: Text(""),
                            );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> buscarCliente(String razaosocial, String cpf_cnpj) async {
    setState(() {
      buttonActive = true;
    });

    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/clientes/selectCliente.php?razaosocial=${razaosocial}&cpf_cnpj=${cpf_cnpj}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (msg == "Dados incorretos!") {
      MensagemDadosIncorretos();
    } else {
      dados = obj['result'];

      this.cli = _dadosCliente(dados);

      print(this.cli);

      Fluttertoast.showToast(
          msg: "Cliente selecionado!",
          backgroundColor: Colors.blue[900],
          textColor: Colors.white,
          fontSize: 16.0);

      Provider.of<ClienteProvider>(context, listen: false).clienteGet(this.cli);
      Navigator.of(context).pop();
    }
  }

  Future getData() async {
    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/clientes/buscarClientes.php?idCliente=${empid}"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);

      setState(() {
        clientes = obj['result'];
      });

      return obj['result'];
    } catch (e) {
      print("error");
    }
  }

  Future selectcliente(String busca, String cnpj) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Charset': 'utf-8'
    };

    if (config.CLIENTESDOVENDEDOR == 1) {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/clientes/buscaClientesVend.php?cnpj=${cnpj}&busca=${busca}&idCliente=${empid}&venid=${config.VENID}"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);

      setState(() {
        clientes = obj['result'];
      });

      return obj['result'];
    } else {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/clientes/razaoorcnpj.php?cnpj=${cnpj}&busca=${busca}&idCliente=${empid}"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);

      setState(() {
        clientes = obj['result'];
      });

      print(obj);

      return obj['result'];
    }
  }
}
