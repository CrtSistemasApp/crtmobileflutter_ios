import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/vendedor.dart';
import 'package:flutteraplicativo/src/models/verdedorProvider.dart';
import 'package:provider/provider.dart';

class Home2 extends StatefulWidget {
  @override
  _Home2State createState() => _Home2State();
}

class _Home2State extends State<Home2> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> itensMenu = ["Ajuda", "Sair"];
  Conexao c = Conexao();

  @override
  void initState() {
    recuperarConexao();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    recuperarConexao();
    super.didChangeDependencies();
  }

  void recuperarConexao() async {
    List list = await DBProvider.db.getAllConexaos();

    if (list.isNotEmpty) {
      c = await DBProvider.db.getConexao(1);

      setState(() {
        if (c.bdname != null) {
          c = c;
        }
      });
      print(c);
    }
  }

  _deslogarUsuario() async {
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);

     Vendedor vend = Vendedor();
    vend.VENDNOME = "Vendedor";
    vend.VENDEMAIL = "";
    Provider.of<VendedorProvider>(context, listen: false).vendedorGet(vend);
  }

  _escolhaMenuItem(String itemEscolhido) {
    print("dsaasd");
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
    return Scaffold(
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
            accountName: Text("Vendedor: MASTER"),
            accountEmail: Text("suporte@crtsistemas.com.br"),
            currentAccountPicture: GestureDetector(
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/pp.jpg'),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.supervisor_account),
            title: Text("CLIENTES"),
            enabled: false,
            onTap: () {
              Navigator.pushNamed(context, "/homeCliente");
            },
          ),
          ListTile(
            enabled: false,
            leading: Icon(Icons.card_travel),
            title: Text("ORÇAMENTOS"),
            onTap: () {},
          ),
          ListTile(
            enabled: false,
            leading: Icon(Icons.analytics_outlined),
            title: Text("RELATÓRIO POR SITUAÇÃO"),
            onTap: () {
              new PopupMenuButton(
                child: new ListTile(
                  title: new Text('Doge or lion?'),
                  trailing: const Icon(Icons.more_vert),
                ),
                itemBuilder: (_) => <PopupMenuItem<String>>[
                  new PopupMenuItem<String>(
                      child: new Text('Doge'), value: 'Doge'),
                  new PopupMenuItem<String>(
                      child: new Text('Lion'), value: 'Lion'),
                ],
                onSelected: (value) => {},
              );
              //Navigator.push(
              //    context,
              //    MaterialPageRoute(
              //      builder: (context) => Relatorio(),
              //    ));
            },
          ),
          ListTile(
            enabled: false,
            leading: Icon(Icons.local_offer),
            title: Text("PRODUTOS"),
            onTap: () {
              Navigator.pushNamed(context, "/homeProduto");
            },
          ),
          ListTile(
            enabled: c.bdname == null ? false : true,
            leading: Icon(Icons.image_rounded),
            title: Text("PRODUTOS IMAGENS"),
            onTap: () {
              Navigator.pushNamed(context, "/imgprod");
            },
          ),
          ListTile(
            enabled: c.bdname == null ? false : true,
            leading: Icon(Icons.business_outlined),
            title: Text("EMPRESA"),
            onTap: () {
              Navigator.pushNamed(context, "/configEmp");
            },
          ),
          ListTile(
            enabled: false,
            leading: Icon(Icons.person),
            title: Text("VENDEDORES"),
            onTap: () {
              Navigator.pushNamed(context, "/homeVendedor");
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("CONFIGURAÇÕES"),
            onTap: () {
              Navigator.pushNamed(context, "/configuracoes");
            },
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
