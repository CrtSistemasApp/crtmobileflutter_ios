import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/view/Select_formas.dart';
import 'package:flutteraplicativo/src/view/clientes/cadastroCliente.dart';
import 'package:flutteraplicativo/src/view/clientes/clientesPage.dart';
import 'package:flutteraplicativo/src/view/clientes/homeCliente.dart';
import 'package:flutteraplicativo/src/view/clientes/selectCliente.dart';
import 'package:flutteraplicativo/src/view/configuracoesPage.dart';
import 'package:flutteraplicativo/src/view/empresas/telaEmpresa.dart';
import 'package:flutteraplicativo/src/view/home.dart';
import 'package:flutteraplicativo/src/view/home2.dart';
import 'package:flutteraplicativo/src/view/login/loginPage.dart';
import 'package:flutteraplicativo/src/view/pedidos/editOrcamento.dart';
import 'package:flutteraplicativo/src/view/pedidos/orcamentoHome.dart';
import 'package:flutteraplicativo/src/view/pedidos/cadastroOrcamento.dart';
import 'package:flutteraplicativo/src/view/produtos/homeProdImg.dart';
import 'package:flutteraplicativo/src/view/produtos/homeProdutos.dart';
import 'package:flutteraplicativo/src/view/vendedores/homeVendedor.dart';
import 'package:flutteraplicativo/src/view/vendedores/selectVendedor.dart';
import 'package:splashscreen/splashscreen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => SplashScreen());

      case "/telaInicial":
        return MaterialPageRoute(builder: (_) => Home());

      case "/loged":
        return MaterialPageRoute(builder: (_) => Home2());

      case "/login":
        return MaterialPageRoute(builder: (_) => Login());

      case "/homeCliente":
        return MaterialPageRoute(builder: (_) => HomeCLiente());

      case "/cadastroCliente":
        return MaterialPageRoute(builder: (_) => CadastroCliente());

      case "/homePedidos":
        return MaterialPageRoute(builder: (_) => HomeOrcamentos());

      case "/cadastroPedido":
        return MaterialPageRoute(builder: (_) => CadastroPedido());

      case "/clientes":
        return MaterialPageRoute(builder: (_) => Clientes());

      case "/clientesBusca":
        return MaterialPageRoute(builder: (_) => ClientesBusca());

      case "/selectForma":
        return MaterialPageRoute(builder: (_) => SelectFormas());

      case "/configuracoes":
        return MaterialPageRoute(builder: (_) => Configuracoes());

      case "/homeVendedor":
        return MaterialPageRoute(builder: (_) => Vendedores());

      case "/vendedorBusca":
        return MaterialPageRoute(builder: (_) => VendedorBusca());

      case "/homeProduto":
        return MaterialPageRoute(builder: (_) => Produtos());

      case "/imgprod":
        return MaterialPageRoute(builder: (_) => ImgProd());

      case "/configEmp":
        return MaterialPageRoute(builder: (_) => EmpresaView());

      case "/selectCliente":
        return MaterialPageRoute(builder: (_) => ClientesBusca());

      default:
        _erroRota();

        return null;
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Tela não encontrada!"),
        ),
        body: Center(
          child: Text("Tela não encontrada!"),
        ),
      );
    });
  }
}
