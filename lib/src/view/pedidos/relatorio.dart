import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/empresaModel.dart';
import 'package:flutteraplicativo/src/models/vendedor.dart';
import 'package:flutteraplicativo/src/models/verdedorProvider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'dart:convert' as convert;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' show get;

import 'package:provider/provider.dart';

Directory _appDocsDir;

extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) =>
      this.toLowerCase().contains(secondString.toLowerCase());
}

class Relatorio extends StatefulWidget {
  String opcao = "";
  @override
  _RelatorioState createState() => _RelatorioState();
}

class _RelatorioState extends State<Relatorio> {
  Future funcao;
  String dropdownvalue = 'Com Dados Vendedor e Contato';
  bool _value = false;
  String nomeCliente = 'Nome Fantasia';
  TextEditingController controller = TextEditingController(text: "120");
  String semFinanceiro = 'SIM';
  String ordPor = 'DATA';
  int val = -1;
  var dados;
  String searchString = "";
  TextEditingController searchController;
  List orcItens = [];
  List listRelatorioVend = [];
  DateTime _dateTime;
  String _dateformat;
  DateTime _dateTime2;
  DateTime now = new DateTime.now();
  DateTime _dateTimeHoje;
  List vendedores = [];
  String _dateformat2;
  String _dateHoje;
  Empresa empresa = Empresa();
  List clientes = [];
  int empid = 0;
  Conexao c = Conexao();
  List<bool> _isChecked;
  List<bool> _isChecked2;
  Future _future;
  String _horaAtual;
  Future _futureVend;
  List listCli = [];
  List listVend = [];
  var result;
  List orcamentosCli = [];
  List results = [];
  Vendedor v = Vendedor();
  bool filtro = false;
  // List of items in our dropdown menu
  var filtros = [
    'Com Dados Vendedor e Contato',
    'Previsão de Pedidos de Cliente'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text("Relatório Orçamento"),
        centerTitle: true,
      ),
      body: _body(),
    );
  }

  @override
  void initState() {
    _dateTime = DateTime.now();
    _dateformat = DateFormat('dd/MM/yyyy').format(_dateTime);
    _dateTime2 = DateTime.now();
    _dateformat2 = DateFormat('dd/MM/yyyy').format(_dateTime2);
    _dateTimeHoje = DateTime.now();
    _dateHoje = DateFormat('dd/MM/yyyy').format(_dateTimeHoje);
    _horaAtual = DateFormat.jms('pt_br').format(now);
    recuperarConexao();

    super.initState();
  }

  Future buscaRelatorioVend(
      String venid, String dataIni, String dataFinal, String filtro) async {
    if (filtro == "Nome Fantasia") {
      setState(() {
        filtro = "clinome";
      });
    } else {
      setState(() {
        filtro = "clinomerazao";
      });
    }
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/relatorio/previsao.php?venid=${venid}&dataInicial=${dataIni}&dataFinal=${dataFinal}&filtro=${filtro}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);

    print(filtro);

    if (obj['code'] == 1) {
      listRelatorioVend.add(obj['result'][0]);
    } else {
      print("sem dados");
    }
  }

  vendedorLogado() {
    if (Provider.of<VendedorProvider>(context, listen: false).vendedor !=
        null) {
      v = Provider.of<VendedorProvider>(context, listen: false).vendedor;

      if (c.bdname != null) {
        _future = getData();
        _futureVend = getDataVendedores();
      }
    }
  }

  void recuperarEmpid() {
    if (Provider.of<Empresa>(context).empresa != null) {
      empid = Provider.of<Empresa>(context).empresa.EMPID;
      empresa = Provider.of<Empresa>(context).empresa;
    }
  }

  @override
  void didChangeDependencies() {
    recuperarEmpid();
    vendedorLogado();

    super.didChangeDependencies();
  }

  void recuperarConexao() async {
    List list = await DBProvider.db.getAllConexaos();

    if (list.isNotEmpty) {
      c = await DBProvider.db.getConexao(1);

      _future = getData();
      _futureVend = getDataVendedores();
    }
  }

  Future orcamentoCliente(int cliid, int venid, String datainicial,
      String datafinal, int status) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/orcamentosPeriodo.php?cliid=${cliid}&venid=${venid}&datainicial=${datainicial}&datafinal=${datafinal}&status=${status}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);

    if ("Dados incorretos!" == "") {
      return;
    } else {
      orcItens = obj['result'];

      if (orcItens == null) {
        return;
      } else {
        for (int i = 0; i < orcItens.length; i++) {
          results.add(orcItens[i]);
        }
      }
    }
  }

  Future getDataVendedores() async {
  

    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/vendedores/buscarVendedores.php?idCliente=${empid}"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);
      print(obj);
      setState(() {
        vendedores = obj['result'];
      });

      _isChecked2 = List<bool>.filled(vendedores.length, false);

      return obj['result'];
    } catch (e) {
      print("error");
    }
  }

  Future getData() async {
    _dateformat = DateFormat('yyyy-MM-dd').format(_dateTime);

    _dateformat2 = DateFormat('yyyy-MM-dd').format(_dateTime2);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Charset': 'utf-8'
    };

    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/clientes/clientesRelatorio.php?venid=${v.VENDID}&empid=${empid}&datainicial=${_dateformat}&datafinal=${_dateformat2}"),
      body: c.toJson());

    var obj = convert.json.decode(response.body);

    if (mounted) {
      setState(() {
        clientes = obj['result'];

        if (clientes != null) {
          if (clientes.isNotEmpty) {
            _dateformat = DateFormat('dd/MM/yyyy').format(_dateTime);

            _dateformat2 = DateFormat('dd/MM/yyyy').format(_dateTime2);
          }

          _isChecked = List<bool>.filled(clientes.length, false);
        } else {
          _dateformat = DateFormat('dd/MM/yyyy').format(_dateTime);

          _dateformat2 = DateFormat('dd/MM/yyyy').format(_dateTime2);
        }
      });
    }

    return obj['result'];
  }

  _body() {
    return SingleChildScrollView(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
        child: SizedBox(
            width: 380,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all()),
              child: Column(
                children: [
                  SizedBox(
                      width: 380,
                      height: 50,
                      child: Container(
                        child: Center(
                          child: Text(
                            "Relatórios",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[900],
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              topLeft: Radius.circular(8)),
                          border: Border.all(),
                        ),
                      )),
                  SizedBox(
                      width: 380,
                      height: 55,
                      child: Container(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 15,
                                        onPrimary: Colors.black,
                                        primary: Colors.grey,
                                      ),
                                      onPressed: () {
                                        if (filtro == true) {
                                          setState(() {
                                            if (listVend.length ==
                                                vendedores.length) {
                                              for (int i = 0;
                                                  i < vendedores.length;
                                                  i++) {
                                                listVend.remove(
                                                    vendedores[i]['VENID']);
                                                _isChecked2[i] = false;
                                              }

                                              return;
                                            }

                                            if (listVend.isNotEmpty) {
                                              listVend.clear();
                                            }

                                            for (int i = 0;
                                                i < vendedores.length;
                                                i++) {
                                              listVend
                                                  .add(vendedores[i]['VENID']);
                                              _isChecked2[i] = true;
                                            }
                                          });
                                        } else {
                                          setState(() {
                                            if (listCli.length ==
                                                clientes.length) {
                                              for (int i = 0;
                                                  i < clientes.length;
                                                  i++) {
                                                listCli.remove(
                                                    clientes[i]['CLIID']);
                                                _isChecked[i] = false;
                                              }

                                              return;
                                            }

                                            if (listCli.isNotEmpty) {
                                              listCli.clear();
                                            }

                                            for (int i = 0;
                                                i < clientes.length;
                                                i++) {
                                              listCli.add(clientes[i]['CLIID']);
                                              _isChecked[i] = true;
                                            }
                                          });
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.fact_check_outlined,
                                            color: Colors.green[900],
                                          ),
                                          Text(
                                            'Todos',
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(4.0)),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 15,
                                        onPrimary: Colors.black,
                                        primary: Colors.grey,
                                      ),
                                      onPressed: () async {
                                        if (filtro == true) {
                                          if (listVend.isEmpty) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Nenhum vendedor selecionado!");
                                          } else {
                                            _dateformat =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(_dateTime);

                                            _dateformat2 =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(_dateTime2);

                                            for (int i = 0;
                                                i < listVend.length;
                                                i++) {
                                              await buscaRelatorioVend(
                                                  listVend[i],
                                                  _dateformat,
                                                  _dateformat2,
                                                  nomeCliente);
                                            }

                                            if (listRelatorioVend.isNotEmpty) {
                                              RelatorioPDFPrevisaoState rel =
                                                  RelatorioPDFPrevisaoState(
                                                      orcamentos:
                                                          listRelatorioVend,
                                                      empresa: empresa,
                                                      dataIni: _dateformat,
                                                      dataFinal: _dateformat2,
                                                      dataHoje: _dateHoje,
                                                      hora: _horaAtual);

                                              await rel.generatePDFInvoice();

                                              setState(() {
                                                _dateformat =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(_dateTime);

                                                _dateformat2 =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(_dateTime2);
                                              });

                                              listRelatorioVend.clear();
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Nenhum orçamento encontrado!",
                                                  fontSize: 18);
                                            }
                                          }
                                        } else {
                                          if (listCli.isEmpty) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                // retorna um objeto do tipo Dialog
                                                return AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  title: new Text(
                                                    "Error: Nenhum cliente selecionado!",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  content: new Text(
                                                      "Selecione no mínimo 1 cliente para continuar!",
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                  actions: <Widget>[
                                                    // define os botões na base do dialogo
                                                    new ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors.blue[
                                                                        900]),
                                                      ),
                                                      child: new Text("Fechar"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                          if (result != null) {
                                            _dateformat =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(_dateTime);

                                            _dateformat2 =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(_dateTime2);

                                            if (results.isEmpty) {
                                              for (int i = 0;
                                                  i < listCli.length;
                                                  i++) {
                                                await orcamentoCliente(
                                                    int.parse(listCli[i]),
                                                    v.VENDID,
                                                    _dateformat,
                                                    _dateformat2,
                                                    result['status']);
                                              }
                                            }

                                            if (results.isEmpty) {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  // retorna um objeto do tipo Dialog
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    title: new Text(
                                                      "Error: Nenhum orçamento à ser informado!",
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                    content: new Text(
                                                        "Verifique se realmente possui orçamentos no periodo informado!",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black)),
                                                    actions: <Widget>[
                                                      // define os botões na base do dialogo
                                                      new ElevatedButton(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(
                                                                      Colors.blue[
                                                                          900]),
                                                        ),
                                                        child:
                                                            new Text("Fechar"),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            } else {
                                              RelatorioPDFState rel =
                                                  RelatorioPDFState(
                                                      orcamentos: results,
                                                      empresa: empresa);

                                              rel.generatePDFInvoice();
                                            }
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                // retorna um objeto do tipo Dialog
                                                return AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  title: new Text(
                                                    "Error: Nenhum opção selecionada!",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  content: new Text(
                                                      "Selecione uma opção abaixo para continuar! \n \nOrçamentos Abertos, fechados ou todos",
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                  actions: <Widget>[
                                                    // define os botões na base do dialogo
                                                    new ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors.blue[
                                                                        900]),
                                                      ),
                                                      child: new Text("Fechar"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          Icon(Icons.view_list_outlined),
                                          Text(
                                            'Visualizar',
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(4.0)),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 15,
                                        onPrimary: Colors.black,
                                        primary: Colors.grey,
                                      ),
                                      onPressed: () {},
                                      child: Column(
                                        children: [
                                          Icon(Icons.print_sharp),
                                          Text(
                                            'imprimir',
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        decoration: BoxDecoration(color: Colors.grey),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Column(
                            children: <Widget>[
                              Text(
                                _dateTime == null
                                    ? 'Data Inicial'
                                    : "Data Inicial",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              FlatButton(
                                child: Text(
                                  _dateformat,
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 18,
                                      decoration: TextDecoration.underline),
                                ),
                                onPressed: () {
                                  showDatePicker(
                                          context: context,
                                          initialDate: _dateTime == null
                                              ? DateTime.now()
                                              : _dateTime,
                                          firstDate: DateTime(2001),
                                          lastDate: DateTime.now())
                                      .then((date) {
                                    setState(() {
                                      initializeDateFormatting('pt_br');
                                      _dateTime = date;
                                      _dateformat = DateFormat('dd/MM/yyyy')
                                          .format(_dateTime);

                                      getData();
                                    });
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            children: <Widget>[
                              Text(
                                _dateTime == null ? 'Data Final' : "Data Final",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              FlatButton(
                                child: Text(
                                  _dateformat2,
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 18,
                                      decoration: TextDecoration.underline),
                                ),
                                onPressed: () {
                                  showDatePicker(
                                          context: context,
                                          initialDate: _dateTime2 == null
                                              ? DateTime.now()
                                              : _dateTime2,
                                          firstDate: DateTime(2001),
                                          lastDate: DateTime(2030))
                                      .then((date) {
                                    setState(() {
                                      initializeDateFormatting('pt_br');
                                      _dateTime2 = date;
                                      _dateformat2 = DateFormat('dd/MM/yyyy')
                                          .format(_dateTime2);
                                      getData();
                                    });
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 10,
                    color: Colors.black,
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  Padding(
                    padding: const EdgeInsets.only(right: 8, left: 8),
                    child: SizedBox(
                      height: 75,
                      width: 350,
                      child: Container(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'RELATÓRIOS',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 50),
                                  child: SizedBox(
                                    width: 340,
                                    child: DropdownButton(
                                      value: dropdownvalue,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: filtros.map((String items) {
                                        return DropdownMenuItem(
                                          value: items,
                                          child: Text(items),
                                        );
                                      }).toList(),
                                      onChanged: (String newValue) {
                                        if (newValue ==
                                            "Previsão de Pedidos de Cliente") {
                                          setState(() {
                                            filtro = true;
                                          });
                                        } else {
                                          setState(() {
                                            filtro = false;
                                          });
                                        }
                                        setState(() {
                                          dropdownvalue = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  filtro == false
                      ? Padding(
                          padding: const EdgeInsets.only(right: 8, left: 8),
                          child: SizedBox(
                              width: 350,
                              height: 200,
                              child: SingleChildScrollView(
                                child: Container(
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'CLIENTES',
                                      labelStyle: TextStyle(fontSize: 18.0),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: SingleChildScrollView(
                                      physics: ScrollPhysics(),
                                      child: Column(
                                        children: [
                                          Container(
                                            child: TextField(
                                              controller: searchController,
                                              onChanged: (value) {
                                                setState(() {
                                                  searchString = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: "Buscar Clientes",
                                                prefixIcon: Icon(Icons.search),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.all(10.0)),
                                          Container(
                                            child: clientes == null
                                                ? Text(
                                                    "Nenhum orçamento com clientes")
                                                : ListView.builder(
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return clientes[index][
                                                                  "CLINOMERAZAO"]
                                                              .toString()
                                                              .containsIgnoreCase(
                                                                  searchString)
                                                          ? SizedBox(
                                                              width: 500,
                                                              height: 70,
                                                              child: Card(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Checkbox(
                                                                          value:
                                                                              _isChecked[index],
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              _isChecked[index] = value;
                                                                            });

                                                                            if (_isChecked[index] ==
                                                                                true) {
                                                                              listCli.add(clientes[index]['CLIID']);
                                                                            } else {
                                                                              listCli.remove(clientes[index]['CLIID']);
                                                                            }
                                                                          },
                                                                        ),
                                                                        Flexible(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              Text(
                                                                            "${clientes[index]['CLIID']} - ${clientes[index]['CLINOMERAZAO']}",
                                                                            style:
                                                                                TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : Container();
                                                    },
                                                    itemCount: clientes.length,
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(right: 8, left: 8),
                          child: Container(
                              child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'VENDEDORES',
                              labelStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: SingleChildScrollView(
                              physics: ScrollPhysics(),
                              child: Column(
                                children: [
                                  Container(
                                    child: TextField(
                                      controller: searchController,
                                      onChanged: (value) {
                                        setState(() {
                                          searchString = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Buscar Vendedores",
                                        prefixIcon: Icon(Icons.search),
                                      ),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.all(10.0)),
                                  Container(
                                    child: vendedores == null
                                        ? Text("Nenhum Vendedor")
                                        : ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return vendedores[index]
                                                          ["VENNOME"]
                                                      .toString()
                                                      .containsIgnoreCase(
                                                          searchString)
                                                  ? SizedBox(
                                                      width: 500,
                                                      height: 70,
                                                      child: Card(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Checkbox(
                                                                  value:
                                                                      _isChecked2[
                                                                          index],
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      _isChecked2[
                                                                              index] =
                                                                          value;
                                                                    });

                                                                    if (_isChecked2[
                                                                            index] ==
                                                                        true) {
                                                                      listVend.add(
                                                                          vendedores[index]
                                                                              [
                                                                              'VENID']);
                                                                    } else {
                                                                      listVend.remove(
                                                                          vendedores[index]
                                                                              [
                                                                              'VENID']);
                                                                    }
                                                                  },
                                                                ),
                                                                Flexible(
                                                                  flex: 1,
                                                                  child: Text(
                                                                    "${vendedores[index]['VENID']} - ${vendedores[index]['VENNOME']}",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : Container();
                                            },
                                            itemCount: vendedores.length,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  filtro == true
                      ? Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, bottom: 10),
                                    child: SizedBox(
                                        child: Container(
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'NOME CLIENTE',
                                          labelStyle: TextStyle(fontSize: 18.0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        child: Container(
                                            child: DropdownButton<String>(
                                          value: nomeCliente,
                                          icon:
                                              const Icon(Icons.arrow_downward),
                                          elevation: 16,
                                          style: const TextStyle(
                                              color: Colors.deepPurple),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.deepPurpleAccent,
                                          ),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              nomeCliente = newValue;
                                            });
                                          },
                                          items: <String>[
                                            'Nome Fantasia',
                                            'Razão Social'
                                          ].map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        )),
                                      ),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, bottom: 10),
                                    child: SizedBox(
                                        child: Container(
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'ORDENAR POR',
                                          labelStyle: TextStyle(fontSize: 18.0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        child: Container(
                                            child: DropdownButton<String>(
                                          value: ordPor,
                                          icon:
                                              const Icon(Icons.arrow_downward),
                                          elevation: 16,
                                          style: const TextStyle(
                                              color: Colors.deepPurple),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.deepPurpleAccent,
                                          ),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              ordPor = newValue;
                                            });
                                          },
                                          items: <String>[
                                            'DATA',
                                            'Cliente',
                                          ].map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        )),
                                      ),
                                    )),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, bottom: 10),
                                    child: SizedBox(
                                        child: Container(
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'SEM FINANCEIRO',
                                          labelStyle: TextStyle(fontSize: 18.0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        child: Container(
                                            child: DropdownButton<String>(
                                          value: semFinanceiro,
                                          icon:
                                              const Icon(Icons.arrow_downward),
                                          elevation: 16,
                                          style: const TextStyle(
                                              color: Colors.deepPurple),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.deepPurpleAccent,
                                          ),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              semFinanceiro = newValue;
                                            });
                                          },
                                          items: <String>['SIM', 'NÃO']
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        )),
                                      ),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, bottom: 10),
                                    child: SizedBox(
                                        child: Container(
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'NOS ÚLTIMOS',
                                          labelStyle: TextStyle(fontSize: 18.0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        child: Container(
                                          child: TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: controller,
                                              decoration: InputDecoration(
                                                  labelText: 'Dias',
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            width: 3,
                                                            color: Colors.blue),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ))),
                                        ),
                                      ),
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 10),
                          child: SizedBox(
                              width: 375,
                              height: 136,
                              child: Container(
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'ORÇAMENTOS',
                                    labelStyle: TextStyle(fontSize: 18.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Radio(
                                            value: 0,
                                            groupValue: val,
                                            onChanged: (value) {
                                              setState(() {
                                                val = value;
                                                result = {
                                                  "status": value,
                                                  "nome": "Abertos"
                                                };
                                              });
                                            },
                                            activeColor: Colors.blue[900],
                                          ),
                                          Text(
                                            "Abertos",
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 20)),
                                          Radio(
                                            value: 2,
                                            groupValue: val,
                                            onChanged: (value) {
                                              setState(() {
                                                val = value;
                                                result = {
                                                  "status": value,
                                                  "nome": "Todos"
                                                };
                                              });

                                              print(result);
                                            },
                                            activeColor: Colors.blue[900],
                                          ),
                                          Text(
                                            "Todos",
                                            style: TextStyle(fontSize: 18.0),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio(
                                            value: 1,
                                            groupValue: val,
                                            onChanged: (value) {
                                              setState(() {
                                                val = value;
                                                result = {
                                                  "status": value,
                                                  "nome": "Fechados"
                                                };
                                              });

                                              print(result);
                                            },
                                            activeColor: Colors.blue[900],
                                          ),
                                          Text(
                                            "Fechados",
                                            style: TextStyle(fontSize: 18.0),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ),
                ],
              ),
            )),
      ),
    );
  }
}

class RelatorioPDF extends StatefulWidget {
  @override
  State<RelatorioPDF> createState() => new RelatorioPDFState();
}

class RelatorioPDFState extends State<RelatorioPDF> {
  List orcamentos;
  var image;
  Empresa empresa;
  double total = 0.0;

  RelatorioPDFState({@required this.orcamentos, this.empresa});
  int count = 0;
  @override
  void initState() {
    orcamentos.sort((a, b) => a["ORCID"].compareTo(b["ORCID"]));

    print(orcamentos);
    super.initState();
  }

  File fileFromDocsDir(String filename) {
    String pathName = p.join(_appDocsDir.path, filename);
    return File(pathName);
  }

  generatePDFInvoice() async {
    String msg = "";
    totalOrc();

    if (empresa.LOGOMARCA == null || empresa.LOGOMARCA == "") {
      image = await networkImage(
          'https://igp.rs.gov.br/themes/modelo-noticias/images/outros/GD_imgSemImagem.png');
    } else {
      image = await networkImage(empresa.LOGOMARCA);
    }

    Uint8List _pdfTextByte;
    final pw.Document doc = pw.Document();
    final pw.Font customFont =
        pw.Font.ttf((await rootBundle.load('assets/fonts/Helvetica.ttf')));

    try {
      doc.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
              margin: pw.EdgeInsets.zero,
              theme: pw.ThemeData(
                  defaultTextStyle: pw.TextStyle(font: customFont))),
          header: _buildHeader,
          footer: _buildPrice,
          build: (context) => _buildContent(context),
        ),
      );
    } on NetworkImageLoadException {
      image = await flutterImageProvider(NetworkImage(
        "http://crtsistemas.com.br/crt_mobile_flutter/logoEmpresa/semimagem.bmp",
      ));
    }

    _pdfTextByte = await doc.save();

    if (_pdfTextByte.length > 0) {
      openFileBytesForMobile(_pdfTextByte);
    }
  }

  static void openFileBytesForMobile(List<int> bytes) async {
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/relatorio.pdf");
    await file.writeAsBytes(bytes);
    OpenFile.open(file.path);
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Container(
        color: PdfColors.blue900,
        height: 200,
        child: pw.Padding(
            padding: pw.EdgeInsets.all(16),
            child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.SizedBox(
                            width: 100,
                            height: 100,
                            child: pw.Container(
                                child: pw.Center(
                              child: pw.Image(image),
                            ))),
                      ]),
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(right: 200, bottom: 20),
                        child: pw.Text("Relatório orçamentos",
                            style: pw.TextStyle(
                                fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Flexible(
                        child: pw.Text('${empresa.EMPNOMEFANTASIA}',
                            style: pw.TextStyle(
                                fontSize: 14, color: PdfColors.white)),
                      ),
                      pw.Text('${empresa.EMPCNPJ}',
                          style: pw.TextStyle(
                              fontSize: 14, color: PdfColors.white)),
                      pw.Text(
                          '${empresa.EMPENDERECO} - ${empresa.EMPBAIRRO} ${empresa.EMPCIDADE}/${empresa.EMPUF}',
                          style: pw.TextStyle(
                              fontSize: 14, color: PdfColors.white)),
                      pw.Text(
                          'CEP: ${empresa.EMPCEP} Fones: ${empresa.EMPFONE01} / ${empresa.EMPFONE02}',
                          style: pw.TextStyle(
                              fontSize: 14, color: PdfColors.white)),
                      pw.Text('${empresa.EMPEMAIL}',
                          style: pw.TextStyle(
                              fontSize: 14, color: PdfColors.white)),
                    ],
                  ),
                ])));
  }

  /// Constroi o conteúdo da página
  List<pw.Widget> _buildContent(pw.Context context) {
    return [
      pw.Padding(
          padding: pw.EdgeInsets.only(top: 8, left: 25, right: 25),
          child: _contentTable(context)),
    ];
  }

  /// Retorna um texto com formatação própria para título
  _titleText(String text) {
    return pw.Padding(
        padding: pw.EdgeInsets.only(top: 8),
        child: pw.Text(text,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)));
  }

  /// Constroi uma tabela com base nos produtos da fatura
  pw.Widget _contentTable(pw.Context context) {
    // Define uma lista usada no cabeçalho
    const tableHeaders = [
      'ORCID',
      'CLIENTE',
      'VENDEDOR',
      'TELEFONES',
      'DATA',
      'STATUS',
      'VALOR'
    ];

    return pw.Table.fromTextArray(
      border: pw.TableBorder.symmetric(inside: pw.BorderSide(width: 2)),
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(),
      headerHeight: 25,
      cellHeight: 40,
      // Define o alinhamento das células, onde a chave é a coluna
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.center,
        6: pw.Alignment.center,
      },
      // Define um estilo para o cabeçalho da tabela
      headerStyle: pw.TextStyle(
        fontSize: 10,
        color: PdfColors.blue,
        fontWeight: pw.FontWeight.bold,
      ),
      // Define um estilo para a célula
      cellStyle: const pw.TextStyle(
        fontSize: 10,
      ),
      headers: tableHeaders,
      // retorna os valores da tabela, de acordo com a linha e a coluna
      data: List<List<dynamic>>.generate(
        orcamentos.length,
        (row) => List.generate(
          tableHeaders.length,
          (col) => _getValueIndex(orcamentos[row], col),
        ),
      ),
    );
  }

  /// Retorna o valor correspondente a coluna
  String _getValueIndex(orcamento, int col) {
    switch (col) {
      case 0:
        return orcamento['ORCID'];
      case 1:
        return orcamento['CLINOMERAZAO'];
      case 2:
        return orcamento['VENNOME'];

      case 3:
        return orcamento['CLIFONE01'] == null
            ? ""
            : "${orcamento['CLIFONE01']}\n${orcamento['CLIFONE02']}";
      case 4:
        return _formatData(orcamento['ORCDATA']);

      case 5:
        return orcamento['ORCSTATUS'] == "0" ||
                orcamento['ORCSTATUS'] == "N" ||
                orcamento['ORCSTATUS'] == "A"
            ? "Aberto"
            : "Fechado";
      case 6:
        return _formatValue(double.parse(orcamento['ORCVALORTOTAL']));
    }
    return '';
  }

  /// Formata o valor informado na formatação pt/BR
  String _formatValue(double value) {
    final NumberFormat numberFormat = new NumberFormat("#,##0.00", "pt_BR");
    return numberFormat.format(value);
  }

  String _formatData(String value) {
    DateTime data = DateTime.parse(value);
    String _dateformat = DateFormat('dd/MM/yyyy').format(data);

    return _dateformat;
  }

  void MensagemLogo() {
    var alert = new AlertDialog(
      contentPadding: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
      backgroundColor: Colors.red,
      title: new Text(
        "Url da logo inválida!",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: new Text("Verifique se a empresa possui logo!",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void totalOrc() {
    double totalLog = 0.0;
    for (int i = 0; i < orcamentos.length; i++) {
      totalLog += double.parse(orcamentos[i]['ORCVALORTOTAL']);
    }

    total = totalLog;
  }

  /// Retorna o rodapé da página
  pw.Widget _buildPrice(pw.Context context) {
    return pw.Container(
      color: PdfColors.blue900,
      height: 90,
      child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Padding(
                padding: pw.EdgeInsets.only(left: 200),
                child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.only(bottom: 0),
                          child: pw.Text('VALOR TOTAL',
                              style: pw.TextStyle(
                                  fontSize: 22, color: PdfColors.white))),
                      pw.Text('R\$:  ${_formatValue(total)}',
                          style: pw.TextStyle(
                              color: PdfColors.white, fontSize: 22)),
                    ]))
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class RelatorioPDFPrevisao extends StatefulWidget {
  @override
  State<RelatorioPDFPrevisao> createState() => new RelatorioPDFPrevisaoState();
}

class RelatorioPDFPrevisaoState extends State<RelatorioPDFPrevisao> {
  List orcamentos;
  var image;
  Empresa empresa;
  String dataIni;
  String dataFinal;
  String dataHoje;
  String hora;
  double total = 0.0;

  RelatorioPDFPrevisaoState(
      {@required this.orcamentos,
      this.empresa,
      this.dataIni,
      this.dataFinal,
      this.dataHoje,
      this.hora});

  int count = 0;
  @override
  void initState() {
    super.initState();
  }

  File fileFromDocsDir(String filename) {
    String pathName = p.join(_appDocsDir.path, filename);
    return File(pathName);
  }

  _intervaloDias(String dataPrevisao, String dataUltima) {
    DateTime dataPrev = DateTime.parse(dataPrevisao);
    DateTime datault = DateTime.parse(dataUltima);

    return dataPrev.difference(datault).inDays.toString();
  }

  generatePDFInvoice() async {
    String msg = "";

    if (empresa.LOGOMARCA == null || empresa.LOGOMARCA == "") {
      image = await networkImage(
          'https://igp.rs.gov.br/themes/modelo-noticias/images/outros/GD_imgSemImagem.png');
    } else {
      image = await networkImage(empresa.LOGOMARCA);
    }

    Uint8List _pdfTextByte;
    final pw.Document doc = pw.Document();
    final pw.Font customFont =
        pw.Font.ttf((await rootBundle.load('assets/fonts/Helvetica.ttf')));

    try {
      doc.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
              margin: pw.EdgeInsets.zero,
              theme: pw.ThemeData(
                  defaultTextStyle: pw.TextStyle(font: customFont))),
          header: _buildHeader,
          footer: _buildPrice,
          build: (context) => _buildContent(context),
        ),
      );
    } on NetworkImageLoadException {
      image = await flutterImageProvider(NetworkImage(
        "http://crtsistemas.com.br/crt_mobile_flutter/logoEmpresa/semimagem.bmp",
      ));
    }

    _pdfTextByte = await doc.save();

    if (_pdfTextByte.length > 0) {
      openFileBytesForMobile(_pdfTextByte);
    }
  }

  String _formatData(String value) {
    DateTime data = DateTime.parse(value);
    String _dateformat = DateFormat('dd/MM/yyyy').format(data);

    return _dateformat;
  }

  static void openFileBytesForMobile(List<int> bytes) async {
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/relatorioPrevisao.pdf");
    await file.writeAsBytes(bytes);
    OpenFile.open(file.path);
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Container(
        color: PdfColors.blue,
        height: 150,
        child: pw.Padding(
            padding: pw.EdgeInsets.all(8),
            child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.SizedBox(
                            width: 100,
                            height: 100,
                            child: pw.Container(
                                child: pw.Center(child: pw.Image(image)))),
                      ]),
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.only(bottom: 10, right: 20),
                          child: pw.Text("Previsão de Pedidos de Cliente",
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  color: PdfColors.white,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.only(bottom: 10),
                          child: pw.Text("${_formatData(dataIni)}",
                              style: pw.TextStyle(
                                  fontSize: 16,
                                  color: PdfColors.white,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.only(bottom: 10),
                          child: pw.Text(" à ${_formatData(dataFinal)}",
                              style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                      ]),
                      pw.Row(children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.only(bottom: 10),
                          child: pw.Text("Data: $dataHoje ",
                              style: pw.TextStyle(
                                  fontSize: 16,
                                  color: PdfColors.white,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.only(bottom: 10),
                          child: pw.Text("$hora",
                              style: pw.TextStyle(
                                  fontSize: 16,
                                  color: PdfColors.white,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                      ]),
                      pw.Row(children: []),
                      pw.Flexible(
                        child: pw.Text('${empresa.EMPNOMEFANTASIA}',
                            style: pw.TextStyle(
                                fontSize: 14, color: PdfColors.white)),
                      ),
                      pw.Text('${empresa.EMPCNPJ}',
                          style: pw.TextStyle(
                              fontSize: 14, color: PdfColors.white)),
                      pw.Text(
                          '${empresa.EMPENDERECO} - ${empresa.EMPBAIRRO} ${empresa.EMPCIDADE}/${empresa.EMPUF}',
                          style: pw.TextStyle(
                              fontSize: 14, color: PdfColors.white)),
                      pw.Text(
                          'CEP: ${empresa.EMPCEP} Fones: ${empresa.EMPFONE01} / ${empresa.EMPFONE02}',
                          style: pw.TextStyle(
                              fontSize: 14, color: PdfColors.white)),
                      pw.Text('${empresa.EMPEMAIL}',
                          style: pw.TextStyle(
                              fontSize: 14, color: PdfColors.white)),
                    ],
                  ),
                ])));
  }

  /// Constroi o conteúdo da página
  List<pw.Widget> _buildContent(pw.Context context) {
    return [
      pw.Padding(
          padding: pw.EdgeInsets.only(top: 50, left: 25, right: 25),
          child: _contentTable(context)),
    ];
  }

  /// Retorna um texto com formatação própria para título
  _titleText(String text) {
    return pw.Padding(
        padding: pw.EdgeInsets.only(top: 8),
        child: pw.Text(text,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)));
  }

  /// Constroi uma tabela com base nos produtos da fatura
  pw.Widget _contentTable(pw.Context context) {
    // Define uma lista usada no cabeçalho
    const tableHeaders = [
      'CLIENTE',
      'VENDEDOR',
      'ÚLTIMA COMPRA',
      'COMPRAS',
      'VALOR MEDIO DE COMPRA',
      'INTERVALO DIAS',
      'PREVISÃO'
    ];

    return pw.Table.fromTextArray(
      border: pw.TableBorder.symmetric(outside: pw.BorderSide(width: 1)),
      cellAlignment: pw.Alignment.center,
      headerDecoration: pw.BoxDecoration(color: PdfColors.blue),

      headerAlignment: pw.Alignment.centerLeft,
      cellHeight: 20,
      tableWidth: pw.TableWidth.max,
      // Define o alinhamento das células, onde a chave é a coluna
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.center,
        6: pw.Alignment.center,
      },

      columnWidths: {
        0: pw.FixedColumnWidth(145),
        3: pw.FixedColumnWidth(100),
        5: pw.FixedColumnWidth(100),
        6: pw.FixedColumnWidth(100),
      },

      // Define um estilo para o cabeçalho da tabela
      headerStyle: pw.TextStyle(
        fontSize: 10,
        height: 20,
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
      ),
      // Define um estilo para a célula
      cellStyle: const pw.TextStyle(fontSize: 10, height: 100),
      headers: tableHeaders,
      // retorna os valores da tabela, de acordo com a linha e a coluna
      data: List<List<dynamic>>.generate(
        orcamentos.length,
        (row) => List.generate(
          tableHeaders.length,
          (col) => _getValueIndex(orcamentos[row], col),
        ),
      ),
    );
  }

  /// Retorna o valor correspondente a coluna
  String _getValueIndex(orcamento, int col) {
    switch (col) {
      case 0:
        return orcamento['clinome'];
      case 1:
        return orcamento['vennome'];
      case 2:
        return _formatData(orcamento['compra_mais_recente']);
      case 3:
        return orcamento['total_de_compras'];
      case 4:
        return "R\$ " + orcamento['valor_medio_compras'];
      case 5:
        return _intervaloDias(
            orcamento['previsao'], orcamento['compra_mais_recente']);
      case 6:
        return _formatData(orcamento['previsao']);
    }
    return '';
  }

  /// Formata o valor informado na formatação pt/BR
  String _formatValue(double value) {
    final NumberFormat numberFormat = new NumberFormat("#,##0.00", "pt_BR");
    return numberFormat.format(value);
  }

  void MensagemLogo() {
    var alert = new AlertDialog(
      contentPadding: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
      backgroundColor: Colors.red,
      title: new Text(
        "Url da logo inválida!",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: new Text("Verifique se a empresa possui logo!",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void totalOrc() {
    double totalLog = 0.0;
    for (int i = 0; i < orcamentos.length; i++) {
      totalLog += double.parse(orcamentos[i]['ORCVALORTOTAL']);
    }

    total = totalLog;
  }

  /// Retorna o rodapé da página
  pw.Widget _buildPrice(pw.Context context) {
    return pw.Container(
      color: PdfColors.blue,
      height: 130,
      child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Padding(
                padding: pw.EdgeInsets.only(left: 200),
                child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.only(bottom: 0),
                          child: pw.Text(
                              'Total de Clientes: ${orcamentos.length}',
                              style: pw.TextStyle(
                                  fontSize: 22, color: PdfColors.white))),
                    ]))
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
