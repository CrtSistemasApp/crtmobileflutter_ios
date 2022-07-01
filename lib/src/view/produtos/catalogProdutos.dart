import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/cliente.dart';
import 'package:flutteraplicativo/src/models/clienteProvider.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/conexaoProvider.dart';
import 'package:flutteraplicativo/src/models/configEspe.dart';
import 'package:flutteraplicativo/src/models/configProvider.dart';
import 'package:flutteraplicativo/src/models/configuracoes.dart';
import 'package:flutteraplicativo/src/view/produtos/homeProdutos.dart';
import 'package:flutteraplicativo/src/models/empresaModel.dart';
import 'package:flutteraplicativo/src/models/produtoProvider.dart';
import 'package:flutteraplicativo/src/models/produtos.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) =>
      this.toLowerCase().contains(secondString.toLowerCase());
}

class ProdutosCatalog extends StatefulWidget {
  ProdutosCatalog({Key key}) : super(key: key);

  @override
  _ProdutosCatalogState createState() => _ProdutosCatalogState();
}

class _ProdutosCatalogState extends State<ProdutosCatalog> {
  List catalogitems = [];
  FocusNode myFocusNode;
  Future produtosDb;
  bool focus = true;
  String searchString = "";
  bool usage = false;
  TextEditingController searchController = TextEditingController();
  Conexao c = Conexao();
  int empid = 0;
  double precoBusca = 0.0;
  ConfigProvider config = ConfigProvider();
  Cliente cli = Cliente();
  var dados;
  bool buttonActive = false;
  List valoresProd = [];
  List valoresVenda = [];
  ConfiguracoesModel configuracoesModel = ConfiguracoesModel();
  Produto buscaProd = Produto();
  var listaUnidades = {
    "0": "UN",
    "1": "CAIXA",
    "2": "PACOTE",
    "3": "M",
    "4": "KG",
    "5": "M2",
    "6": "BALDE",
    "7": "GALÃO",
    "8": "LATA",
    "9": "TAMBOR",
    "10": "LITRO",
    "11": "BARRICA",
    "12": "CENTO",
    "13": "PEÇA",
    "14": "ML",
    "15": "BISNAGA",
    "16": "SACO",
    "17": "POTE",
    "18": "ROLO",
    "19": "BOBINA",
    "20": "MILHEIRO",
    "21": "CONJUNTO",
    "22": "MEDIDA",
    "23": "ENVELOPE",
    "24": "BANDEJA",
    "25": "M3",
    "26": "FARDO",
    "27": "PAR",
    "28": "TUBO",
    "29": "JOGO",
    "30": "DUZIA",
    "31": "TONELADA",
    "32": "BOMBONA",
    "33": "RESMA",
    "34": "FOLHA",
    "35": "VARA",
    "36": "FRASCO",
    "37": "CIL"
  };
  @override
  void initState() {
    recuperarConexao();
    myFocusNode = FocusNode();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    recuperarEmpid();
    recuperarConfig();
    recuperarConfiguracoesModel();
    recuperarDadosCliente();
    super.didChangeDependencies();
  }

  void recuperarConexao() async {
    List list = await DBProvider.db.getAllConexaos();

    if (list.isNotEmpty) {
      c = await DBProvider.db.getConexao(1);
    }
  }

  void recuperarConfiguracoesModel() {
    if (Provider.of<ConfiguracoesModel>(context).config != null) {
      configuracoesModel =
          Provider.of<ConfiguracoesModel>(context, listen: false).config;

      setState(() {
        valoresVenda =
            Provider.of<Especifica>(context, listen: false).listValores;
      });
    }
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

  //_listaBusca() async {
  //  while (searchController.text.isNotEmpty) {
  //    return await produtosDb;
  //  }
  //}

  String _formatValue(double value) {
    final NumberFormat numberFormat = new NumberFormat("#,##0.00", "pt_BR");
    return numberFormat.format(value);
  }

  void imgDialog(String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            // You need this, notice the parameters below:
            builder: (BuildContext context, StateSetter setState) {
              return CachedNetworkImage(imageUrl: url);
            },
          ),
        );
      },
    );
  }

  Future<double> buscarUltimoValor(int cliid, int proid) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/ultimovalorvenda.php?cliid=${cliid}&proid=${proid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (msg == "Dados incorretos!") {
    } else {
      var dados = obj['result'];

      return await double.parse(dados[0]['ORIVALOR']);
    }
  }

  void recuperarDadosCliente() {
    if (Provider.of<ClienteProvider>(context).cli != null) {
      cli = Provider.of<ClienteProvider>(context).cli;
    }
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selecionar Produtos"),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, right: 20.0, left: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.all(10.0)),
              Container(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Buscar Produtos',
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
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ))),
                        onPressed: () {
                          setState(() {
                            if (usage == false) {
                              usage = true;
                            }
                          });
                          if (searchController.text.isNotEmpty) {
                            if (isNumeric(searchController.text)) {
                              setState(() {
                                produtosDb =
                                    selectProdutos(null, searchController.text);
                              });
                            } else {
                              setState(() {
                                produtosDb =
                                    selectProdutos(searchController.text, '');
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
              Padding(padding: EdgeInsets.all(16.0)),
              usage == false
                  ? Text("")
                  : Container(
                      height: MediaQuery.of(context).size.height * 0.77,
                      child: FutureBuilder(
                          future: produtosDb,
                          builder: (context, snapshot) {
                            double c_width =
                                MediaQuery.of(context).size.width * 0.7;
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.waiting:
                                return Center(
                                  child: Column(
                                    children: <Widget>[
                                      Text("Carregando Produtos"),
                                      CircularProgressIndicator()
                                    ],
                                  ),
                                );
                                break;
                              case ConnectionState.active:
                              case ConnectionState.done:
                                return catalogitems == null ||
                                        catalogitems[0]['PROID'] == null
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          left: 80,
                                        ),
                                        child: Text(
                                          "Produto não encontrado",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : Container(
                                        height: double.infinity,
                                        child: ListView.builder(
                                          cacheExtent: 9999,
                                          shrinkWrap: true,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                              ),
                                              child: Column(
                                                children: <Widget>[
                                                  Card(
                                                    elevation: 5,
                                                    color: Colors.grey[100],
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Container(
                                                              width: c_width,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    'Referência: ${catalogitems[index]['PROREFERENCIA']}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '${catalogitems[index]['PRONOME']}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    'VENDA: R\$:  ${_formatValue(double.parse(catalogitems[index]['PROVALORVENDA1']))}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                              .blue[
                                                                          900],
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                  config.ULTIMOVALORVENDA ==
                                                                          1
                                                                      ? FutureBuilder<
                                                                          double>(
                                                                          future: buscarUltimoValor(
                                                                              cli.id,
                                                                              int.parse(catalogitems[index]['PROID'])), // function where you call your api
                                                                          builder:
                                                                              (BuildContext context, AsyncSnapshot<double> snapshot) {
                                                                            // AsyncSnapshot<Your object type>
                                                                            if (snapshot.connectionState ==
                                                                                ConnectionState.waiting) {
                                                                              return CircularProgressIndicator();
                                                                            } else {
                                                                              if (snapshot.hasError)
                                                                                return Center(child: Text('Error: ${snapshot.error}'));
                                                                              else
                                                                                return snapshot.data == null
                                                                                    ? Container()
                                                                                    : new Text(
                                                                                        'ULTIMA VENDA: R\$:  ${_formatValue(snapshot.data)}',
                                                                                        textAlign: TextAlign.left,
                                                                                        style: TextStyle(
                                                                                          color: Colors.blue[900],
                                                                                          fontSize: 16,
                                                                                        ),
                                                                                      ); // snapshot.data  :- get your object which is pass from your downloadData() function
                                                                            }
                                                                          },
                                                                        )
                                                                      : Container(),
                                                                  catalogitems[index]
                                                                              [
                                                                              'LOPQTD'] ==
                                                                          null
                                                                      ? Text(
                                                                          'Qtd Est: 0.00',
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.blue[900],
                                                                            fontSize:
                                                                                16,
                                                                          ),
                                                                        )
                                                                      : Text(
                                                                          'Qtd Est: ${_formatValue(double.parse(catalogitems[index]['LOPQTD']))}',
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.blue[900],
                                                                            fontSize:
                                                                                16,
                                                                          ),
                                                                        ),
                                                                  Text(
                                                                    'Unidade: ${listaUnidades['${catalogitems[index]['PROUNIDADE']}']}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                              .blue[
                                                                          900],
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                  config.PRECODECUSTO ==
                                                                          1
                                                                      ? Text(
                                                                          'CUSTO: R\$:  ${_formatValue(double.parse(catalogitems[index]['PROVALORCUSTO']))}',
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.blue[900],
                                                                            fontSize:
                                                                                16,
                                                                          ),
                                                                        )
                                                                      : Text(
                                                                          ""),
                                                                  catalogitems[index]['PROIMAGEM'] ==
                                                                              null ||
                                                                          catalogitems[index]['PROIMAGEM'] ==
                                                                              ""
                                                                      ? Text(
                                                                          "Sem Imagem")
                                                                      : SizedBox(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(bottom: 10),
                                                                            child:
                                                                                GestureDetector(
                                                                              onTap: () {
                                                                                Produto prod = Produto();
                                                                                prod.PROREFERENCIA = "${catalogitems[index]['PROREFERENCIA']}";
                                                                                prod.PRONOME = "${catalogitems[index]['PRONOME']}";
                                                                                prod.PROVALOR = double.parse("${catalogitems[index]['PROVALORVENDA1']}");
                                                                                Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                        builder: (context) => ImageViewer(
                                                                                              url: "${catalogitems[index]['PROIMAGEM']}",
                                                                                              prod: prod,
                                                                                            )));
                                                                              },
                                                                              child: Image.network(
                                                                                "${catalogitems[index]['PROIMAGEM']}",
                                                                                cacheHeight: 150,
                                                                                cacheWidth: 150,
                                                                                loadingBuilder: (context, child, loadingProgress) {
                                                                                  if (loadingProgress == null) return child;

                                                                                  return const Center(child: Text('Loading...'));
                                                                                  // You can use LinearProgressIndicator, CircularProgressIndicator, or a GIF instead
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            if (buttonActive ==
                                                                false) {
                                                              setState(() {
                                                                buttonActive =
                                                                    true;
                                                              });
                                                              if (Provider.of<
                                                                          ProdutoProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .items
                                                                  .contains(
                                                                      catalogitems[
                                                                          index])) {
                                                                catalogitems[
                                                                        index]
                                                                    .quantity++;
                                                              } else {
                                                                Produto
                                                                    produto =
                                                                    new Produto();

                                                                produto.PROID = int.parse(
                                                                    catalogitems[
                                                                            index]
                                                                        [
                                                                        'PROID']);

                                                                produto.PROREFERENCIA =
                                                                    catalogitems[
                                                                            index]
                                                                        [
                                                                        'PROREFERENCIA'];

                                                                double result =
                                                                    await buscarUltimoValor(
                                                                        cli.id,
                                                                        produto
                                                                            .PROID);

                                                                produto.PRONOME =
                                                                    catalogitems[
                                                                            index]
                                                                        [
                                                                        'PRONOME'];
                                                                produto.PRODESCRICAO =
                                                                    catalogitems[
                                                                            index]
                                                                        [
                                                                        'PRODESCRICAO'];

                                                                config.ULTIMOVALORVENDA ==
                                                                        0
                                                                    ? result !=
                                                                            null
                                                                        ? produto.PROVALOR =
                                                                            result
                                                                        : produto
                                                                            .PROVALOR = double.parse(catalogitems[
                                                                                index]
                                                                            [
                                                                            'PROVALORVENDA1'])
                                                                    : produto
                                                                        .PROVALOR = double.parse(catalogitems[
                                                                            index]
                                                                        [
                                                                        'PROVALORVENDA1']);
                                                                produto.PROIMAGEM =
                                                                    catalogitems[
                                                                            index]
                                                                        [
                                                                        'PROIMAGEM'];
                                                                produto.quantity =
                                                                    1;
                                                                produto.PROVALORDESCONTO =
                                                                    0.0;
                                                                produto.PRECOCUSTO =
                                                                    double.parse(
                                                                        catalogitems[index]
                                                                            [
                                                                            'PROVALORCUSTO']);

                                                                produto.PROOBS =
                                                                    "";

                                                                List<dynamic>
                                                                    dadosLocais =
                                                                    [];

                                                                setState(() {
                                                                  dadosLocais.add(
                                                                      catalogitems[
                                                                          index]);
                                                                });

                                                                produto.dados =
                                                                    dadosLocais;

                                                                Provider.of<ProdutoProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .addProd(
                                                                        produto);

                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              }
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            width: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .blue[900],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Center(
                                                                child: Icon(
                                                              Icons
                                                                  .add_shopping_cart_sharp,
                                                              color:
                                                                  Colors.white,
                                                              size: 20,
                                                            )),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          itemCount: catalogitems.length,
                                        ),
                                      );

                                break;
                            }
                            return Text("");
                          }),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future getDataProd() async {
    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/buscarProdutos.php?idCliente=${empid}"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);

      setState(() {
        catalogitems = obj['result'];
      });

      return obj['result'];
    } catch (e) {
      print("Não encontrados");
    }
  }

  Future<String> buscarProdStq(String ref) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/produtoSemStq.php?ref=${ref}&empid=${empid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (msg == "Dados incorretos!") {
    } else {
      dados = obj['result'];
      setState(() {
        catalogitems = obj['result'];
      });
    }
  }

  Future buscarProdid(String proid, String empid) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/buscarProdutoId.php?proid=${proid}&empid=${empid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (msg == "Dados incorretos!") {
      print("error");
    } else {
      dados = obj['result'];
      setState(() {
        catalogitems = obj['result'];
      });

      if (catalogitems[0]['PROID'] == null) {
        buscarProdStq(proid);
      }

      return obj['result'];
    }
  }

  Future<Produto> _dadosProd(dados) async {
    Produto prod = Produto();
    prod.PROID = int.parse(dados[0]['PROREFERENCIA']);
    prod.PRONOME = dados[0]['PRONOME'];
    prod.PRODESCRICAO = dados[0]['PRODESCRICAO'];
    prod.PRECOCUSTO = double.parse(dados[0]['PROVALORCUSTO']);
    if (config.ULTIMOVALORVENDA == 1) {
      double result = await buscarUltimoValor(cli.id, prod.PROID);

      if (result == null) {
        prod.PROVALOR = double.parse(dados[0]['PROVALORVENDA1']);
      } else {
        prod.PROVALOR = result;
      }
    } else {
      prod.PROVALOR = double.parse(dados[0]['PROVALORVENDA1']);
    }

    prod.PROVALORDESCONTO = 0.0;
    prod.quantity = 1;
    prod.PROOBS = "";

    return prod;
  }

  void MensagemProd() {
    var alert = new AlertDialog(
      contentPadding: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
      backgroundColor: Colors.red,
      title: new Text(
        "Nenhum Produto encontrado!",
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

  bool isNumeric(String string) {
    final numericRegex = RegExp(r'^[\d,.?!]+$');

    return numericRegex.hasMatch(string);
  }

  Future selectProdutos(String busca, String preco) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/selectPronome.php?preco=${preco}&busca=${busca}&idCliente=${empid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);

    setState(() {
      catalogitems = obj['result'];
    });

    if (catalogitems == null) {
      if (isNumeric(preco)) {
        return buscarProdid(preco, empid.toString());
      } else {
        selectProdutosEstoque(busca);
      }
    }
    if (catalogitems == []) {
      MensagemProd();
    }
    return obj['result'];
  }

  Future selectProdutosEstoque(String busca) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/selectpronomeesto.php?busca=${busca}&empid=${empid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);

    setState(() {
      catalogitems = obj['result'];
    });

    return obj['result'];
  }
}
