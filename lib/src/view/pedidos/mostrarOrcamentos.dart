import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/cliente.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/configEspe.dart';
import 'package:flutteraplicativo/src/models/empresaModel.dart';
import 'package:flutteraplicativo/src/models/orcamento.dart';
import 'package:flutteraplicativo/src/models/produtos.dart';
import 'package:flutteraplicativo/src/models/vendedor.dart';
import 'package:flutteraplicativo/src/models/verdedorProvider.dart';
import 'package:flutteraplicativo/src/view/pedidos/cadastroOrcamento.dart';
import 'package:flutteraplicativo/src/view/pedidos/editOrcamento.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) =>
      this.toLowerCase().contains(secondString.toLowerCase());
}

class PedidosView extends StatefulWidget {
  @override
  _PedidosViewState createState() => _PedidosViewState();
}

class _PedidosViewState extends State<PedidosView> {
  Future<Produto> futureProd;
  Future _future;
  String razaosocial;
  String cpf_cnpj;
  Future _selectCliente;
  List orcamentos;
  List resulOrcamentos;
  String valoDesconto = "";
  String msg = '';
  String searchString = "";
  String orcstatus = "";
  TextEditingController searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();
  String _mensagemErro = "";
  TextEditingController razaosocialtxt = TextEditingController(text: "dan");
  TextEditingController cpf_cnpjtxt = TextEditingController(text: "123");
  var dados;
  Orcamento pedido = Orcamento();
  List pedidos;
  Vendedor vendedor;
  String vendNome;
  int idVend;
  Conexao c = Conexao();
  Orcamento orc = Orcamento();
  List produtosOrc = [];
  Empresa empresa = Empresa();
  List<Produto> produtos = [];
  double desconto = 0.0;
  int usuid = 0;
  Especifica especifica = Especifica();

  @override
  void initState() {
    recuperarConexao();

    super.initState();

    //this.buscarCliente();
  }

  void recuperarEmpid() {
    if (Provider.of<Empresa>(context).empresa != null) {
      empresa = Provider.of<Empresa>(context).empresa;
    }
  }

  void recuperarDados() {
    vendedor = Provider.of<VendedorProvider>(context).vendedor;
    vendNome = Provider.of<VendedorProvider>(context).vendedor.VENDNOME;
    idVend = Provider.of<VendedorProvider>(context).vendedor.VENDID;
    usuid = Provider.of<VendedorProvider>(context).vendedor.USUID;
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
  void didChangeDependencies() {
    recuperarDados();
    recuperarEmpid();
    recuperarPermissoes();
    super.didChangeDependencies();
  }

  void recuperarConexao() async {
    c = await DBProvider.db.getConexao(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text("Orçamentos"),
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
                  labelText: 'Buscar Orçamentos',
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
                              _future = getData('', searchController.text);
                            });
                          } else {
                            setState(() {
                              _future = getData(searchController.text, '');
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
                child: FutureBuilder(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) print(snapshot.error);
                      double c_width = MediaQuery.of(context).size.width * 0.7;
                      return snapshot.hasData
                          ? ListView.builder(
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Card(
                                    elevation: 5,
                                    color: Colors.grey[100],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  children: [
                                                    Container(
                                                      width: c_width,
                                                      child: new Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            "Orçamento: " +
                                                                orcamentos[
                                                                        index]
                                                                    ["ORCID"],
                                                            style: TextStyle(
                                                                color: Colors
                                                                        .indigo[
                                                                    900],
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            orcamentos[index][
                                                                "CLINOMERAZAO"],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blue[300]),
                                                          ),
                                                          Text(
                                                            orcamentos[index]
                                                                ["CLINOME"],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blue[300]),
                                                          ),
                                                          Text(
                                                            "Valor total: " +
                                                                _formatValue(double
                                                                    .parse(orcamentos[
                                                                            index]
                                                                        [
                                                                        "ORCVALORTOTAL"])),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blue[300]),
                                                          ),
                                                          Text(
                                                            "Obs Prod: " +
                                                                orcamentos[
                                                                        index]
                                                                    ["ORCOBS"],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blue[300]),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        getOrcamentos(int.parse(
                                                            orcamentos[index]
                                                                ["ORCID"]));
                                                      },
                                                      child: Container(
                                                        height: 40,
                                                        width: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.blue[900],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Center(
                                                            child: Icon(
                                                          Icons.search,
                                                          color: Colors.white,
                                                          size: 20,
                                                        )),
                                                      ),
                                                    ),
                                                    Padding(
                                                        padding: EdgeInsets.all(
                                                            8.0)),
                                                    orcamentos[index]
                                                                ['ORCSTATUS'] ==
                                                            "1"
                                                        ? Center(
                                                            child: Icon(
                                                            Icons.lock_sharp,
                                                            color: Colors.red,
                                                            size: 20,
                                                          ))
                                                        : Container(),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              itemCount: orcamentos.length,
                            )
                          : Center(child: Text(""));
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue(double value) {
    final NumberFormat numberFormat = new NumberFormat("#,##0.00", "pt_BR");
    return numberFormat.format(value);
  }

  String _formatQtd(double value) {
    final NumberFormat numberFormat = new NumberFormat("#,#0.0", "pt_BR");
    return numberFormat.format(value);
  }

  void imprimir(GeneratePDFState pdf) {
    pdf.generatePDFInvoice();
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
      title: Text("Não permitido!"),
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

  showAlertSem(BuildContext context) {
    // configura o button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    // configura o  AlertDialog
    AlertDialog alerta = AlertDialog(
      title: Text("Orçamento não encontrado!"),
      content: Text(
          "Realize um orçamento ou verifique o id do orçamento, nome do cliente"),
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

  void show() {
    String data;
    var total = orc.ORCVALORTOTAL + double.parse(valoDesconto);

    data = DateFormat("dd-MM-yyyy").format(DateTime.parse("${orc.ORCDATA}"));
    var alert = SingleChildScrollView(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
              child: RichText(
                text: TextSpan(
                  text: ' ORCID: ',
                  style: TextStyle(color: Colors.grey[700], fontSize: 18),
                  children: <TextSpan>[
                    TextSpan(
                      text: orc.ORCID.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      //recognizer: _longPressRecognizer,
                    ),
                    TextSpan(
                        text: '  DATA: ',
                        style: TextStyle(fontSize: 18),
                        children: <TextSpan>[
                          TextSpan(
                              text: data,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              )),
                          TextSpan(
                              text: "  " + orc.ORCHORA,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              )),
                        ]),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
              child: RichText(
                text: TextSpan(
                  text: ' CLIENTE: ',
                  style: TextStyle(color: Colors.grey[700], fontSize: 18),
                  children: <TextSpan>[
                    TextSpan(
                      text: orc.CLINOMEFANTASIA,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 36.0, left: 4.0, right: 4.0),
              child: RichText(
                text: TextSpan(
                  text: ' VENDEDOR(A): ',
                  style: TextStyle(color: Colors.grey[700], fontSize: 18),
                  children: <TextSpan>[
                    TextSpan(
                      text: orc.VENNOME,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      //recognizer: _longPressRecognizer,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
              child: RichText(
                text: TextSpan(
                  text: ' OBSERVAÇÕES DO PEDIDO: ',
                  style: TextStyle(color: Colors.grey[700], fontSize: 18),
                  children: <TextSpan>[
                    TextSpan(
                      text: orc.ORCOBS,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      //recognizer: _longPressRecognizer,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
              child: RichText(
                text: TextSpan(
                  text: ' FPG: ',
                  style: TextStyle(color: Colors.grey[700], fontSize: 18),
                  children: <TextSpan>[
                    TextSpan(
                      text: orc.ORCFORMAPAGAMENTOTXT,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      //recognizer: _longPressRecognizer,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
              child: RichText(
                text: TextSpan(
                  text: ' VALOR TOTAL: ',
                  style: TextStyle(color: Colors.grey[700], fontSize: 18),
                  children: <TextSpan>[
                    TextSpan(
                      text: "R\$ ${total}",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      //recognizer: _longPressRecognizer,
                    ),
                  ],
                ),
              ),
            ),
            valoDesconto != "0.0"
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, left: 4.0, right: 4.0),
                        child: RichText(
                          text: TextSpan(
                            text: ' VALOR DESCONTO: ',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 18),
                            children: <TextSpan>[
                              TextSpan(
                                text: "R\$ ${valoDesconto}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                //recognizer: _longPressRecognizer,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, left: 4.0, right: 4.0),
                        child: RichText(
                          text: TextSpan(
                            text: ' VALOR TOTAL COM DESCONTO: ',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 18),
                            children: <TextSpan>[
                              TextSpan(
                                text: "R\$ ${orc.ORCVALORTOTAL}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                //recognizer: _longPressRecognizer,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
              child: SizedBox(
                width: 375,
                height: 35,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "PRODUTOS",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  color: Colors.blue[900],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              child: SizedBox(
                width: 375,
                height: 300,
                child: Container(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            width: 500,
                            height: 164,
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "REF: ${produtos[index].PROREFERENCIA}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${produtos[index].PRONOME}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      "QTD:  ${_formatQtd(produtos[index].quantity)}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal)),
                                  Text(
                                      "Valor(item): R\$ ${_formatValue(produtos[index].PROVALOR)}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal)),
                                  Text(
                                      "Valor(desconto): R\$ ${_formatValue(produtos[index].PROVALORDESCONTO)}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal)),
                                  Text(
                                      "Grade: ${produtos[index].COR}, ${produtos[index].TAMANHO}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal))
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: produtos.length,
                      )),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
                child: Row(
                  children: [
                    Padding(padding: EdgeInsets.all(2.0)),
                    especifica.UPEALTERARORCAMENTO == 1 &&
                            (orcstatus == "N" ||
                                orcstatus == "A" ||
                                orcstatus == "0")
                        ? SizedBox(
                            width: 75,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue[900], // background
                                onPrimary: Colors.white, // foreground
                              ),
                              onPressed: () {
                                Cliente cli = Cliente(
                                    razao: orc.CLINOMERAZAO,
                                    cpf_cnpj: orc.CLICPF);
                                Vendedor ven = Vendedor();
                                ven.VENDNOME = orc.VENNOME;
                                ven.VENDTEL = orc.FONEVEND;
                                ven.VENDEMAIL = "";
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditOrcamento(
                                          vend: ven,
                                          cli: cli,
                                          list: produtos,
                                          orc: orc),
                                    ));
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.edit),
                                ],
                              ),
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue[900], // background
                              onPrimary: Colors.white, // foreground
                            ),
                            onPressed: () {
                              showAlertDialog1(context);
                            },
                            child: Column(
                              children: [
                                Icon(Icons.edit),
                              ],
                            ),
                          ),
                    Padding(padding: EdgeInsets.all(6.0)),
                    especifica.UPEEXCLUIRORCAMENTO == 1 && orcstatus != "1"
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue[900], // background
                              onPrimary: Colors.white, // foreground
                            ),
                            onPressed: () {
                              confirmDeleteOrc(context, orc.ORCID);
                            },
                            child: Column(
                              children: [
                                Icon(Icons.delete_forever),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue[900], // background
                              onPrimary: Colors.white, // foreground
                            ),
                            onPressed: () {
                              showAlertDialog1(context);
                            },
                            child: Column(
                              children: [
                                Icon(Icons.delete_forever),
                              ],
                            ),
                          ),
                    Padding(padding: EdgeInsets.all(6.0)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue[900], // background
                        onPrimary: Colors.white, // foreground
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Column(
                        children: [
                          Icon(Icons.cancel),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(6.0)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue[900], // background
                        onPrimary: Colors.white, // foreground
                      ),
                      onPressed: () {
                        Cliente cli = Cliente(
                            nomeFantasia: orc.CLINOMEFANTASIA,
                            razao: orc.CLINOMERAZAO,
                            cpf_cnpj: orc.CLICPF);
                        Vendedor ven = Vendedor();
                        ven.VENDNOME = orc.VENNOME;
                        ven.VENDTEL = orc.FONEVEND;
                        String obs =
                            "${orc.ORCFORMAPAGAMENTOTXT}\n${orc.ORCOBS} ";
                        GeneratePDFState pdf = GeneratePDFState(
                            cliente: cli,
                            vendedor: ven,
                            data: orc.ORCDATA,
                            empresa: empresa,
                            formaPagamento: orc.ORCFORMAPAGAMENTOTXT,
                            hora: orc.ORCHORA,
                            obsOrcamento: obs,
                            total: orc.ORCVALORTOTAL,
                            orcid: orc.ORCID,
                            produtos: produtos,
                            totalDesconto: desconto,
                            valorTotal: orc.ORCVALORTOTAL + desconto);

                        pdf.generatePDFInvoice2();
                      },
                      child: Column(
                        children: [
                          Icon(Icons.print),
                        ],
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );

    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  Future<String> _deleteOrcamento(int orcid) async {
    await http.get(
        Uri.encodeFull(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/deleteORC.php?orcid=${orcid}&usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}"),
        headers: {"Accept": "application/json"});
  }

  Future<String> voltarEstoqueProduto(
      int proid, int corid, int tamid, int empid, double qtd) async {
    final result = await http.post(
        'http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/voltarEstoque.php?qtd=${qtd}&proid=${proid}&corid=${corid}&tamid=${tamid}&empid=${empid}',
        body: c.toJson());

    if (result.statusCode == 200) {
      print("retornou o estoque do produto $proid");

      return result.body;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
  }

  void recuperarPermissoes() {
    if (Provider.of<Especifica>(context).especifica != null) {
      especifica = Provider.of<Especifica>(context).especifica;
    }
  }

  delete(int orcid) async {
    _deleteOrcamento(orcid).then((sucess) => {
          Fluttertoast.showToast(
              msg: "Orçamento excluido com sucesso!",
              backgroundColor: Colors.blue[900],
              textColor: Colors.white,
              fontSize: 16.0),
          Navigator.of(context, rootNavigator: true).pop(),
          Navigator.of(context, rootNavigator: true).pop(),
          Navigator.of(context).pop(),
        });
  }

  Future<void> _showMyDialog() async {
    getProdutosOrc(orc.ORCID);
    String data;
    data = DateFormat("dd-MM-yyyy").format(DateTime.parse("${orc.ORCDATA}"));
    return showDialog(
        context: context,
        builder: (_) => Padding(
              padding: EdgeInsets.only(left: 0.0, right: 50.0),
              child: Dialog(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: RichText(
                            text: TextSpan(
                              text: 'ORCID: ',
                              style: TextStyle(color: Colors.grey[700]),
                              children: <TextSpan>[
                                TextSpan(
                                  text: orc.ORCID.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  //recognizer: _longPressRecognizer,
                                ),
                                TextSpan(text: ' DATA: ', children: <TextSpan>[
                                  TextSpan(
                                      text: data,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  TextSpan(
                                      text: " " + orc.ORCHORA,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ]),
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
                elevation: 0.0,
                backgroundColor: Colors.transparent,
              ),
            ));
  }

  _dados(dados) {
    pedido.VENID = int.parse(dados['VENDID']);
    pedido.CLIID = int.parse(dados['CLIID']);

    return this.pedido;
  }

  _orcamentoOBJ(dados) {
    return orc = new Orcamento(
        ORCID: int.parse(dados[0]['ORCID']),
        CLIID: int.parse(dados[0]['CLIID']),
        VENID: int.parse(dados[0]['VENID']),
        EMPID: int.parse(dados[0]['EMPID']),
        VENNOME: dados[0]['VENNOME'],
        CLINOMERAZAO: dados[0]['CLINOMERAZAO'],
        CLINOMEFANTASIA: dados[0]['CLINOME'],
        ORCDATA: dados[0]['ORCDATA'],
        ORCHORA: dados[0]['ORCHORA'],
        ORCVALORTOTAL: double.parse(dados[0]['ORCVALORTOTAL']),
        ORCFORMAPAGAMENTOTXT: dados[0]['ORCFORMAPAGAMENTOTXT'],
        ORCOBS2: dados[0]['ORIDESCONTO'],
        ORCOBS: dados[0]['ORCOBS2'],
        CLICPF: dados[0]['CLICPF'],
        FONEVEND: dados[0]['VENFONE01']);
  }

  Future<String> _mostrarPedido(int pedid) async {
    final result = await http.post(
        'http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/mostrarPedido.php?pedid=${pedid}',
        body: c.toJson());

    if (result.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      var obj = convert.json.decode(result.body);

      pedidos = obj['result'];

      pedido = _dados(pedidos);

      _showMyDialog();
      return result.body;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
  }

  Future getData(String busca, String orcid) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Charset': 'utf-8'
    };

    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/pedidos.php?busca=${busca}&orcid=${orcid}&vendid=${idVend}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var message = obj['message'];

    if (message == "Dados incorretos!") {
      showAlertSem(context);
    }

    setState(() {
      orcamentos = obj['result'];
    });

    return obj['result'];
  }

  confirmDeleteOrc(BuildContext context, int orcid) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.white, // background
        onPrimary: Colors.blue[900],
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
      child: Column(
        children: [
          Icon(Icons.cancel),
          Text('Cancelar'),
        ],
      ),
    );
    Widget continueButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.white, // background
        onPrimary: Colors.blue[900], // foreground
      ),
      onPressed: () {
        delete(orcid);
      },
      child: Column(
        children: [
          Icon(Icons.delete_forever),
          Text('Excluir'),
        ],
      ),
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Excluir Orçamento: ${orcid}"),
      content: Text("Tem certeza que deseja excluir o orçamento selecionado?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<List> buscarProdid(String proid, String empid) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    };

    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/buscarProdutoId.php?proid=${proid}&empid=${empid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (msg == "Dados incorretos!") {
    } else {
      var dados = obj['result'];

      List list = dados;

      return list;
    }
  }

  Future getOrcamentos(int orcid) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Charset': 'utf-8'
    };

    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/buscarOrcamento.php?orcid=${orcid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);

    setState(() {
      resulOrcamentos = obj['result'];
    });

    var dados = obj['result'];

    setState(() {
      orcstatus = dados[0]['ORCSTATUS'];
    });

    orc = _orcamentoOBJ(dados);

    valoDesconto = dados[0]['ORCOBS'];

    print("result orcamentos teste: " + resulOrcamentos.toString());

    produtos.clear();
    desconto = 0.0;
    for (int i = 0; i < resulOrcamentos.length; i++) {
      Produto prod = Produto();
      prod.PROID = int.parse(resulOrcamentos[i]['PROID']);
      prod.PROREFERENCIA = resulOrcamentos[i]['PROREFERENCIA'];
      prod.PRONOME = resulOrcamentos[i]['PRONOME'];
      prod.PROVALOR = double.parse(resulOrcamentos[i]['ORIVALOR']);
      prod.quantity = double.parse(resulOrcamentos[i]['ORIQTD']);
      prod.PROVALORDESCONTO = double.parse(resulOrcamentos[i]['ORIDESCONTO']);
      prod.COR = resulOrcamentos[i]['CORNOME'];
      prod.corid = int.parse(resulOrcamentos[i]['CORID']);
      prod.TAMANHO = resulOrcamentos[i]['TAMNOME'];
      prod.tamid = int.parse(resulOrcamentos[i]['TAMID']);
      prod.PROOBS = resulOrcamentos[i]['ORIOBS'];
      prod.dados = await buscarProdid(
          resulOrcamentos[i]['PROREFERENCIA'], resulOrcamentos[i]['EMPID']);

      desconto += prod.PROVALORDESCONTO;

      produtos.add(prod);
    }

    print(produtos);

    if (produtos.isNotEmpty) {
      show();
    }

    return obj['result'];
  }

  Future getProdutosOrc(int orcid) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Charset': 'utf-8'
    };

    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/mostrarItens.php?orcid=${orcid}"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);

      setState(() {
        produtosOrc = obj['result'];
      });

      return obj['result'];
    } catch (e) {
      print("orcamentos nao encontrados");
    }
  }
}
