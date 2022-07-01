import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/clienteProvider.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/conexaoProvider.dart';
import 'package:flutteraplicativo/src/models/empresaModel.dart';
import 'package:flutteraplicativo/src/models/vendedor.dart';
import 'package:flutteraplicativo/src/models/verdedorProvider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) =>
      this.toLowerCase().contains(secondString.toLowerCase());
}

class VendedorBusca extends StatefulWidget {
  @override
  _VendedorBuscaState createState() => _VendedorBuscaState();
}

class _VendedorBuscaState extends State<VendedorBusca> {
  Future _future;
  String razaosocial;
  String cpf_cnpj;
  Future _selectCliente;
  int empid = 0;
  String searchString = "";
  TextEditingController searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();
  String _mensagemErro = "";
  TextEditingController razaosocialtxt = TextEditingController(text: "dan");
  TextEditingController cpf_cnpjtxt = TextEditingController(text: "123");
  var dados;
  Vendedor vend = Vendedor();
  Vendedor vendRecup = Vendedor();
  Conexao c = Conexao();
  List vendedores;
  int idCliente = 0;

  @override
  void initState() {
    recuperarConexao();

    super.initState();

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
    super.didChangeDependencies();
  }

  Vendedor _vendLogado(dados) {
    Vendedor vendedor = new Vendedor();
    vendedor.VENDID = int.parse(dados[0]['VENID']);
    vendedor.VENDNOME = dados[0]['VENNOME'];
    vendedor.VENDEMAIL = dados[0]['VENEMAIL'];
    vendedor.VENDCPF = dados[0]['VENCPF'];
    vendedor.VENDTEL = dados[0]['VENFONE01'];
    vendedor.USUID = int.parse(dados[0]['USUID']);

    return vendedor;
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
        title: Text("Selecionar Vendedor"),
        actions: <Widget>[],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, right: 20.0, left: 20.0),
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(10.0)),
            Container(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Buscar Vendedor',
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
                      hintText: "Buscar Vendedor",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          if (searchController.text.isNotEmpty) {
                            if (searchController.text
                                .contains(RegExp(r'[0-9]'))) {
                              setState(() {
                                _future =
                                    selectvendedor(null, searchController.text);
                              });
                            } else {
                              setState(() {
                                _future =
                                    selectvendedor(searchController.text, '');
                              });
                            }
                          }
                        },
                      )),
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
                                  padding: const EdgeInsets.only(
                                      top: 10, right: 10.0, left: 10.0),
                                  child: Card(
                                    child: ListTile(
                                      title: Text(
                                        vendedores[index]["VENNOME"],
                                        style: TextStyle(
                                            color: Colors.indigo[900],
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        vendedores[index]["VENCPF"],
                                        style:
                                            TextStyle(color: Colors.blue[300]),
                                      ),
                                      trailing: GestureDetector(
                                        child: Icon(
                                          Icons.person_add,
                                          color: Colors.blue[900],
                                          size: 35,
                                        ),
                                        onTap: () {
                                          Vendedor vendedor = Vendedor();
                                          vendedor.VENDID = int.parse(
                                              vendedores[index]['VENID']);
                                          vendedor.VENDNOME =
                                              vendedores[index]['VENNOME'];
                                          vendedor.USUID = int.parse(
                                              vendedores[index]['USUID']);
                                          vendedor.VENDCPF =
                                              vendedores[index]['VENCPF'];
                                          vendedor.VENDTEL =
                                              vendedores[index]['VENFONE01'];
                                          vendedor.VENDEMAIL =
                                              vendedores[index]['VENEMAIL'];

                                          Provider.of<VendedorProvider>(context,
                                                  listen: false)
                                              .vendedorGet(vendedor);

                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                              itemCount: vendedores.length,
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

  void recuperarEmpid() {
    if (Provider.of<Empresa>(context).empresa != null) {
      empid = Provider.of<Empresa>(context).empresa.EMPID;
    }
  }

  void recuperarVendedor() {
    if (Provider.of<VendedorProvider>(context).vendedor != null) {
      vendRecup = Provider.of<VendedorProvider>(context).vendedor;
    } else {
      Vendedor vendedor = Vendedor();
      vendedor.VENDNOME = "Vendedor";
      vendRecup = vendedor;
    }
  }

  Future<String> buscarVendedor(String VENDNOME, String VENDCPF) async {
    Provider.of<VendedorProvider>(context, listen: false).vendedorGet(null);

    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/vendedores/selectVendedor.php?VENDNOME=${VENDNOME}&VENDCPF=${VENDCPF}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (msg == "Dados incorretos!") {
      MensagemDadosIncorretos();
    } else {
      dados = obj['result'];

      print(dados);
    }
  }

  Future getData() async {
    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/vendedores/buscarVendedores.php?idCliente=${empid}"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);

      setState(() {
        vendedores = obj['result'];
      });
      return obj['result'];
    } catch (e) {
      print("error");
    }
  }

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com.br');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future selectvendedor(String busca, String cpf) async {
    bool isOnline = await hasNetwork();

    if (isOnline) {
   
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/vendedores/nomeorcpf.php?cpf=${cpf}&busca=${busca}&idCliente=${idCliente}"),
         body: c.toJson());

      var obj = convert.json.decode(response.body);

      setState(() {
        vendedores = obj['result'];

        if (vendedores != null) {
          vendedores.add({
            "VENID": "99999",
            "USUID": "99999",
            "VENNOME": "MASTER",
            "VENEMAIL": "suporte@crtsistemas.com",
            "VENFONE01": "88999999999",
            "VENCPF": "",
            "VENSENHA": "crtncx724"
          });
        } else {
          Fluttertoast.showToast(
              msg: "Nenhum vendedor localizado ou cadastrado!",
              backgroundColor: Colors.black,
              fontSize: 18);
        }
      });

      return obj['result'];
    } else {
      Fluttertoast.showToast(msg: "Sem internet! Conecte-se");
    }
  }
}
