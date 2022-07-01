import 'dart:async';

import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/cliente.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/conexaoProvider.dart';
import 'package:flutteraplicativo/src/models/configEspe.dart';
import 'package:flutteraplicativo/src/models/vendedor.dart';
import 'package:flutteraplicativo/src/models/verdedorProvider.dart';
import 'package:flutteraplicativo/src/view/clientes/EditView.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:provider/provider.dart';

class ClienteEdit extends StatefulWidget {
  Cliente cliente;
  String _estados = "* UF";
  String _municipios = "* CIDADE";
  String tipoPessoa = "Tipo Pessoa";
  ClienteEdit({Key key, @required this.cliente}) : super(key: key);

  @override
  _ClienteEditState createState() => _ClienteEditState();
}

class _ClienteEditState extends State<ClienteEdit>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> itensMenu = ["Ajuda", "Sair"];
  int munid = 0;
  String munnome = "";
  TextEditingController razaosocial = new TextEditingController();
  TextEditingController nomefantasia = new TextEditingController();
  TextEditingController cpf_cnpj = new TextEditingController();
  TextEditingController rg_ie = new TextEditingController();
  TextEditingController tel1 = new TextEditingController();
  TextEditingController tel2 = new TextEditingController();
  TextEditingController logradouro = new TextEditingController();
  TextEditingController bairro = new TextEditingController();
  TextEditingController cidade = new TextEditingController();
  TextEditingController cep = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController site = new TextEditingController();
  TextEditingController obs = new TextEditingController();
  TextEditingController uf = new TextEditingController();
  TextEditingController tipoPessoa = new TextEditingController();
  Conexao c = Conexao();
  List municipios = [];
  Vendedor vendedor = Vendedor();
  int usuid = 0;
  int alterar = 0;
  var dados;
  Especifica especifica = Especifica();
  String ufrec = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: especifica.UPEALTERARCLIENTE == 1
          ? Padding(
              padding: const EdgeInsets.only(bottom: 50, right: 10),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(25.0)),
                child: IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Editview(
                            cliente: widget.cliente,
                          ),
                        ));
                  },
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 50, right: 10),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(25.0)),
                child: IconButton(
                    icon: Icon(Icons.edit_off),
                    onPressed: () {
                      showAlertDialog1(context);
                    }),
              ),
            ),
      appBar: AppBar(
          backgroundColor: Colors.blue[900],
          title: Text(widget.cliente.razao),
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
      body: _body(),
    );
  }

  _deslogarUsuario() async {
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  _escolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case "Ajuda":
        break;
      case "Sair":
        _deslogarUsuario();
        break;
    }
    //print("Item escolhido: " + itemEscolhido );
  }

  @override
  void didChangeDependencies() {
    recuperarVendedor();
    recuperarPermissoes();
    super.didChangeDependencies();
  }

  void recuperarConexao() async {
    List list = await DBProvider.db.getAllConexaos();

    if (list.isNotEmpty) {
      c = await DBProvider.db.getConexao(1);
    }
  }

  Future getDataMunicipios(String uf) async {
    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/municipios.php?uf=${uf}"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);

      setState(() {
        municipios = obj['result'];
      });

      Navigator.of(context, rootNavigator: true).pop();
      _displayTextInputDialog();
      return obj['result'];
    } catch (e) {
      print("nao foi possivel recuperar os municipios");
    }
  }

  Future<void> _displayTextInputDialog() async {
    razaosocial = new TextEditingController(text: widget.cliente.razao);
    nomefantasia = new TextEditingController(text: widget.cliente.nomeFantasia);
    cpf_cnpj = new TextEditingController(text: widget.cliente.cpf_cnpj);
    rg_ie = new TextEditingController(text: widget.cliente.rg_ie);
    tel1 = new TextEditingController(text: widget.cliente.tel1);
    tel2 = new TextEditingController(text: widget.cliente.tel2);
    logradouro = new TextEditingController(text: widget.cliente.logradouro);
    bairro = new TextEditingController(text: widget.cliente.bairro);

    cep = new TextEditingController(text: widget.cliente.cep);
    email = new TextEditingController(text: widget.cliente.email);
    site = new TextEditingController(text: widget.cliente.site);
    obs = new TextEditingController(text: widget.cliente.obs);

    tipoPessoa = new TextEditingController(
        text: widget.cliente.tipoPessoa == 0
            ? "Pessoa Física"
            : "Pessoa Jurídica");
    //widget._estados = widget.cliente.uf;
    //widget._municipios = widget.cliente.cidade;
    munid = widget.cliente.munid;

    var alert = SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: 50, left: 10, right: 10),
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Alterar Cliente",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: DropdownButton(
                            hint: widget._estados == null
                                ? Text(
                                    '${widget.cliente.uf}',
                                    style: TextStyle(fontSize: 20),
                                  )
                                : Text(
                                    widget._estados,
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 20),
                                  ),
                            iconSize: 30.0,
                            style: TextStyle(color: Colors.blue),
                            items: [
                              'Pessoa Física',
                              'Pesssoa Jurídica',
                            ].map(
                              (val) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Text(val),
                                );
                              },
                            ).toList(),
                            onChanged: (val) {
                              setState(
                                () {
                                  widget._estados = val;
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 4.0, right: 4.0),
                          child: TextField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100)
                            ],
                            controller: razaosocial,
                            decoration: InputDecoration(
                                icon: new Icon(Icons.person),
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 20, 8),
                                labelStyle: TextStyle(fontSize: 18),
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: "Digite seu nome ou razao social"),
                          ),
                        ),
                        widget.cliente.nomeFantasia == ""
                            ? Text("")
                            : TextField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(60)
                                ],
                                controller: nomefantasia,
                                decoration: InputDecoration(
                                    labelStyle: TextStyle(fontSize: 18),
                                    labelText: "Digite sua nome fantasia"),
                              ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: SizedBox(
                                width: 150,
                                child: TextField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(14)
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: cpf_cnpj,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 20, 8),
                                      labelStyle: TextStyle(fontSize: 18),
                                      filled: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      labelText: "CPF/CNPJ"),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 67),
                              child: SizedBox(
                                width: 150,
                                child: TextField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(14)
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: rg_ie,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 20, 8),
                                      labelStyle: TextStyle(fontSize: 18),
                                      filled: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      labelText: "RG/IE"),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: SizedBox(
                                  width: 150,
                                  child: TextField(
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(11)
                                    ],
                                    keyboardType: TextInputType.number,
                                    controller: tel1,
                                    decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(10, 10, 20, 8),
                                        labelStyle: TextStyle(fontSize: 16),
                                        filled: true,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        labelText: "TELEFONE 1"),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 67),
                                child: SizedBox(
                                  width: 150,
                                  child: TextField(
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(11)
                                    ],
                                    keyboardType: TextInputType.number,
                                    controller: tel2,
                                    decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(10, 10, 20, 8),
                                        labelStyle: TextStyle(fontSize: 16),
                                        filled: true,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        labelText: "TELEFONE 2"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 4.0, right: 4.0),
                          child: TextField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100)
                            ],
                            controller: logradouro,
                            decoration: InputDecoration(
                                icon: new Icon(Icons.add_location_alt),
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 20, 8),
                                labelStyle: TextStyle(fontSize: 18),
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: "ENDEREÇO"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 4.0, right: 4.0),
                          child: TextField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100)
                            ],
                            controller: bairro,
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 20, 8),
                                labelStyle: TextStyle(fontSize: 18),
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: "BAIRRO"),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: DropdownButton(
                                hint: widget._estados == null
                                    ? Text(
                                        '${widget.cliente.uf}',
                                        style: TextStyle(fontSize: 20),
                                      )
                                    : Text(
                                        widget._estados,
                                        style: TextStyle(
                                            color: Colors.blue, fontSize: 20),
                                      ),
                                iconSize: 30.0,
                                style: TextStyle(color: Colors.blue),
                                items: [
                                  'AC',
                                  'AL',
                                  'AP',
                                  'AM',
                                  'BA',
                                  'CE',
                                  'DF',
                                  'ES',
                                  'GO',
                                  'MA',
                                  'MT',
                                  'MS',
                                  'MG',
                                  'PA',
                                  'PB',
                                  'PR',
                                  'PE',
                                  'PI',
                                  'RJ',
                                  'RN',
                                  'RS',
                                  'RO',
                                  'RR',
                                  'SC',
                                  'SP',
                                  'SE',
                                  'TO'
                                ].map(
                                  (val) {
                                    return DropdownMenuItem<String>(
                                      value: val,
                                      child: Text(val),
                                    );
                                  },
                                ).toList(),
                                onChanged: (val) {
                                  setState(
                                    () {
                                      widget._estados = val;

                                      getDataMunicipios(val);
                                    },
                                  );
                                },
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 10, left: 40)),
                            widget._municipios.isEmpty
                                ? Text("")
                                : Flexible(
                                    child: DropdownButton(
                                      hint: widget._municipios == null
                                          ? Text(
                                              'CIDADE',
                                              style: TextStyle(fontSize: 20),
                                            )
                                          : Text(
                                              widget.cliente.cidade !=
                                                      widget._municipios
                                                  ? widget._municipios
                                                  : widget.cliente.cidade,
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 20),
                                            ),
                                      iconSize: 30.0,
                                      style: TextStyle(color: Colors.blue),
                                      items: municipios.map((dynamic map) {
                                        return new DropdownMenuItem<dynamic>(
                                          onTap: () {
                                            setState(() {
                                              munid = int.parse(map['MUNID']);
                                              munnome = map['MUNNOME'];
                                            });
                                          },
                                          value: map['MUNNOME'],
                                          child: new Text(map['MUNNOME'],
                                              style: new TextStyle(
                                                  color: Colors.black)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(
                                          () {
                                            print("aqui");
                                            widget._municipios = val;
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                            _displayTextInputDialog();
                                          },
                                        );
                                      },
                                    ),
                                  ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 4.0, right: 4.0),
                          child: TextField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(8)
                            ],
                            keyboardType: TextInputType.number,
                            controller: cep,
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 20, 8),
                                labelStyle: TextStyle(fontSize: 18),
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: "CEP"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 4.0, right: 4.0),
                          child: TextField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100)
                            ],
                            keyboardType: TextInputType.url,
                            controller: site,
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 20, 8),
                                labelStyle: TextStyle(fontSize: 18),
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: "SITE/DESC"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 4.0, right: 4.0),
                          child: TextField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100)
                            ],
                            keyboardType: TextInputType.emailAddress,
                            controller: email,
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 20, 8),
                                labelStyle: TextStyle(fontSize: 18),
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: "EMAIL/CONTATO"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 4.0, right: 4.0),
                          child: TextField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100)
                            ],
                            controller: obs,
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 20, 8),
                                labelStyle: TextStyle(fontSize: 18),
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: "OBS CLIENTE"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue[900], // background
                                  onPrimary: Colors.white, // foreground
                                ),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.cancel),
                                    Text('CANCELAR'),
                                  ],
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(16.0)),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue[900], // background
                                  onPrimary: Colors.white, // foreground
                                ),
                                onPressed: () {
                                  if (widget.cliente.uf != widget._estados) {
                                    print("diferente");
                                  }
                                  Cliente c = Cliente(
                                    nomeFantasia: nomefantasia.text,
                                    razao: razaosocial.text,
                                    cpf_cnpj: cpf_cnpj.text,
                                    logradouro: logradouro.text,
                                    email: email.text,
                                    rg_ie: rg_ie.text,
                                    tel1: tel1.text,
                                    tel2: tel2.text,
                                    cep: cep.text,
                                    uf: widget._estados,
                                    bairro: bairro.text,
                                    cidade: widget._municipios,
                                    obs: obs.text,
                                    site: site.text,
                                  );

                                  edit(c);
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.edit),
                                    Text('ALTERAR'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  Future<String> _deleteCliente() async {
    await http.get(
        Uri.encodeFull(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/clientes/deleteCliente.php?cpf_cnpj=${widget.cliente.cpf_cnpj}&usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}"),
        headers: {"Accept": "application/json"});
  }

  // Http post request to create new data
  Future<String> _editCliente(Cliente cliente) async {
    final result = await http.post(
      Uri.parse(
          'http://crtsistemas.com.br/crt_mobile_flutter/apis/clientes/editCliente.php?munid=${munid}&usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}'),
      body: cliente.toJson(),
    );

    if (result.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      return result.body;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
  }

  edit(Cliente cliente) async {
    await _editCliente(cliente).then((sucess) => {
          Fluttertoast.showToast(
              msg: "Cliente editado com sucesso!",
              backgroundColor: Colors.blue[900],
              textColor: Colors.white,
              fontSize: 16.0),
          Navigator.of(context, rootNavigator: true).pop(),
          Navigator.pushNamedAndRemoveUntil(
              context, "/homeCliente", (route) => false)
        });
  }

  delete() async {
    _deleteCliente().then((sucess) => {
          print("deletado com sucesso!"),
          Navigator.pushNamedAndRemoveUntil(
              context, "/homeCliente", (route) => false)
        });
  }

  @override
  void initState() {
    widget._estados = widget.cliente.uf;
    widget._municipios = widget.cliente.cidade;
    recuperarConexao();
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void recuperarVendedor() {
    if (Provider.of<VendedorProvider>(context).vendedor != null) {
      vendedor = Provider.of<VendedorProvider>(context).vendedor;
      usuid = vendedor.USUID;
    }
  }

  void recuperarPermissoes() {
    if (Provider.of<Especifica>(context).especifica != null) {
      especifica = Provider.of<Especifica>(context).especifica;
    }
  }

  showAlertDialog1(BuildContext context) {
    // configura o button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    // configura o  AlertDialog
    AlertDialog alerta = AlertDialog(
      title: Text("Não permitido cadastrar cliente!"),
      content: Text(
          "Verifique as configurações específicas do usuário no sistema CRT!"),
      actions: [
        okButton,
      ],
    );
    // exibe o dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alerta;
      },
    );
  }

  _body() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: <Widget>[
            Card(
              child: Container(
                padding: EdgeInsets.all(5),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.asset(
                        "assets/editUser.png",
                        height: 130,
                        width: 350,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "INFORMAÇÕES",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              widget.cliente.nomeFantasia != ""
                                  ? RichText(
                                      text: TextSpan(
                                          style: new TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Nome Fantasia: ',
                                              style: new TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            TextSpan(
                                                text: widget
                                                    .cliente.nomeFantasia),
                                          ]),
                                    )
                                  : Text(""),
                              RichText(
                                text: TextSpan(
                                    style: new TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Nome: ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      TextSpan(text: widget.cliente.razao),
                                    ]),
                              ),
                              RichText(
                                text: TextSpan(
                                    style: new TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'CPF/CNPJ: ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      TextSpan(text: widget.cliente.cpf_cnpj),
                                    ]),
                              ),
                              RichText(
                                text: TextSpan(
                                    style: new TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'RG/IE: ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      TextSpan(text: widget.cliente.rg_ie),
                                    ]),
                              ),
                              Divider(),
                              Center(
                                child: Text(
                                  "ENDEREÇO",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                              ),
                              RichText(
                                text: TextSpan(
                                    style: new TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Rua: ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      TextSpan(text: widget.cliente.logradouro),
                                    ]),
                              ),
                              RichText(
                                text: TextSpan(
                                    style: new TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Bairro: ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      TextSpan(text: widget.cliente.bairro),
                                    ]),
                              ),
                              RichText(
                                text: TextSpan(
                                    style: new TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Cep: ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      TextSpan(text: widget.cliente.cep),
                                    ]),
                              ),
                              RichText(
                                text: TextSpan(
                                    style: new TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Cidade: ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      TextSpan(text: widget.cliente.cidade),
                                    ]),
                              ),
                              RichText(
                                text: TextSpan(
                                    style: new TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'UF: ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      TextSpan(text: widget.cliente.uf),
                                    ]),
                              ),
                              Divider(),
                              Center(
                                child: Text(
                                  "CONTATO",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(8.0)),
                              RichText(
                                text: TextSpan(
                                    style: new TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Telefone 1: ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      TextSpan(text: widget.cliente.tel1),
                                    ]),
                              ),
                              RichText(
                                text: TextSpan(
                                    style: new TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Telefone 2: ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      TextSpan(text: widget.cliente.tel2),
                                    ]),
                              ),
                              RichText(
                                text: TextSpan(
                                    style: new TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Site: ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      TextSpan(text: widget.cliente.site),
                                    ]),
                              ),
                              Divider(),
                              Center(
                                child: Text(
                                  "OBSERVAÇÕES DO CLIENTE",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(8.0)),
                              RichText(
                                text: TextSpan(
                                    style: new TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Obs: ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      TextSpan(text: widget.cliente.obs),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
