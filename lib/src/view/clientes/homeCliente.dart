import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/configEspe.dart';
import 'package:flutteraplicativo/src/models/vendedor.dart';
import 'package:flutteraplicativo/src/models/verdedorProvider.dart';
import 'package:flutteraplicativo/src/view/pedidos/orcamentoHome.dart';
import 'package:flutteraplicativo/src/view/pedidos/relatorio.dart';
import 'package:provider/provider.dart';

class HomeCLiente extends StatefulWidget {
  Vendedor vend;

  @override
  _HomeCLienteState createState() => _HomeCLienteState();
}

class _HomeCLienteState extends State<HomeCLiente>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> itensMenu = ["Ajuda", "Sair"];
  Especifica especifica = Especifica();

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
          title: Text("Clientes"),
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
  void didChangeDependencies() {
    recuperarPermissoes();
    super.didChangeDependencies();
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
          ListTile(
            leading: Icon(Icons.view_list_rounded),
            title: Text("CONTAS À RECEBER"),
            onTap: () {
              Navigator.pushNamed(context, "/contasReceber");
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
                  especifica.UPECADCLIENTE == 1
                      ? IconButton(
                          iconSize: 110,
                          icon: Image.asset(
                            'assets/addUser.png',
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/cadastroCliente');
                          })
                      : IconButton(
                          iconSize: 110,
                          icon: Image.asset(
                            'assets/addUser.png',
                          ),
                          onPressed: () {
                            showAlertDialog1(context);
                          }),
                  Text("Novo Cliente"),
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
                        Navigator.pushNamed(context, "/clientes");
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
