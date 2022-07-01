import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/clienteProvider.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/conexaoProvider.dart';
import 'package:flutteraplicativo/src/models/configuracoesModel.dart';
import 'package:flutteraplicativo/src/models/produtoProvider.dart';
import 'package:flutteraplicativo/src/models/vendedor.dart';
import 'package:flutteraplicativo/src/models/verdedorProvider.dart';
import 'package:flutteraplicativo/src/view/pedidos/orcamentoHome.dart';
import 'package:flutteraplicativo/src/view/pedidos/relatorio.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> itensMenu = ["Ajuda", "Sair"];
  Conexao c = Conexao();
  String _mensagemErro;
  var dados;
  int idCliente = 0;
  ConfigModel conf = ConfigModel();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    recuperarConexao();
    super.initState();
  }

  void recuperarConexao() async {
    c = await DBProvider.db.getConexao(1);
  }

  buscar(String cnpj) async {
    await _buscarCliente(cnpj).then((sucess) => {
          print("id cliente recuperado com sucesso!"),
        });
  }

  Future<String> _buscarCliente(String cnpj) async {
    final result = await http.post(
        'http://crtsistemas.com.br/crt_mobile_flutter/apis/clientes/buscarClienteCNPJ.php?cnpj=${cnpj}',
        body: c.toJson());

    if (result.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      var obj = convert.json.decode(result.body);
      dados = obj['result'];

      setState(() {
        idCliente = int.parse(dados[0]['EMPID']);
        String razao = dados[0]['EMPRAZAOSOCIAL'];
        String fone = dados[0]['EMPFONE01'];
        String fone2 = dados[0]['EMPFONE02'];
        String email = dados[0]['EMPEMAIL'];
        String logradouro = dados[0]['EMPENDERECO'];
        String numero = dados[0]['EMPNUMERO'];
        String bairro = dados[0]['EMPBAIRRO'];
        String cidade = dados[0]['EMPCIDADE'];
        String cep = dados[0]['EMPCEP'];
        String uf = dados[0]['EMPUF'];

        Provider.of<ClienteProvider>(context, listen: false)
            .setIdCliente(idCliente);
        Provider.of<ClienteProvider>(context, listen: false).setRazao(razao);
        Provider.of<ClienteProvider>(context, listen: false).setFone(fone);
        Provider.of<ClienteProvider>(context, listen: false).setFone2(fone2);
        Provider.of<ClienteProvider>(context, listen: false).setEmail(email);
        Provider.of<ClienteProvider>(context, listen: false)
            .setLogradouro(logradouro);
        Provider.of<ClienteProvider>(context, listen: false).setBairro(bairro);
        Provider.of<ClienteProvider>(context, listen: false).setNumero(numero);
        Provider.of<ClienteProvider>(context, listen: false).setCidade(cidade);
        Provider.of<ClienteProvider>(context, listen: false).setCep(cep);
        Provider.of<ClienteProvider>(context, listen: false).setUF(uf);
      });

      return result.body;
    } else {
      setState(() {
        _mensagemErro = "Cliente não encontrado!";
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  _deslogarUsuario() async {
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);

    Vendedor vend = Vendedor();
    vend.VENDNOME = "Vendedor";
    vend.VENDEMAIL = "";
    Provider.of<VendedorProvider>(context, listen: false).vendedorGet(vend);
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.blue[900],
          title: Row(
            children: <Widget>[
              Image.asset(
                'assets/logo1.png',
                fit: BoxFit.cover,
                height: 40,
              ),
              Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('CRT SISTEMAS'))
            ],
          ),
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
          ],
        ),
        body: _home(),
        drawer: _drawer(),
      ),
    );
  }

  _home() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: new AssetImage("assets/backgroud2.jpeg"),
              fit: BoxFit.cover)),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Você tem certeza que quer sair do sistema?'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('Não'),
          ),
          new FlatButton(
            onPressed: () {
              exit(0);
            },
            child: new Text('Sim'),
          ),
        ],
      ),
    );
  }

  void onDismiss() {
    print('Menu is dismiss');
  }

  showAlertDialog(BuildContext context) {
    // set up the button

    // set up the AlertDialog
    var alert = SizedBox(
        width: 20,
        height: 20,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/pp.jpg"))),
        ));

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _drawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          SizedBox(
              height: 40,
              child: Container(
                child: Padding(
                    child: Center(
                        child: Text(
                      "CRT SISTEMAS MOBILE",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
                    padding: EdgeInsets.only(top: 10)),
                decoration: BoxDecoration(color: Colors.blue[900]),
              )),
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue[900]),
            accountName: Text("Vendedor: " +
                Provider.of<VendedorProvider>(context).vendedor.VENDNOME),
            accountEmail:
                Text(Provider.of<VendedorProvider>(context).vendedor.VENDEMAIL),
            currentAccountPicture: GestureDetector(
              child: GestureDetector(
                onTap: () {
                  showAlertDialog(context);
                },
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/pp.jpg'),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.supervisor_account),
            title: Text("CLIENTES"),
            onTap: () {
              Navigator.pushNamed(context, "/homeCliente");
            },
          ),
          ListTile(
            leading: Icon(Icons.card_travel),
            title: Text("ORÇAMENTOS"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeOrcamentos(
                      vend: Provider.of<VendedorProvider>(context).vendedor,
                    ),
                  ));
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics_outlined),
            title: Text("RELATÓRIO"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Relatorio(),
                  ));
            },
          ),
          ListTile(
            leading: Icon(Icons.local_offer),
            title: Text("PRODUTOS"),
            onTap: () {
              Navigator.pushNamed(context, "/homeProduto");
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("VENDEDORES"),
            onTap: () {
              Navigator.pushNamed(context, "/homeVendedor");
            },
          ),
          Provider.of<VendedorProvider>(context).vendedor.VENDNOME == "MASTER"
              ? ListTile(
                  leading: Icon(Icons.settings),
                  title: Text("CONFIGURAÇÕES"),
                  onTap: () {
                    Navigator.pushNamed(context, "/configuracoes");
                  },
                )
              : ListTile(
                  leading: Icon(Icons.settings),
                  title: Text("CONFIGURAÇÕES"),
                ),
          ListTile(
            enabled: false,
            leading: Icon(Icons.error_outline),
            title: Text("SOBRE"),
          ),
        ],
      ),
    );
  }
}
