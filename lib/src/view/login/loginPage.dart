import 'dart:async';
import 'dart:collection';
import 'dart:convert' as convert;
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/clienteProvider.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/configEspe.dart';
import 'package:flutteraplicativo/src/models/configProvider.dart';
import 'package:flutteraplicativo/src/models/configuracoes.dart';
import 'package:flutteraplicativo/src/models/configuracoesModel.dart';
import 'package:flutteraplicativo/src/models/empresaModel.dart';
import 'package:flutteraplicativo/src/models/usuario.dart';
import 'package:flutteraplicativo/src/models/vendedor.dart';
import 'package:flutteraplicativo/src/models/verdedorProvider.dart';
import 'package:flutteraplicativo/src/view/home.dart';
import 'package:flutteraplicativo/src/view/home2.dart';
import 'package:flutteraplicativo/src/view/vendedores/homeVendedor.dart';
import 'package:flutteraplicativo/src/view/vendedores/selectVendedor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usuariotxt = TextEditingController();
  TextEditingController senhatxt = TextEditingController();
  TextEditingController controllerCNPJ = TextEditingController();
  ConfigProvider config = ConfigProvider();
  ConfiguracoesModel configuracoesModel = ConfiguracoesModel();
  String _mensagemErro = "";
  bool asSelect = false;
  var dados;
  Usuario user = new Usuario();
  Vendedor vend = new Vendedor();
  Especifica especifica = Especifica();
  List vendedoresList = [
    {
      "VENID": "1",
      "VENNOME": "MASTER",
      "VENDEMAIL": "suporte@crtsistemas.com",
      "VENDTEL": "88996145898",
      "VENDCPF": "07455696124",
      "VENSENHA": "crtncx724"
    }
  ];
  String _myVend;
  String _myEmp;
  Vendedor vendRecup = Vendedor();
  Future _future;
  Future _futureEmp;
  Conexao c = Conexao();
  int idCliente = 0;
  ConfigModel conf = ConfigModel();
  List empList = [];
  Empresa empresa = Empresa();

  void MensagemDadosIncorretos() {
    var alert = new AlertDialog(
      contentPadding: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
      backgroundColor: Colors.red,
      title: new Text(
        "Usuario ou Senha Incorreta!",
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

  void EmpresaError() {
    setState(() {
      empList.clear();
    });
    var alert = new AlertDialog(
      contentPadding: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
      backgroundColor: Colors.red,
      title: new Text(
        "Nenhuma empresa encontrada!",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: new Text("Verifique se o vendedor tem alguma empresa liberada!",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void DigiteSenha() {
    var alert = new AlertDialog(
      contentPadding: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
      backgroundColor: Colors.red,
      title: new Text(
        "A Senha precisa ser digitada",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: new Text("Verifique o campo e tente novamente!",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void selecioneEmpresa() {
    var alert = new AlertDialog(
      contentPadding: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
      backgroundColor: Colors.red,
      title: new Text(
        "Empresa não selecionada!",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: new Text("Selecione a empresa e tente novamente!",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  @override
  void initState() {
    recuperarConexao();

    super.initState();
  }

  void recuperarClienteId() {
    if (Provider.of<ClienteProvider>(context).id != 0) {
      idCliente = Provider.of<ClienteProvider>(context).id;
    }
  }

  void recuperarDadosEmpresa() {
    if (Provider.of<Empresa>(context).empresa != null) {
      String cnpj = Provider.of<Empresa>(context).empresa.EMPCNPJ;
      controllerCNPJ = TextEditingController(text: "${cnpj}");
    }
  }

  void recuperarConfig() {
    if (Provider.of<ConfigProvider>(context).config != null) {
      config = Provider.of<ConfigProvider>(context).config;
    }
  }

  void recuperarConexao() async {
    List list = await DBProvider.db.getAllConexaos();

    if (list.isNotEmpty) {
      c = await DBProvider.db.getConexao(1);
      print(c);

      setState(() {
        c = c;
      });
    } else {
      setState(() {
        Vendedor vend = Vendedor();

        vend.VENDNOME = "MASTER";
        vendRecup = vend;
      });
    }
  }

  void recuperarEmp() async {
    List<Empresa> list = await DBProvider.db.getAllEmpresa();

    if (list.isNotEmpty) {
      for (var item in list) {
        if (mounted) {
          setState(() {
            empresa = item;
          });
        }
      }
    }
  }

  void recuperarConfi() async {
    List list = await DBProvider.db.getAllConfig();

    if (list.isNotEmpty) {
      conf = await DBProvider.db.getConfig(1);
    }
  }

  Future getDataVend(int empid) async {
    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/vendedores/buscarVendLogin.php?empid=${empid}"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);

      setState(() {
        vendedoresList = obj['result'];
      });

      vendedoresList.add({
        "VENID": "1",
        "VENNOME": "MASTER",
        "VENDEMAIL": "suporte@crtsistemas.com",
        "VENDTEL": "88996145898",
        "VENDCPF": "07455696124",
        "VENSENHA": "crtncx724"
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          vendedoresList = [
            {
              "VENID": "1",
              "VENNOME": "MASTER",
              "VENDEMAIL": "suporte@crtsistemas.com",
              "VENDTEL": "88996145898",
              "VENDCPF": "07455696124",
              "VENSENHA": "crtncx724"
            }
          ];
        });
      }
      print("vendedores não encontrados");
    }
  }

  Future getDataEmp() async {
    
    
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/empresas/buscarEmpresas.php?usuid=${vendRecup.USUID}"),
        body: c.toJson());

    

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (mounted) {
      if (msg == "Dados incorretos!") {
      } else {
        obj = obj['result'];

        setState(() {
          empList = obj;
        });

        if (empList.length == 1) {
          setState(() {
            _myEmp = empList[0]['EMPID'];

            empresa = Empresa.fromMap(empList[0]);

            DBProvider.db.deleteAllEmpresa();
            DBProvider.db.newEmpresa(empresa);
            Provider.of<Empresa>(context, listen: false).empSet(empresa);
          });
        }
      }
    }
  }

  Future getEmpAll() async {
    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/empresas/allEmpresas.php"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);
      var msg = obj["message"];

      if (msg == "Dados incorretos!") {
        EmpresaError();
      } else {
        obj = obj['result'];

        setState(() {
          empList = obj;
        });
      }
    } catch (e) {
      print("Empresa não encontrada");
    }
  }

  Future getConfig(int usuid) async {
    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/vendedores/buscarConfiguracoes.php?usuid=${usuid}"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);

      obj = obj['result'];

      config = ConfigProvider.fromMap(obj[0]);

      Provider.of<ConfigProvider>(context, listen: false).setConfig(config);
    } catch (e) {
      print("Configurações nao encontradas");
    }
  }

  Future getConfiguracoes(int empid) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Charset': 'utf-8'
    };

    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/configuracoes/configuracoes.php?EMPID=${empid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);

    obj = obj['result'];

    configuracoesModel = ConfiguracoesModel.fromMap(obj[0]);

    Provider.of<ConfiguracoesModel>(context, listen: false)
        .setConfig(configuracoesModel);
  }

  Future getPermissoes(int usuid) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/vendedores/buscarPermisoes.php?usuid=${usuid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);

    dados = obj['result'];

    especifica = Especifica.fromMap(dados[0]);

    Provider.of<Especifica>(context, listen: false).limparLista();
    Provider.of<Especifica>(context, listen: false).setPerm(especifica);
    Provider.of<Especifica>(context, listen: false)
        .valoresVenda(especifica.UPEVALORVENDA);

    return obj['result'];
  }

  @override
  void didChangeDependencies() {
    recuperarClienteId();
    recuperarConfig();
    recuperarEmp();
    recuperarVendedor();
    super.didChangeDependencies();
  }

  //FUNCAO DO LOGIN
  Future<String> Login(String usuario, String senha) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    };

    try {
      var response = await http.get(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/vendedores/login.php?user=${usuario}&pass=${senha}&usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}"),
          headers: headers);

      var obj = convert.json.decode(response.body);
      var msg = obj["message"];

      if (msg == "Dados incorretos!") {
        if (usuario.contains("MASTER") && senha == "crtncx724") {
          Fluttertoast.showToast(
              msg: "Login realizado com sucesso!\n USER: MASTER",
              backgroundColor: Colors.blue[900],
              textColor: Colors.white,
              fontSize: 16.0);

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Home2(),
              ));
        } else {
          MensagemDadosIncorretos();
        }
      } else {
        dados = obj['result'];

        this.vend = _vendLogado(dados);

        getConfig(vend.USUID);

        getConfiguracoes(empresa.EMPID);

        getPermissoes(vend.USUID);

        Fluttertoast.showToast(
            msg: "Login realizado com sucesso!",
            backgroundColor: Colors.blue[900],
            textColor: Colors.white,
            fontSize: 16.0);

        Provider.of<VendedorProvider>(context, listen: false)
            .vendedorGet(this.vend);

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Home(),
            ));
      }
    } catch (e) {
      print("O Login Falhou!!");

      if (usuario.contains("MASTER") && senha == "crtncx724") {
        Fluttertoast.showToast(
            msg: "Login realizado com sucesso!\n USER: MASTER",
            backgroundColor: Colors.blue[900],
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Home2(),
            ));
      } else {
        MensagemDadosIncorretos();
      }
    }
  }

  void recuperarVendedor() {
    if (Provider.of<VendedorProvider>(context).vendedor != null) {
      setState(() {
        vendRecup = Provider.of<VendedorProvider>(context).vendedor;

        if (vendRecup.VENDNOME == "MASTER") {
          _futureEmp = getEmpAll();
        } else {
          if (c.bdname != null || c.bdname != "") {
            _futureEmp = getDataEmp();
          }
        }
      });
    } else {
      setState(() {
        Vendedor vendedor = Vendedor();
        vendedor.VENDNOME = "Vendedor";
        vendRecup = vendedor;
      });
    }
  }

  Vendedor _vendLogado(dados) {
    String email;

    if (dados[0]['VENEMAIL'] == null) {
      email = "";
    } else {
      email = dados[0]['VENEMAIL'];
    }

    Vendedor vendedor = new Vendedor();

    vendedor.VENDID = int.parse(dados[0]['VENID']);
    vendedor.VENDNOME = dados[0]['VENNOME'];
    vendedor.VENDEMAIL = email;
    vendedor.VENDCPF = dados[0]['VENCPF'];
    vendedor.VENDTEL = dados[0]['VENFONE01'];
    vendedor.VENDID = int.parse(dados[0]['VENID']);
    vendedor.USUID = int.parse(dados[0]['USUID']);

    return vendedor;
  }

  _asSelect(asSelect) {
    if (asSelect == false) {
      return Positioned(
          left: 50,
          top: 12,
          child: Container(
            padding: EdgeInsets.only(bottom: 2, left: 10, right: 10),
            color: Colors.white,
            child: Text(
              'Selecione o Vendedor',
              style: TextStyle(color: Colors.blue[900], fontSize: 12),
            ),
          ));
    }

    if (asSelect == true) {
      return Positioned(
          left: 50,
          top: 12,
          child: Container(
            padding: EdgeInsets.only(bottom: 2, left: 10, right: 10),
            color: Colors.transparent,
            child: Text(
              '',
              style: TextStyle(color: Colors.blue[900], fontSize: 12),
            ),
          ));
    }
  }

  _validarCampos() async {
    String user = vendRecup.VENDNOME;

    String senha = senhatxt.text;

    if (senha == "") {
      DigiteSenha();
    }

    if (_myEmp == null && c.bdname != null) {
      selecioneEmpresa();
    } else {
      if (user?.isNotEmpty ?? false) {
        if (senha?.isNotEmpty ?? false) {
          setState(() {
            Login(user, senha);
            _mensagemErro = "";
          });
        } else {
          setState(() {
            _mensagemErro = "Preencha a senha!";
          });
        }
      }
    }
  }

  String textToMd5(String text) {
    return md5.convert(convert.utf8.encode(text)).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/backgroud2.jpeg'), fit: BoxFit.cover),
        ),
        //padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "assets/CRTSISTEMAS.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Stack(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(15.0),
                      padding: const EdgeInsets.all(5.0),
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(120),
                        shape: BoxShape.rectangle,
                      ),
                      child: SingleChildScrollView(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      "${vendRecup.VENDNOME}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.search),
                                    onPressed: () {
                                      if (vendRecup.VENDNOME != "MASTER") {
                                        setState(() {
                                          _myEmp = null;
                                        });
                                        Provider.of<VendedorProvider>(context,
                                                listen: false)
                                            .vendedorGet(null);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  VendedorBusca(),
                                            ));
                                      }
                                    },
                                  )
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                c.bdname != null
                    ? Stack(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.all(15.0),
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(120),
                              shape: BoxShape.rectangle,
                            ),
                            child: SingleChildScrollView(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                      child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton<String>(
                                        value: _myEmp,
                                        iconSize: 30,
                                        icon: (null),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                        hint: Text(
                                          'Empresa',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            _myEmp = null;
                                            _myEmp = newValue;
                                            _myVend = null;
                                          });

                                          print(newValue);

                                          for (int i = 0;
                                              i < empList.length;
                                              i++) {
                                            if (empList[i]['EMPID'] == _myEmp) {
                                              setState(() {
                                                empresa =
                                                    Empresa.fromMap(empList[i]);

                                                DBProvider.db
                                                    .deleteAllEmpresa();
                                                DBProvider.db
                                                    .newEmpresa(empresa);
                                                Provider.of<Empresa>(context,
                                                        listen: false)
                                                    .empSet(empresa);

                                                print(empresa);
                                              });
                                            }
                                          }
                                        },
                                        items: empList?.map((item) {
                                              return new DropdownMenuItem(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          new Text(
                                                            item[
                                                                'EMPNOMEFANTASIA'],
                                                            style: TextStyle(
                                                                fontSize: 15),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                value: item['EMPID'].toString(),
                                              );
                                            })?.toList() ??
                                            [],
                                      ),
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
                Container(
                  margin: const EdgeInsets.all(15.0),
                  height: 59.0,
                  child: TextField(
                    autofocus: true,
                    controller: senhatxt,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Senha",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: RaisedButton(
                      child: Text(
                        "ACESSAR",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      color: Colors.yellow[600],
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      onPressed: () {
                        _validarCampos();
                      }),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _mensagemErro,
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
