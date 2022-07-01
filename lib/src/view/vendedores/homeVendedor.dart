import 'dart:async';
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/clienteProvider.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/conexaoProvider.dart';
import 'package:flutteraplicativo/src/models/empresaModel.dart';
import 'package:flutteraplicativo/src/models/vendedor.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) =>
      this.toLowerCase().contains(secondString.toLowerCase());
}

class Vendedores extends StatefulWidget {
  @override
  _VendedoresState createState() => _VendedoresState();
}

class _VendedoresState extends State<Vendedores> {
  Future _future;
  int empid = 0;
  String razaosocial;
  List vendedores = [];
  String cpf_cnpj;
  Future _selectCliente;
  String searchString = "";
  TextEditingController searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();
  String _mensagemErro = "";
  TextEditingController razaosocialtxt = TextEditingController(text: "dan");
  TextEditingController cpf_cnpjtxt = TextEditingController(text: "123");
  var dados;
  Vendedor vend = Vendedor();
  Conexao c = Conexao();
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

  void recuperarEmpid() {
    if (Provider.of<Empresa>(context).empresa != null) {
      empid = Provider.of<Empresa>(context).empresa.EMPID;
    }
  }

  Vendedor _vendLogado(dados) {
    Vendedor vendedor = new Vendedor();
    vendedor.VENDNOME = dados[0]['VENNOME'];
    vendedor.VENDEMAIL = dados[0]['VENEMAIL'];
    vendedor.VENDCPF = dados[0]['VENCPF'];
    vendedor.VENDTEL = dados[0]['VENFONE01'];

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

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(vend.VENDNOME),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Vendedor: ' + vend.VENDNOME,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Telefone: ' + vend.VENDTEL,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                vend.VENDEMAIL == null
                    ? Text(
                        "Email: ",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      )
                    : Text(
                        'Email:  ${vend.VENDEMAIL}',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              color: Colors.blue[900],
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _listaBusca() async {
    while (searchController.text.isNotEmpty) {
      return await _future;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text("Vendedores"),
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
                  labelText: 'Buscar Vendedores',
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
                      double c_width = MediaQuery.of(context).size.width * 0.7;
                      return snapshot.hasData
                          ? ListView.builder(
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, right: 20.0, left: 20.0),
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            width: c_width,
                                            child: new Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  vendedores[index]["VENNOME"],
                                                  style: TextStyle(
                                                      color: Colors.indigo[900],
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  vendedores[index]["VENCPF"],
                                                  style: TextStyle(
                                                      color: Colors.blue[300]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        child: Container(
                                          height: 30,
                                          width: 28,
                                          decoration: BoxDecoration(
                                            color: Colors.blue[900],
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Center(
                                              child: Icon(
                                            Icons.search,
                                            color: Colors.white,
                                            size: 20,
                                          )),
                                        ),
                                        onTap: () async {
                                          buscarVendedor(
                                              vendedores[index]["VENNOME"],
                                              vendedores[index]["VENCPF"]);
                                        },
                                      ),
                                      SizedBox(
                                        height: 60,
                                      ),
                                    ],
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

  Future<String> buscarVendedor(String VENDNOME, String VENDCPF) async {
    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/vendedores/selectVendedor.php?VENDNOME=${VENDNOME}&VENDCPF=${VENDCPF}&usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);

      var msg = obj["message"];

      if (msg == "Dados incorretos!") {
        MensagemDadosIncorretos();
      } else {
        dados = obj['result'];
        this.vend = _vendLogado(dados);
        _showMyDialog();
      }
    } catch (e) {
      print("error");
    }
  }

  Future getData() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Charset': 'utf-8'
    };

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

  Future selectvendedor(String busca, String cpf) async {
 
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/vendedores/nomeorcpf.php?cpf=${cpf}&busca=${busca}&idCliente=${empid}"),
      body: c.toJson());

    var obj = convert.json.decode(response.body);

    setState(() {
      vendedores = obj['result'];
    });

    return obj['result'];
  }
}
