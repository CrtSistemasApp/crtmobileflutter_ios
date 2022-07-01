import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/clienteProvider.dart';
import 'package:flutteraplicativo/src/models/formasModel.dart';
import 'package:flutteraplicativo/src/models/produtoProvider.dart';
import 'package:flutteraplicativo/src/models/vendedor.dart';
import 'package:flutteraplicativo/src/models/verdedorProvider.dart';
import 'package:flutteraplicativo/src/view/pedidos/cadastroOrcamento.dart';
import 'package:flutteraplicativo/src/view/pedidos/mostrarOrcamentos.dart';
import 'package:flutteraplicativo/src/view/pedidos/relatorio.dart';
import 'package:provider/provider.dart';

class HomeOrcamentos extends StatefulWidget {
  Vendedor vend;

  HomeOrcamentos({Key key, this.vend}) : super(key: key);

  @override
  _HomeOrcamentosState createState() => _HomeOrcamentosState();
}

class _HomeOrcamentosState extends State<HomeOrcamentos>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> itensMenu = ["Ajuda", "Sair"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue[900],
          title: Text("Orçamentos"),
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
      body: _home(),
      drawer: _drawer(),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        print("Ajuda");
        break;
      case "Sair":
        _deslogarUsuario();
        break;
    }
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
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/pp.jpg'),
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
                      vend: widget.vend,
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
            leading: Icon(Icons.error_outline),
            title: Text("SOBRE"),
          ),
        ],
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: CircleAvatar(
              radius: 150.0,
              backgroundColor: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      iconSize: 110,
                      icon: Image.asset(
                        'assets/carrinho.png',
                      ),
                      onPressed: () {
                        Provider.of<FormasProvider>(context, listen: false)
                            .reset();

                        Provider.of<ProdutoProvider>(context, listen: false)
                            .addProd(null);
                        if (Provider.of<ProdutoProvider>(context, listen: false)
                            .items
                            .isNotEmpty) {
                          Provider.of<ProdutoProvider>(context, listen: false)
                              .clearList();
                        }

                        if (Provider.of<ClienteProvider>(context, listen: false)
                                .cli !=
                            null) {
                          Provider.of<ClienteProvider>(context, listen: false)
                              .clienteReset();
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CadastroPedido(),
                            ));
                      }),
                  Text("Novo Orçamento"),
                ],
              ),
            ),
          ),
          Expanded(
            child: CircleAvatar(
              radius: 150.0,
              backgroundColor: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      iconSize: 110,
                      icon: Image.asset(
                        'assets/lupa.png',
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PedidosView(),
                            ));
                      }),
                  Text("Pesquisa"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
