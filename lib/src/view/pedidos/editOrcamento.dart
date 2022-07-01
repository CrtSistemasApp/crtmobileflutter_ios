import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutteraplicativo/src/models/configEspe.dart';
import 'package:flutteraplicativo/src/models/configuracoes.dart';
import 'package:flutteraplicativo/src/view/pedidos/cadastroOrcamento.dart';
import 'package:flutteraplicativo/src/view/pedidos/mostrarOrcamentos.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as p;
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/configProvider.dart';
import 'package:flutteraplicativo/src/models/empresaModel.dart';
import 'package:flutteraplicativo/src/models/formasModel.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutteraplicativo/src/models/cliente.dart';
import 'package:flutteraplicativo/src/models/clienteProvider.dart';
import 'package:flutteraplicativo/src/models/orcamento.dart';
import 'package:flutteraplicativo/src/models/produtoProvider.dart';
import 'package:flutteraplicativo/src/models/produtos.dart';

import 'package:flutteraplicativo/src/models/vendedor.dart';
import 'package:flutteraplicativo/src/models/verdedorProvider.dart';
import 'package:flutteraplicativo/src/view/pedidos/orcamentoHome.dart';
import 'package:flutteraplicativo/src/view/produtos/catalogProdutos.dart';

import 'dart:convert' as convert;
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

class EditOrcamento extends StatefulWidget {
  Vendedor vend;
  Cliente cli;
  List<Produto> list;
  Orcamento orc;
  String forma = "Forma De Pagamento";
  String condPagamento = "Cond/Pagamento";
  String desconto = "Tipo Desconto";
  String cor = "Selecione a Cor";
  String grade = "Selecione o Tamanho";
  String valorVenda = "Vr.Venda";
  EditOrcamento(
      {Key key,
      @required this.vend,
      @required this.cli,
      @required this.list,
      @required this.orc})
      : super(key: key);

  @override
  EditOrcamentoState createState() => EditOrcamentoState();
}

class EditOrcamentoState extends State<EditOrcamento>
    with SingleTickerProviderStateMixin {
  SizeConfig sized = SizeConfig();
  bool enabledEdit = true;
  bool initialTela = true;
  Orcamento orc = Orcamento();
  TabController _tabController;
  bool semGrade = false;
  int FPGTIPO = 0;
  ConfiguracoesModel configuracoesModel = ConfiguracoesModel();
  double qtdMax = 0.000;
  double qtdMaxEst = 0.000;
  List formasPagamento = [];
  List listaDebitos = [];
  double percentualMax = 0.0;
  int idGrade = 0;
  bool resetDesconto = false;
  bool recuperouCli = false;
  double total2 = 0.0;
  FocusNode focusNodeRef;
  FocusNode focusNodeCli;
  FocusNode focusNodeObs;
  String nomeGrade = "PADRAO";
  List valoresProd = [];
  List valoresVenda = [];
  int idCor = 0;
  double desconto = 0.0;
  double estoquePro = 0.0;
  bool semEstoque = false;
  bool selected = false;
  List resulOrcamentos;
  List<Produto> produtos = [];
  String orcstatus = "";
  List<Produto> listReside = [];
  String nomeCor = "PADRAO";
  List gradeList = [];
  List corList = [];
  List tamcores = [];
  List cores = [];
  int idProd = 0;
  List tamanhos = [];
  double qtdResid = 0.0;
  double percentualMax2 = 0.0;
  double slider = 0.0;
  String formaNome = "";
  bool temGrade = false;
  List<String> itensMenu = ["Ajuda", "Sair"];
  TextEditingController controlprod = TextEditingController();
  TextEditingController controlOrcObs = TextEditingController();
  TextEditingController controlQtd = TextEditingController(text: '1');
  TextEditingController controllerVendNome = TextEditingController();
  TextEditingController controllerVendId = TextEditingController();
  TextEditingController controllerClienteNome = TextEditingController();
  TextEditingController controllerClienteId = TextEditingController();
  TextEditingController controlProdNome = TextEditingController();
  TextEditingController controlProdId = TextEditingController();
  TextEditingController controlProdObs = TextEditingController();
  TextEditingController controlProdDesc = TextEditingController();
  TextEditingController controlProdValor = TextEditingController(text: "0.0");
  TextEditingController controlProdValorCusto = TextEditingController();
  TextEditingController formaPagamento =
      TextEditingController(text: "Nenhuma forma selecionada");
  TextEditingController controlPorcen = TextEditingController();
  TextEditingController controlNull;
  TextEditingController descontoControl = TextEditingController(text: "0.0");
  GlobalKey _scaffold = GlobalKey();
  TextEditingController controlParcelas = TextEditingController(text: "0");
  List tipoDocumento = [];
  List produtosList = [];
  List vendedoresList = [];
  List clientesList = [];
  List orcamentos = [];
  int count = 0;
  String _myProd;
  String _myVend;
  String _myCliente;
  int orcid;
  double resultqtd = 0.0;
  int idrecup = 0;
  String opcaoItem = "";
  String opcaoTotal = "";
  int locidemp = 0;
  ConfigProvider config = ConfigProvider();
  OrcamentoItem pedItem;
  String generatedPdfFilePath;
  DateTime selectedDate = DateTime.now();
  Future<Produto> futureProd;
  Future _future;
  Future _orcamentos;
  Future _getPedido;
  Future _futureVend;
  double valorD = 0.0;
  int indexEdit = 0;
  int idProdEdit = 0;
  Future _futureCli;
  String razaosocial;
  String cpf_cnpj;
  Future _selectCliente;
  int items = 0;
  double total = 0.0;
  double totalDesconto = 0.0;
  double descontoItem = 0.0;
  int locid = 0;
  int empid = 0;
  double descontoItemFinal = 0.0;

  String searchString = "";
  TextEditingController searchController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();
  String _mensagemErro = "";
  TextEditingController razaosocialtxt = TextEditingController(text: "dan");
  TextEditingController cpf_cnpjtxt = TextEditingController(text: "123");
  TextEditingController controllerSubtotal = TextEditingController(text: "0.0");
  TextEditingController controlDescontoItem =
      TextEditingController(text: "0.0");
  bool enebledButton = false;
  var dados;
  String PROID;
  String PRONOME;
  String PRODESCRICAO;
  String PROVALOR;
  String PROIMAGEM;
  String forma;
  int idForma = 0;
  DateTime _dateTime;
  String _dateformat;
  String _horaAtual;
  bool asSelect = false;
  bool asSelectCli = false;
  String nomeVendedor;
  List<Produto> produtolist = [];

  bool init = true;

  Vendedor vendedor;
  Cliente cliente;
  Produto produto;
  Produto produtoBusca;
  Produto prodid = Produto();
  String valueForma = "";
  Timer _timer;
  Conexao c = Conexao();
  String obsOrcamento = null;
  String valorProduto = null;

  String formasDePagamento = null;
  String custo = null;
  String _selected;
  List<String> _vezes = ['1', '2', '3', '4', '5'];
  String formaPrazo;
  String cliImagem = "";
  String razao = "";
  String fone = "";
  String fone2 = "";
  String email = "";
  String logradouro = "";
  String numero = "";
  String bairro = "";
  String cidade = "";
  bool debitoButton = false;
  String cep = "";
  String uf = "";
  String cnpj = "";
  DateTime now = new DateTime.now();
  DateTime date;
  int idCliente = 0;
  double descontoTotal = 0.0;
  Cliente cli = Cliente();
  Empresa empresa = Empresa();
  List formasPrazo = [];
  double descontoPercente = 0.0;

  double descontoTipo = 0.0;
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    focusNodeRef = FocusNode();
    focusNodeObs = FocusNode();
    focusNodeCli = FocusNode();
    descontoControl.selection = TextSelection.fromPosition(
        TextPosition(offset: descontoControl.text.length));

    recuperarConexao();
    initializeDateFormatting('pt_br');
    _future = getDataProd();
    _futureVend = getDataVend();
    _futureCli = getDataClientes();

    _dateTime = DateTime.now();
    _dateformat = DateFormat('dd/MM/yyyy').format(_dateTime);
    _horaAtual = DateFormat.jms('pt_br').format(now);
    _timer = new Timer(const Duration(milliseconds: 400), () {});
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  void valoresVendaEdit(List produtos, int index) {
    valoresProd.clear();
    setState(() {
      widget.valorVenda = "Vr.Venda";
    });

    for (int i = 0; i < valoresVenda.length; i++) {
      valoresProd.add({
        "Nome": "PROVALORVENDA${valoresVenda[i]['VENDA']}",
        "Valor":
            "${produtos[index].dados[0]['PROVALORVENDA${valoresVenda[i]['VENDA']}']}"
      });
    }
  }

  Future<String> _buscarDebitos(int cliid) async {
    listaDebitos.clear();
    setState(() {
      initialTela = false;
    });

    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/contasReceber/contasReceber.php?cliid=${cliid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (msg == "Dados incorretos!") {
      //ValorNaoEncontrado();
      setState(() {
        debitoButton = false;
      });
    } else {
      var dados = obj['result'];

      if (mounted) {
        setState(() {
          listaDebitos = dados;
          debitoButton = true;
        });
      }
    }

    return "funcao";
  }

  double totalPrice2() {
    double total = 0;
    for (int i = 0; i < widget.list.length; i++) {
      if (widget.list[i].PROVALORDESCONTO != null) {
        total += (widget.list[i].quantity * widget.list[i].PROVALOR) -
            widget.list[i].PROVALORDESCONTO;
      } else {
        total += widget.list[i].quantity * widget.list[i].PROVALOR;
      }
    }

    setState(() {
      total2 = total;
    });

    return total2;
  }

  double totalPriceProd() {
    double total = 0;
    for (int i = 0; i < widget.list.length; i++) {
      if (widget.list[i].PROVALORDESCONTO != null) {
        total += (widget.list[i].quantity * widget.list[i].PROVALOR);
      } else {
        total += widget.list[i].quantity * widget.list[i].PROVALOR;
      }
    }

    return total;
  }

  double totalDesconto2() {
    double total = 0;
    for (int i = 0; i < widget.list.length; i++) {
      total += widget.list[i].PROVALORDESCONTO;
    }

    return total;
  }

  void alterarValor(String text) {
    setState(() {
      controlProdValor = TextEditingController(text: text);
    });
  }

  void alterarDescontoControl(String text) {
    setState(() {
      descontoControl = TextEditingController(text: text);
    });
  }

  void alterarDescontoControlPorc(String text) {
    setState(() {
      controlPorcen = TextEditingController(text: text);
    });
  }

  void alterarDesconto(String text) {
    setState(() {
      controlProdDesc = TextEditingController(text: text);
    });
  }

  void alterarSubtotal() {
    double valorSubtotal =
        (double.parse(controlQtd.text) * double.parse(controlProdValor.text)) -
            double.parse(controlProdDesc.text);
    setState(() {
      controllerSubtotal = TextEditingController(text: "${valorSubtotal}");
    });
  }

  void alterarSubtotal3(double desconto) {
    double valorSubtotal =
        (double.parse(controlQtd.text) * double.parse(controlProdValor.text)) -
            desconto;
    setState(() {
      controllerSubtotal = TextEditingController(text: "${valorSubtotal}");
    });
  }

  void alterarSubtotal2(String text) {
    setState(() {
      controllerSubtotal = TextEditingController(text: "${text}");
    });
  }

  double somarQtd(Produto prod) {
    double qtd = 0;

    for (int i = 0; i < widget.list.length; i++) {
      if (widget.list[i] == prod) {
        qtd += widget.list[i].quantity;
      }
    }
    return qtd;
  }

  void recuperarEmpid() {
    if (Provider.of<Empresa>(context).empresa != null) {
      empid = Provider.of<Empresa>(context).empresa.EMPID;
      empresa = Provider.of<Empresa>(context).empresa;

      percentualMax = Provider.of<Especifica>(context, listen: false)
          .getEspecifica()
          .UPEPERCENTUALDESCONTO
          .toDouble();
    }
  }

  _deslogarUsuario() async {
    Navigator.pushReplacementNamed(context, "/login");

    Vendedor vend = Vendedor();
    vend.VENDNOME = "Vendedor";
    vend.VENDEMAIL = "";
    Provider.of<VendedorProvider>(context, listen: false).vendedorGet(vend);
  }

  double valorDescontoPorcent(
      double porcentagem, double valorProd, double qtd) {
    double result = (porcentagem / 100) * (valorProd * qtd);

    this.descontoPercente = result;

    return descontoPercente;
  }

  double valorDescontoPorcent2(double porcentagem, double valorProd) {
    double result = (porcentagem / 100) * valorProd;

    this.descontoPercente = result;

    return descontoPercente;
  }

  double descontoFinal() {
    double total = 0;
    for (int i = 0; i < widget.list.length; i++) {
      total += widget.list[i].PROVALORDESCONTO;
    }

    print(total);
    return total;
  }

  Future<double> estoqueProduto(
      int proid, int corid, int tamid, int empid) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/qtdEstoqueProduto.php?proid=${proid}&tamid=${tamid}&corid=${idCor}&empid=${empid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);

    dados = obj['result'];

    if (dados != null) {
      setState(() {
        qtdMax = double.parse(dados[0]['LOPQTD']);
      });

      return estoquePro = double.parse(dados[0]['LOPQTD']);
    }

    return 0.0;
  }

  void recuperarEspecifica() {
    if (Provider.of<Especifica>(context).UPEPERCENTUALDESCONTO != null) {
      percentualMax = double.parse(
          "${Provider.of<Especifica>(context).UPEPERCENTUALDESCONTO}");
    }
  }

  Future getFormasPrazo() async {
    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/formasPrazo.php"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);

      setState(() {
        formasPrazo = obj['result'];
      });
    } catch (e) {
      print("error");
    }
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

  Future<String> buscarClienteId(String cliid) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/clientes/buscarClienteid.php?cliid=${cliid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (msg == "Dados incorretos!") {
      MensagemClienteError();
    } else {
      dados = obj['result'];

      this.cli = _dadosCliente(dados);

      setState(() {
        recuperouCli = true;
      });

      print("buscando pelo id" + cli.id.toString());
      _buscarDebitos(cli.id);

      Fluttertoast.showToast(
          msg: "Cliente selecionado!",
          backgroundColor: Colors.blue[900],
          textColor: Colors.white,
          fontSize: 16.0);

      Provider.of<ClienteProvider>(context, listen: false).clienteGet(this.cli);

      focusNodeRef.requestFocus();
    }
  }

  String _formatData(String value) {
    DateTime data = DateTime.parse(value);
    String _dateformat = DateFormat('dd/MM/yyyy').format(data);

    return _dateformat;
  }

  Widget setupAlertDialoadContainer() {
    return Container(
      width: 300.0, // Change as per your requirement
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "CLIENTE: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  "${recuperouCli ? Provider.of<ClienteProvider>(context, listen: false).cli.nomeFantasia : widget.orc.CLINOMEFANTASIA}"),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: listaDebitos.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "ID: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("${listaDebitos[index]['CRCID']}"),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Número Documento: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("${listaDebitos[index]['CRCNUMERODOCUMENTO']}"),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Data: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              "${_formatData(listaDebitos[index]['CRCDATAVENCIMENTO'])}"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Historico: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Flexible(
                              child: Text(
                                  "${listaDebitos[index]['CRCHISTORICO']}")),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Valor: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              "R\$ ${listaDebitos[index]['CRCVALORDOCUMENTO']}"),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
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
      dados = obj['result'];

      return double.parse(dados[0]['ORIVALOR']);
    }
  }

  Future<String> buscarProdid(String proid) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/buscarProdutoId.php?proid=${proid}&empid=${empid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (msg == "Dados incorretos!") {
      buscarProdStq(proid);
    } else {
      setState(() {
        semGrade = false;
      });

      var dados = obj['result'];

      print(dados);
      valoresProd.clear();

      for (int i = 0; i < valoresVenda.length; i++) {
        valoresProd.add({
          "Nome": "PROVALORVENDA${valoresVenda[i]['VENDA']}",
          "Valor": "${dados[0]['PROVALORVENDA${valoresVenda[i]['VENDA']}']}"
        });
      }

      print(valoresProd);

      if (dados[0]['PROID'] == null) {
        buscarProdStq(proid);
      } else {
        this.prodid = await _dadosProd(dados);

        setState(() {
          qtdMaxEst = double.parse(dados[0]['LOPQTD']);
        });

        print("Max estoque: " + qtdMaxEst.toString());
        print("Proid: " + prodid.PROID.toString());

        limpar();
        Provider.of<ProdutoProvider>(context, listen: false).addProd(prodid);

        buscarCoresTam(dados[0]['PROID']);
      }
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
      MensagemProdutoError();
    } else {
      dados = obj['result'];

      this.prodid = await _dadosProd(dados);
      setState(() {
        temGrade = false;
        semGrade = true;
      });

      limpar();
      Provider.of<ProdutoProvider>(context, listen: false).addProd(prodid);
    }
  }

  Future<String> buscarTamanhos(
      String idCor, String proid, String empid) async {
    tamanhos.clear();

    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/tamanhos.php?empid=${empid}&corid=${idCor}&proid=${proid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    print(obj);

    if (msg == "Dados incorretos!") {
    } else {
      dados = obj['result'];

      if (tamanhos.length == 1 && tamanhos[0]['TAMID'] == "0") {
        setState(() {
          idGrade = int.parse(tamanhos[0]['TAMID']);
          widget.grade = tamanhos[0]['TAMNOME'];
        });
      }

      setState(() {
        tamanhos = dados;
      });
    }
  }

  Future<String> buscarCoresTam(String proid) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/corestam.php?proid=${proid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (msg == "Dados incorretos!") {
    } else {
      dados = obj['result'];

      setState(() {
        temGrade = true;
        tamcores = dados;
      });

      if (tamcores.isNotEmpty) {
        cores.clear();
        tamanhos.clear();
        var resultcor;

        for (int i = 0; i < tamcores.length; i++) {
          resultcor = {
            "CORID": "${tamcores[i]['CORID']}",
            "CORNOME": "${tamcores[i]['CORNOME']}"
          };

          setState(() {
            cores.add(resultcor);
          });
        }

        if (cores.length == 1 && cores[0]['CORID'] == "0") {
          setState(() {
            widget.cor = cores[0]['CORNOME'];
            idCor = int.parse(cores[0]['CORID']);

            selected = true;
            temGrade = false;
          });
        }

        setState(() {
          tamanhos = tamanhos;
          cores = cores;
        });
      }
    }
  }

  Cliente _dadosCliente(dados) {
    Cliente cliente = Cliente(
        id: int.parse(dados[0]['CLIID']),
        razao: dados[0]["CLINOMERAZAO"],
        nomeFantasia: dados[0]["CLINOME"],
        cpf_cnpj: dados[0]["CLICPF"],
        rg_ie: dados[0]["CLIRG"],
        tel1: dados[0]["CLIFONE01"],
        tel2: dados[0]["CLIFONE02"],
        tipoPessoa: dados[0]["CLITIPOPESSOA"],
        cep: dados[0]["CLICEP"],
        cidade: dados[0]["CLICIDADE"],
        logradouro: dados[0]["CLIENDERECO"],
        uf: dados[0]["CLIUF"],
        bairro: dados[0]["CLIBAIRRO"],
        email: dados[0]["CLIEMAIL"],
        site: dados[0]["CLICONTATO"],
        obs: dados[0]["CLICOMENTARIO"]);

    return cliente;
  }

  Future<Produto> _dadosProd(dados) async {
    Produto prod = Produto();
    prod.PROID = int.parse(dados[0]['PROID']);
    prod.PROREFERENCIA = dados[0]['PROREFERENCIA'];
    prod.PRONOME = dados[0]['PRONOME'];
    prod.PRODESCRICAO = dados[0]['PRODESCRICAO'];
    prod.PRECOCUSTO = double.parse(dados[0]['PROVALORCUSTO']);
    prod.dados = dados;

    if (config.ULTIMOVALORVENDA == 1) {
      double result = await buscarUltimoValor(cli.id, prod.PROID);
      print(result);
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

  _recuperarClienteId() {
    if (controllerClienteId.text.isNotEmpty) {
      if (clientesList.isNotEmpty) {
        for (var item in clientesList) {
          print(item);
        }
      }
    }
  }

  @override
  void dispose() {
    focusNodeRef.dispose();
    focusNodeObs.dispose();
    focusNodeCli.dispose();
    _timer.cancel();
    super.dispose();
  }

  String _formatValue(double value) {
    final NumberFormat numberFormat = new NumberFormat("##0.00", "en_US");
    return numberFormat.format(value);
  }

  String _formatValueDesconto(double value1, double value2) {
    double result = value1 - value2;
    final NumberFormat numberFormat = new NumberFormat("#,##0.00", "pt_BR");
    return numberFormat.format(result);
  }

  void recuperarConfig() {
    if (Provider.of<ConfigProvider>(context).config != null) {
      config = Provider.of<ConfigProvider>(context).config;
    }
  }

  void recuperarFormas() {
    if (Provider.of<FormasProvider>(context).forma != null) {
      forma = Provider.of<FormasProvider>(context).forma;
      if (forma == "A PRAZO") {
        formaPrazo = forma;
      }
      idForma = Provider.of<FormasProvider>(context).id;

      formaPagamento = TextEditingController(text: forma);

      if (formaPagamento.text.isNotEmpty &&
          formaPagamento.text != "CARTAO CREDITO") {
        controlOrcObs.clear();
        controlOrcObs =
            TextEditingController(text: "Forma de pagamento: $forma");
      } else if (formaPagamento.text == "CARTAO CREDITO") {
        controlOrcObs.clear();
        controlOrcObs =
            TextEditingController(text: "Forma de pagamento: $forma");
        if (int.parse(controlParcelas.text) >= 1) {
          controlOrcObs = TextEditingController(
              text: controlOrcObs.text +
                  "\n Pagamento parcelado: ${controlParcelas.text} de R\$ ${_formatValue(total / int.parse(controlParcelas.text))}");
        }
      }
    }
  }

  double totalPrice() {
    double totalB = 0;
    double desconTipo = 0;

    if (config.TIPODESCONTO == 1) {
      descontoControl = TextEditingController(text: "0.0");
      for (int i = 0; i < widget.list.length; i++) {
        count++;
        if (widget.list[i].PROVALORDESCONTO != null) {
          totalB += (widget.list[i].quantity * widget.list[i].PROVALOR);

          desconTipo += widget.list[i].PROVALORDESCONTO;
        } else {
          totalB += widget.list[i].quantity * widget.list[i].PROVALOR;
        }
      }

      total = totalB;

      setState(() {
        descontoTipo = desconTipo;
      });
    } else {
      for (int i = 0; i < widget.list.length; i++) {
        if (widget.list[i].PROVALORDESCONTO != null) {
          totalB += (widget.list[i].quantity * widget.list[i].PROVALOR) -
              widget.list[i].PROVALORDESCONTO;
        } else {
          totalB += widget.list[i].quantity * widget.list[i].PROVALOR;
        }
      }

      total = totalB + double.parse(descontoControl.text);
    }

    if (descontoControl.text == "0.0") {
      if (init == true) {
        descontoControl = TextEditingController(
            text:
                "${_formatValue(double.parse(widget.orc.ORCOBS2) * widget.list.length)}");

        if (double.parse(descontoControl.text) <= 0) {
          setState(() {
            resetDesconto = false;
          });
        } else {
          setState(() {
            resetDesconto = true;
            init = false;
          });
        }
      }
    } else {
      print("aqui diferente");
    }
    if (widget.forma == "Forma De Pagamento") {
      setState(() {
        widget.forma = "${widget.orc.ORCFORMAPAGAMENTOTXT}";
        formaNome = widget.orc.ORCFORMAPAGAMENTOTXT;
      });
    }

    return total;
  }

  void recuperarDadosProduto() {
    if (widget.list.isNotEmpty) {
      items = widget.list.length;
      total = totalPrice();
    } else {
      items = 0;
      total = 0.0;
    }
  }

  void recuperarProduto() async {
    if (Provider.of<ProdutoProvider>(context, listen: false).produto != null) {
      produto = Provider.of<ProdutoProvider>(context, listen: false).produto;

      var dados = produto.dados;
      String proreferencia =
          Provider.of<ProdutoProvider>(context, listen: false)
              .produto
              .PROREFERENCIA;
      String nome =
          Provider.of<ProdutoProvider>(context, listen: false).produto.PRONOME;

      setState(() {
        idProd =
            Provider.of<ProdutoProvider>(context, listen: false).produto.PROID;
      });

      double provalor =
          Provider.of<ProdutoProvider>(context, listen: false).produto.PROVALOR;

      if (config.ULTIMOVALORVENDA == 1) {
        int idCliente =
            Provider.of<ClienteProvider>(context, listen: false).cli != null
                ? Provider.of<ClienteProvider>(context, listen: false).cli.id
                : orc.CLIID;
        provalor = await buscarUltimoValor(idCliente, idProd);

        if (provalor == null || provalor == "null") {
          provalor = Provider.of<ProdutoProvider>(context, listen: false)
              .produto
              .PROVALOR;
        }
      }

      double desc = Provider.of<ProdutoProvider>(context, listen: false)
          .produto
          .PROVALORDESCONTO;
      double valorCusto = Provider.of<ProdutoProvider>(context, listen: false)
          .produto
          .PRECOCUSTO;

      if (valorCusto == null) {
        valorCusto = 0.0;
      }

      if (enabledEdit == false) {
        idProdEdit =
            Provider.of<ProdutoProvider>(context, listen: false).produto.PROID;
      }

      double qtd =
          Provider.of<ProdutoProvider>(context, listen: false).produto.quantity;
      String obs =
          Provider.of<ProdutoProvider>(context, listen: false).produto.PROOBS;
      controlProdNome = TextEditingController(text: '${nome}');
      controlProdId = TextEditingController(text: '${proreferencia}');
      controlProdDesc = TextEditingController(text: '${desc}');
      controlProdValor = TextEditingController(text: '${provalor}');
      controlProdValorCusto = TextEditingController(text: '${valorCusto}');
      controlQtd = TextEditingController(text: '${qtd.toInt()}');
      controlProdObs = TextEditingController(text: '${obs}');

      percentualMax = Provider.of<Especifica>(context, listen: false)
          .getEspecifica()
          .UPEPERCENTUALDESCONTO
          .toDouble();

      valoresProd.clear();

      for (int i = 0; i < valoresVenda.length; i++) {
        valoresProd.add({
          "Nome": "PROVALORVENDA${valoresVenda[i]['VENDA']}",
          "Valor": "${dados[0]['PROVALORVENDA${valoresVenda[i]['VENDA']}']}"
        });
      }

      buscarCoresTam(idProd.toString());
      buscarTamanhos(idCor.toString(), idProd.toString(), empid.toString());

      estoqueProduto(idProd, idCor, idGrade, empid);

      if (controllerSubtotal.text != "0.0") {
        if (desc > 0.0) {
          alterarSubtotal3(desc);
        } else {
          double valorSubtotal = qtd * provalor;
          controllerSubtotal = TextEditingController(text: '${valorSubtotal}');
        }
      }
    }
  }

  void addItemIndex(int index, Produto item) {
    widget.list.removeAt(index);
    widget.list.insert(index, item);
  }

  @override
  void didChangeDependencies() {
    recuperarDadosProduto();
    if (controlProdNome.text == "") {
      recuperarProduto();
    }

    totalPrice2();

    sized.init(context);
    recuperarConfiguracoesModel();

    recuperarFormas();
    recuperarDados();
    recuperarEmpid();
    recuperarConfig();
    recuperarEspecifica();
    super.didChangeDependencies();
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

  void limpar() {
    controlProdId.clear();
    controlProdDesc.clear();
    controlProdObs.clear();
    controlProdNome.clear();
    controlProdValor.clear();
    controlQtd.clear();
    controlDescontoItem.clear();
    controllerSubtotal.clear();

    setState(() {
      widget.grade = "PADRAO";
      widget.cor = "PADRAO";
    });

    Provider.of<ProdutoProvider>(context, listen: false).limparProduto();
  }

  void recuperarConexao() async {
    List list = await DBProvider.db.getAllConexaos();

    if (list.isNotEmpty) {
      c = await DBProvider.db.getConexao(1);
      print(c);
    }

    if (c.bdname != null) {
      getFormas();
      getTipos();
      _buscarDebitos(widget.orc.CLIID);
      getOrcamentos(widget.orc.ORCID);
    }
  }

  Future getTipos() async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/tiposDocumento.php"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);

    if (mounted) {
      setState(() {
        tipoDocumento = obj['result'];
      });
    }

    return obj['result'];
  }

  Future getFormas() async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/formasPagamento.php"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    if (mounted) {
      setState(() {
        formasPagamento = obj['result'];
      });
    }

    return obj['result'];
  }

  void recuperarDados() {
    if (recuperouCli == false) {
      controllerClienteId = TextEditingController(text: "${widget.orc.CLIID}");
      controllerClienteNome =
          TextEditingController(text: "${widget.orc.CLINOMEFANTASIA}");
    } else if (Provider.of<ClienteProvider>(context, listen: false).cli !=
        null) {
      controllerClienteId = TextEditingController(
          text:
              "${Provider.of<ClienteProvider>(context, listen: false).cli.id}");

      controllerClienteNome = TextEditingController(
          text:
              "${Provider.of<ClienteProvider>(context, listen: false).cli.nomeFantasia}");
    }

    controllerVendId = TextEditingController(text: "${widget.orc.VENID}");
    controllerVendNome = TextEditingController(text: "${widget.orc.VENNOME}");

    if (Provider.of<FormasProvider>(context, listen: false).forma != null) {
      forma = Provider.of<FormasProvider>(context, listen: false).forma;

      formaPagamento = TextEditingController(text: "${forma}");

      controlOrcObs = TextEditingController(text: "Forma Pagamento: ${forma}");
    } else {
      formaPagamento =
          TextEditingController(text: "${widget.orc.ORCFORMAPAGAMENTOTXT}");
      controlOrcObs = TextEditingController(text: "${widget.orc.ORCOBS}");
    }
  }

  Future<bool> _onBackPressed() {
    if (widget.list.isNotEmpty) {
      return showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text(
                  'Você tem certeza que quer voltar sem finalizar a alteração do pedido?'),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text('Não'),
                ),
                new FlatButton(
                  onPressed: () {
                    for (var item in widget.list) {
                      voltarEstoqueProduto(item.PROID, item.corid, item.tamid,
                          empresa.EMPID, item.quantity);
                    }
                    Navigator.of(context).pop(true);
                    Provider.of<ProdutoProvider>(context, listen: false)
                        .limparProduto();
                  },
                  child: new Text('Sim'),
                ),
              ],
            ),
          ) ??
          false;
    }
    Navigator.of(context).pop();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffold,
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          title: Text("Orcamento: ${widget.orc.ORCID}"),
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
        body: _body(),
      ),
    );
  }

  _drawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue[900]),
            accountName: Text("Vendedor: " + widget.vend.VENDNOME),
            accountEmail: Text(widget.vend.VENDEMAIL),
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
                      vend: vendedor,
                    ),
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

  bool buscarProduto(Produto prod) {
    bool result;

    for (var item in widget.list) {
      if (item.corid == prod.corid && item.tamid == prod.tamid) {
        result = true;
        break;
      } else {
        result = false;
      }
    }

    return result;
  }

  Future<String> _deleteOrcamento(int orcid) async {
    await http.get(
        Uri.encodeFull(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/deleteORC.php?orcid=${orcid}&usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}"),
        headers: {"Accept": "application/json"});
  }

  delete(int orcid) async {
    _deleteOrcamento(orcid).then((sucess) => {
          print("deletado com sucesso!"),
        });
  }

  Future<String> baixarEstoqueProduto(
      int proid, int corid, int tamid, int empid, double qtd) async {
    final result = await http.post(
        'http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/baixarEstoque.php?qtd=${qtd}&proid=${proid}&corid=${corid}&tamid=${tamid}&empid=${empid}',
        body: c.toJson());

    if (result.statusCode == 200) {
      var obj = convert.json.decode(result.body);
      print("Result baixa: " + obj['success'].toString());

      return result.body;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
  }

  Future getLOCID(int empid) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/empresas/selectlocid.php?empid=${empid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);

    dados = obj['result'];

    if (mounted) {
      setState(() {
        locid = int.parse(dados[0]['LOCID']);
      });
    }

    return obj['result'];
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

  _asSelectCli(asSelectCli) {
    if (asSelectCli == false) {
      return Positioned(
          left: 50,
          top: 12,
          child: Container(
            padding: EdgeInsets.only(bottom: 2, left: 10, right: 10),
            color: Colors.white,
            child: Text(
              'Selecione o Cliente',
              style: TextStyle(color: Colors.blue[900], fontSize: 12),
            ),
          ));
    }

    if (asSelectCli == true) {
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

  _orcamentoOBJ(dados) {
    return orc = new Orcamento(
        ORCID: int.parse(dados[0]['ORCID']),
        CLIID: int.parse(dados[0]['CLIID']),
        VENID: int.parse(dados[0]['VENID']),
        EMPID: int.parse(dados[0]['EMPID']),
        VENNOME: dados[0]['VENNOME'],
        CLINOMERAZAO: dados[0]['CLINOMERAZAO'],
        ORCDATA: dados[0]['ORCDATA'],
        ORCHORA: dados[0]['ORCHORA'],
        ORCVALORTOTAL: double.parse(dados[0]['ORCVALORTOTAL']),
        ORCFORMAPAGAMENTOTXT: dados[0]['ORCFORMAPAGAMENTOTXT'],
        ORCOBS2: dados[0]['ORIDESCONTO'],
        ORCOBS: dados[0]['ORCOBS'],
        CLICPF: dados[0]['CLICPF'],
        FONEVEND: dados[0]['VENFONE01']);
  }

  Future<List<Produto>> getOrcamentos(int orcid) async {
    print(orcid);

    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/buscarOrcamento.php?orcid=${orcid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);

    setState(() {
      resulOrcamentos = obj['result'];
    });
    print("aqui result");
    print(resulOrcamentos);

    var dados = obj['result'];

    setState(() {
      orcstatus = dados[0]['ORCSTATUS'];
    });

    orc = _orcamentoOBJ(dados);

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
      desconto += prod.PROVALORDESCONTO;

      setState(() {
        produtos.add(prod);
      });
    }

    return produtos;
  }

  Future<String> _deleteItens(int orcid) async {
    await http.get(
        Uri.encodeFull(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/deleteItens.php?orcid=${orcid}&usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}"),
        headers: {"Accept": "application/json"});
  }

  deleteItem(int orcid) async {
    _deleteItens(orcid).then((sucess) => {
          print("deletado com sucesso!"),
        });
  }

  _body() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(padding: EdgeInsets.all(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.all(8)),
              new SizedBox(
                width: 95,
                child: GestureDetector(
                  child: TextField(
                    enabled: false,
                    controller: controllerVendId,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'ID',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        filled: true,
                        fillColor: Colors.grey[350],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: Colors.blue[900]),
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(4)),
              new SizedBox(
                width: SizeConfig.screenWidth - 127,
                child: GestureDetector(
                  child: TextField(
                    enabled: false,
                    controller: controllerVendNome,
                    decoration: InputDecoration(
                        labelText: 'VENDEDOR',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        filled: true,
                        fillColor: Colors.grey[350],
                        border: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: Colors.blue[900]),
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.all(4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.all(8)),
              new SizedBox(
                width: 95,
                child: GestureDetector(
                  onTap: () {
                    focusNodeCli.requestFocus();
                  },
                  child: TextField(
                    autofocus: true,
                    focusNode: focusNodeCli,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (value) {
                      buscarClienteId(controllerClienteId.text);
                    },
                    controller: controllerClienteId,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'ID',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        filled: true,
                        fillColor: Colors.grey[350],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: Colors.blue[900]),
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(4)),
              new SizedBox(
                width: SizeConfig.screenWidth - 127,
                child: GestureDetector(
                  onDoubleTap: () {
                    Navigator.pushNamed(context, '/clientesBusca');
                  },
                  child: TextField(
                    enabled: false,
                    controller: controllerClienteNome,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.search,
                            color: Colors.blue[900],
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/clientesBusca');
                          },
                        ),
                        labelText: 'CLIENTE',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        filled: true,
                        fillColor: Colors.grey[350],
                        border: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: Colors.blue[900]),
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              debitoButton && cli != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10, left: 20.0),
                      child: Container(
                        child: ElevatedButton(
                            child: Text("Débitos"),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.blue[900])),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                      title: Row(
                                        children: [
                                          Wrap(
                                            children: [Text("Débitos")],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 140.0),
                                            child: IconButton(
                                                icon: Icon(Icons.cancel,
                                                    color: Colors.red),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                }),
                                          ),
                                        ],
                                      ),
                                      content: SingleChildScrollView(
                                          child: setupAlertDialoadContainer()));
                                },
                              );
                            }),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 10, left: 20.0),
                      child: Container(
                        child: ElevatedButton(
                            child: Text("Débitos"),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.grey)),
                            onPressed: () {}),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(left: 150, top: 10),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Text(
                        _dateTime == null ? 'Selecione uma data!' : "Data",
                        style: TextStyle(color: Colors.black, fontSize: 18),
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
                                  lastDate: DateTime(2030))
                              .then((date) {
                            setState(() {
                              initializeDateFormatting('pt_br');
                              _dateTime = date;
                              _dateformat =
                                  DateFormat('dd/MM/yyyy').format(_dateTime);
                              _horaAtual =
                                  DateFormat.jms('pt_br').format(_dateTime);
                            });
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Seleção Produto",
                  style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.all(4)),
                Row(
                  children: [
                    Padding(padding: EdgeInsets.all(8)),
                    new SizedBox(
                      width: 100,
                      height: 50,
                      child: GestureDetector(
                        child: TextField(
                          autofocus: true,
                          enabled: enabledEdit,
                          focusNode: focusNodeRef,
                          controller: controlProdId,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (value) {
                            buscarProdid(controlProdId.text);
                          },
                          decoration: InputDecoration(
                              labelText: 'REF',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              filled: true,
                              fillColor: Colors.grey[350],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: Colors.blue[900]),
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(4)),
                    new SizedBox(
                      width: SizeConfig.screenWidth - 135,
                      height: 50,
                      child: GestureDetector(
                        onDoubleTap: () {
                          if (enabledEdit != false) {
                            limpar();

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProdutosCatalog(),
                                ));
                          }
                        },
                        child: TextField(
                          controller: controlProdNome,
                          enabled: false,
                          decoration: InputDecoration(
                              labelText: 'Nome Produto',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              filled: true,
                              fillColor: Colors.grey[350],
                              border: OutlineInputBorder(
                                  borderSide: new BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: Colors.blue[900]),
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.all(4)),
                Row(
                  children: [
                    Padding(padding: EdgeInsets.all(8)),
                    new SizedBox(
                      width: 69,
                      height: 55,
                      child: GestureDetector(
                        child: TextField(
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              if (double.parse(controlProdDesc.text) == 0.0) {
                                double valorsubtotal =
                                    double.parse(controlQtd.text) *
                                        double.parse(controlProdValor.text);
                                alterarSubtotal2(_formatValue(valorsubtotal));
                              } else {
                                if (controlPorcen.text.isNotEmpty) {
                                  double valor = valorDescontoPorcent(
                                      double.parse(controlPorcen.text),
                                      double.parse(controlProdValor.text),
                                      double.parse(controlQtd.text));

                                  alterarDesconto(_formatValue(valor));

                                  double valorSubtotal =
                                      (double.parse(controlProdValor.text) *
                                              double.parse(controlQtd.text)) -
                                          valor;

                                  alterarSubtotal2(_formatValue(valorSubtotal));
                                } else if (double.parse(controlProdDesc.text) >
                                    0.0) {
                                  double valorSubtotal = (double.parse(
                                              controlQtd.text) *
                                          double.parse(controlProdValor.text) -
                                      double.parse(controlProdDesc.text));

                                  alterarSubtotal2(valorSubtotal.toString());
                                } else {
                                  double valorSubtotal =
                                      double.parse(controlQtd.text) *
                                          double.parse(controlProdValor.text);

                                  alterarSubtotal2(valorSubtotal.toString());
                                }
                              }
                            }
                          },
                          controller: controlQtd,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: 'QTD',
                              labelStyle: TextStyle(fontSize: 15),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              filled: true,
                              fillColor: Colors.grey[350],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: Colors.blue[900]),
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(4)),
                    new SizedBox(
                      width: 92,
                      height: 55,
                      child: GestureDetector(
                        onDoubleTap: () {
                          if (controlProdNome.text != "") {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: StatefulBuilder(
                                    // You need this, notice the parameters below:
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return Form(
                                          key: formKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              DropdownButton(
                                                  underline: Text(""),
                                                  hint: widget.valorVenda ==
                                                          null
                                                      ? Text(
                                                          'Vr.Venda',
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        )
                                                      : Text(
                                                          "${widget.valorVenda}",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18),
                                                        ),
                                                  iconSize: 30.0,
                                                  style: TextStyle(
                                                      color: Colors.blue),
                                                  items: valoresProd
                                                      .asMap()
                                                      .entries
                                                      .map((dynamic map) {
                                                    return new DropdownMenuItem<
                                                        dynamic>(
                                                      value:
                                                          "${double.parse(map.value['Valor'])}",
                                                      child: new Text(
                                                          "${map.value['Nome']}: R\$ ${_formatValue(double.parse(map.value['Valor']))}",
                                                          style: new TextStyle(
                                                              color: Colors
                                                                  .black)),
                                                    );
                                                  }).toList(),
                                                  onChanged: (val) {
                                                    setState(() {
                                                      if (val == "0.0") {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Valor de Produto zerado!");
                                                      } else {
                                                        widget.valorVenda =
                                                            "Vr.Venda: R\$" +
                                                                val;

                                                        alterarValor("${val}");

                                                        if (double.parse(
                                                                controlProdDesc
                                                                    .text) >
                                                            0.0) {
                                                          var valorsub = (double
                                                                      .parse(
                                                                          val) *
                                                                  double.parse(
                                                                      controlQtd
                                                                          .text)) -
                                                              double.parse(
                                                                  controlProdDesc
                                                                      .text);

                                                          alterarSubtotal2(
                                                              _formatValue(
                                                                  valorsub));

                                                          if (controlPorcen.text
                                                              .isNotEmpty) {
                                                            var porcentagem =
                                                                double.parse(
                                                                    controlPorcen
                                                                        .text);
                                                            var desconto =
                                                                valorDescontoPorcent(
                                                                    porcentagem,
                                                                    double.parse(
                                                                        val),
                                                                    double.parse(
                                                                        controlQtd
                                                                            .text));

                                                            alterarDesconto(
                                                                _formatValue(
                                                                    desconto));
                                                          }
                                                        }
                                                      }
                                                    });
                                                  }),
                                              SizedBox(
                                                width: 120,
                                                height: 60,
                                                child: Container(
                                                  child: TextField(
                                                    onChanged: (value) {
                                                      alterarSubtotal();
                                                      setState(() {
                                                        controlQtd = controlQtd;
                                                      });
                                                    },
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                            decimal: true),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              '[0-9.,]')),
                                                    ],
                                                    controller:
                                                        controlProdValor,
                                                    enabled:
                                                        config.ALTVALORPRODUTOVENDA ==
                                                                1
                                                            ? true
                                                            : false,
                                                    decoration: InputDecoration(
                                                        labelText: 'Valor',
                                                        labelStyle: TextStyle(
                                                            fontSize: 15),
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                                vertical: 15,
                                                                horizontal: 20),
                                                        filled: true,
                                                        fillColor:
                                                            Colors.grey[350],
                                                        border: OutlineInputBorder(
                                                            borderSide: new BorderSide(
                                                                color:
                                                                    Colors.red),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    10)),
                                                        focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                width: 2,
                                                                color: Colors
                                                                    .blue[900]),
                                                            borderRadius:
                                                                BorderRadius.circular(10))),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  ElevatedButton(
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                          .blue[
                                                                      900])),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text("Ok")),
                                                  ElevatedButton(
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .red)),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text("Voltar")),
                                                ],
                                              )
                                            ],
                                          ));
                                    },
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: Container(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                alterarSubtotal();
                                controlQtd = controlQtd;
                              });
                            },
                            controller: controlProdValor,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp('[0-9.,]')),
                            ],
                            enabled:
                                config.ALTVALORPRODUTOVENDA == 1 ? true : false,
                            decoration: InputDecoration(
                                labelText: 'Valor',
                                labelStyle: TextStyle(fontSize: 15),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                filled: true,
                                fillColor: Colors.grey[350],
                                border: OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.red),
                                    borderRadius: BorderRadius.circular(10)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2, color: Colors.blue[900]),
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 10, top: 3)),
                    config.HABDESCONTO == 1
                        ? config.TIPODESCONTO == 1
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: new SizedBox(
                                  width: 70,
                                  height: 57,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (controlProdId.text.isEmpty) {
                                        Mensagem();
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: StatefulBuilder(
                                                // You need this, notice the parameters below:
                                                builder: (BuildContext context,
                                                    StateSetter setState) {
                                                  return Form(
                                                    key: formKey,
                                                    child: Column(
                                                        // Then, the content of your dialog.
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          DropdownButton(
                                                            hint:
                                                                widget.desconto ==
                                                                        null
                                                                    ? Text(
                                                                        'Tipo Desconto',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20),
                                                                      )
                                                                    : Text(
                                                                        widget
                                                                            .desconto,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.blue,
                                                                            fontSize: 20),
                                                                      ),
                                                            iconSize: 30.0,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blue),
                                                            items: [
                                                              'Valor Real(R\$)',
                                                              'Porcentagem(%)',
                                                            ].map(
                                                              (val) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: val,
                                                                  child:
                                                                      Text(val),
                                                                );
                                                              },
                                                            ).toList(),
                                                            onChanged: (val) {
                                                              setState(
                                                                () {
                                                                  widget.desconto =
                                                                      val;

                                                                  controlProdDesc
                                                                      .clear();
                                                                  controlPorcen
                                                                      .clear();
                                                                },
                                                              );
                                                            },
                                                          ),
                                                          widget.desconto ==
                                                                  "Porcentagem(%)"
                                                              ? SizedBox(
                                                                  height: 60,
                                                                  width: 150,
                                                                  child:
                                                                      TextFormField(
                                                                    validator: Validators.max(
                                                                        percentualMax,
                                                                        "MAX: (${percentualMax}%)"),
                                                                    keyboardType:
                                                                        TextInputType.numberWithOptions(
                                                                            decimal:
                                                                                true),
                                                                    inputFormatters: [
                                                                      FilteringTextInputFormatter
                                                                          .allow(
                                                                              RegExp('[0-9.,]')),
                                                                    ],
                                                                    controller:
                                                                        controlPorcen,
                                                                    enabled:
                                                                        true,
                                                                    decoration: InputDecoration(
                                                                        labelText:
                                                                            '(%)',
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                15,
                                                                            horizontal:
                                                                                20),
                                                                        border: OutlineInputBorder(
                                                                            borderSide: new BorderSide(
                                                                                color: Colors
                                                                                    .red),
                                                                            borderRadius: BorderRadius.circular(
                                                                                10)),
                                                                        focusedBorder: OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(width: 2, color: Colors.blue[900]),
                                                                            borderRadius: BorderRadius.circular(10))),
                                                                  ),
                                                                )
                                                              : Text(""),
                                                          widget.desconto ==
                                                                  "Valor Real(R\$)"
                                                              ? SizedBox(
                                                                  height: 50,
                                                                  width: 100,
                                                                  child:
                                                                      TextField(
                                                                    onChanged:
                                                                        (value) {
                                                                      double
                                                                          valorSubtotal =
                                                                          (double.parse(controlProdValor.text) * double.parse(controlQtd.text)) -
                                                                              double.parse(controlProdDesc.text);

                                                                      alterarSubtotal2(
                                                                          '${_formatValue(valorSubtotal)}');
                                                                    },
                                                                    keyboardType:
                                                                        TextInputType.numberWithOptions(
                                                                            decimal:
                                                                                true),
                                                                    inputFormatters: [
                                                                      FilteringTextInputFormatter
                                                                          .allow(
                                                                              RegExp('[0-9.,]')),
                                                                    ],
                                                                    controller:
                                                                        controlProdDesc,
                                                                    enabled:
                                                                        true,
                                                                    decoration: InputDecoration(
                                                                        labelText:
                                                                            'Desc',
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                15,
                                                                            horizontal:
                                                                                20),
                                                                        border: OutlineInputBorder(
                                                                            borderSide: new BorderSide(
                                                                                color: Colors
                                                                                    .red),
                                                                            borderRadius: BorderRadius.circular(
                                                                                10)),
                                                                        focusedBorder: OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(width: 2, color: Colors.blue[900]),
                                                                            borderRadius: BorderRadius.circular(10))),
                                                                  ),
                                                                )
                                                              : Text(""),
                                                          widget.desconto ==
                                                                  "Tipo Desconto"
                                                              ? Text("")
                                                              : Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                            primary: Colors.blue[
                                                                                900],
                                                                            textStyle:
                                                                                TextStyle()),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: Text(
                                                                            "Cancelar")),
                                                                    Padding(
                                                                        padding:
                                                                            EdgeInsets.all(8.0)),
                                                                    ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                            primary: Colors.blue[
                                                                                900],
                                                                            textStyle:
                                                                                TextStyle()),
                                                                        onPressed:
                                                                            () {
                                                                          if (widget.desconto ==
                                                                              "Porcentagem(%)") {
                                                                            if (formKey.currentState?.validate() ==
                                                                                true) {
                                                                              double valor = valorDescontoPorcent(double.parse(controlPorcen.text), double.parse(controlProdValor.text), double.parse(controlQtd.text));

                                                                              setState(
                                                                                () {
                                                                                  this.valorD = valor;

                                                                                  alterarDesconto("${_formatValue(valorD)}");
                                                                                },
                                                                              );
                                                                              Navigator.pop(context, () {
                                                                                alterarDesconto("${_formatValue(valorD)}");
                                                                              });

                                                                              double valorSubtotal = double.parse(controllerSubtotal.text) - double.parse(controlProdDesc.text);

                                                                              setState(() {
                                                                                controllerSubtotal = TextEditingController(text: '${_formatValue(valorSubtotal)}');
                                                                              });
                                                                            }
                                                                          } else if (widget.desconto ==
                                                                              "Valor Real(R\$)") {
                                                                            Navigator.of(context).pop();
                                                                          }
                                                                        },
                                                                        child: Text(
                                                                            "OK")),
                                                                  ],
                                                                )
                                                        ]),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.grey[350]),
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'Desc',
                                          labelStyle: TextStyle(fontSize: 15),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: SizedBox(
                                          height: 55,
                                          child: Text(
                                              controlProdDesc.text == "0.0"
                                                  ? "${controlProdDesc.text}"
                                                  : "${controlProdDesc.text}"),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : new SizedBox(
                                width: 70,
                                height: 60,
                                child: GestureDetector(
                                  child: TextField(
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[0-9.,]')),
                                    ],
                                    controller: controlProdDesc,
                                    enabled: false,
                                    decoration: InputDecoration(
                                        labelText: 'Desc',
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 20),
                                        filled: true,
                                        fillColor: Colors.grey[350],
                                        border: OutlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Colors.red),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 2,
                                                color: Colors.blue[900]),
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                  ),
                                ),
                              )
                        : new SizedBox(
                            width: 70,
                            height: 60,
                            child: GestureDetector(
                              child: TextField(
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp('[0-9.,]')),
                                ],
                                controller: controlProdDesc,
                                enabled: false,
                                decoration: InputDecoration(
                                    labelText: 'Desc',
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 20),
                                    filled: true,
                                    fillColor: Colors.grey[350],
                                    border: OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.red),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 2, color: Colors.blue[900]),
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                            ),
                          ),
                    Padding(padding: EdgeInsets.all(4)),
                    new SizedBox(
                      width: SizeConfig.screenWidth - 280,
                      height: 50,
                      child: GestureDetector(
                        child: TextField(
                          controller: controllerSubtotal,
                          enabled: false,
                          decoration: InputDecoration(
                              labelText: 'Subtotal',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              filled: true,
                              fillColor: Colors.grey[350],
                              border: OutlineInputBorder(
                                  borderSide: new BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: Colors.blue[900]),
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.all(4)),
                temGrade != true
                    ? Container()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(width: 1),
                                  borderRadius: BorderRadius.circular(8.0)),
                              padding: const EdgeInsets.all(0.0),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: SizedBox(
                                  width: SizeConfig.screenWidth - 40,
                                  child: DropdownButton(
                                    icon: Visibility(
                                        visible: false,
                                        child: Icon(Icons.arrow_downward)),
                                    underline: Text(""),
                                    hint: widget.cor == null
                                        ? Text(
                                            'Cor',
                                            style: TextStyle(fontSize: 18),
                                          )
                                        : Text(
                                            "Cor: " + widget.cor,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                    iconSize: 30.0,
                                    style: TextStyle(color: Colors.blue),
                                    items: cores.map((dynamic map) {
                                      setState(() {
                                        nomeCor = widget.cor;
                                      });
                                      return new DropdownMenuItem<dynamic>(
                                        value:
                                            "${map['CORID']},${map['CORNOME']}",
                                        child: new Text(
                                            "Cor: " + map['CORNOME'],
                                            style: new TextStyle(
                                                color: Colors.black)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      var array = val.split(',');

                                      setState(
                                        () {
                                          idCor = int.parse(array[0]);
                                          selected = true;
                                          buscarTamanhos(
                                              array[0],
                                              idProd.toString(),
                                              empresa.EMPID.toString());
                                          widget.cor = array[1];
                                          widget.grade = 'Selecione o Tamanho';
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          selected == false
                              ? Container()
                              : Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, top: 8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(width: 1),
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: SizedBox(
                                        width: SizeConfig.screenWidth - 40,
                                        child: DropdownButton(
                                          icon: Visibility(
                                              visible: false,
                                              child:
                                                  Icon(Icons.arrow_downward)),
                                          underline: Text(""),
                                          hint: widget.grade == null
                                              ? Text(
                                                  'Grade',
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                )
                                              : Text(
                                                  "Tam: " + widget.grade,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18),
                                                ),
                                          iconSize: 30.0,
                                          style: TextStyle(color: Colors.blue),
                                          items: tamanhos.map((dynamic map) {
                                            return new DropdownMenuItem<
                                                dynamic>(
                                              value:
                                                  "${map['TAMID']},${map['TAMNOME']},${map['LOPQTD']}",
                                              child: new Text(
                                                  "Tam: " +
                                                      map['TAMNOME'] +
                                                      ", QTD: ${_formatValue(double.parse(map['LOPQTD']))}",
                                                  style: new TextStyle(
                                                      color: Colors.black)),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            var arr = val.split(',');

                                            print(arr[0]);

                                            var cfgNome =
                                                configuracoesModel.CFGNOME;
                                            var cfgValor =
                                                configuracoesModel.CFGVALOR;

                                            if (cfgNome ==
                                                    "bloqueaorcestzero" &&
                                                cfgValor == 0) {
                                              setState(
                                                () {
                                                  semEstoque = false;
                                                  idGrade = int.parse(arr[0]);
                                                  widget.grade = arr[1];
                                                  qtdMax = double.parse(
                                                      arr[2].toString());
                                                },
                                              );
                                            } else {
                                              if (arr[2] == '0.000') {
                                                Fluttertoast.showToast(
                                                    msg: "Produto sem estoque");

                                                setState(
                                                  () {
                                                    semEstoque = true;
                                                    idGrade = 0;
                                                    widget.grade =
                                                        "Selecione o Tamanho";
                                                  },
                                                );
                                              } else {
                                                setState(
                                                  () {
                                                    semEstoque = false;
                                                    idGrade = int.parse(arr[0]);
                                                    widget.grade = arr[1];
                                                    qtdMax = double.parse(
                                                        arr[2].toString());
                                                  },
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                Padding(padding: EdgeInsets.all(4)),
                Row(
                  children: [
                    Padding(padding: EdgeInsets.all(8)),
                    new SizedBox(
                      width: SizeConfig.screenWidth - 27,
                      height: 55,
                      child: GestureDetector(
                        onDoubleTap: () {},
                        child: TextField(
                          controller: controlProdObs,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              labelText: 'Observações',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              filled: true,
                              fillColor: Colors.grey[350],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: Colors.blue[900]),
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.all(4)),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Row(
                    children: [
                      Padding(padding: EdgeInsets.all(8)),
                      new SizedBox(
                          width: 150,
                          height: 45,
                          child: RaisedButton(
                              child: Row(
                                children: [Icon(Icons.done), Text("CONFIRMAR")],
                              ),
                              onPressed: () async {
                                getLOCID(empid);

                                if (double.parse(controlQtd.text) == 0.0) {
                                  Fluttertoast.showToast(
                                      msg: "Quantidade inválida!");
                                } else {
                                  focusNodeRef.requestFocus();
                                  if (controlProdNome.text.isEmpty) {
                                    Fluttertoast.showToast(
                                        msg: "Busque o produto primeiro!");
                                  } else {
                                    if (resetDesconto == true &&
                                        config.TIPODESCONTO == 0) {
                                      Fluttertoast.showToast(
                                          msg:
                                              "Primeiro Zere o desconto para continuar à adicionar Produtos");
                                    } else {
                                      setState(() {
                                        temGrade = false;
                                      });

                                      if (semGrade == true) {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Produto não adicionado, produto sem estoque!");
                                      } else {
                                        if (widget.cor == "Selecione a Cor" ||
                                            widget.grade ==
                                                "Selecione o Tamanho") {
                                          setState(() {
                                            temGrade = true;
                                            widget.cor = 'Selecione a Cor';
                                            widget.grade =
                                                'Selecione o Tamanho';
                                          });
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Produto não adicionado, selecione uma grade cor e tamanho");
                                        } else {
                                          if (semEstoque == true) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Produto não adicionado, selecione uma grade com estoque");

                                            setState(() {
                                              temGrade = true;
                                              widget.cor = 'Selecione a Cor';
                                              widget.grade =
                                                  'Selecione o Tamanho';
                                            });
                                          } else {
                                            var cfgNome =
                                                configuracoesModel.CFGNOME;
                                            var cfgValor =
                                                configuracoesModel.CFGVALOR;

                                            if (cfgNome ==
                                                    "bloqueaorcestzero" &&
                                                cfgValor == 0) {
                                              if (controlProdId
                                                  .text.isNotEmpty) {
                                                Produto prod = Produto();
                                                prod.PROID =
                                                    enabledEdit == false
                                                        ? idProdEdit
                                                        : idProd;
                                                prod.PROREFERENCIA =
                                                    controlProdId.text;
                                                prod.PRONOME =
                                                    controlProdNome.text;
                                                prod.PROOBS =
                                                    controlProdObs.text.isEmpty
                                                        ? ""
                                                        : controlProdObs.text;
                                                prod.PRODESCRICAO =
                                                    controlProdDesc.text;
                                                prod.PROVALOR = double.parse(
                                                    controlProdValor.text);
                                                prod.quantity = double.parse(
                                                    controlQtd.text + ".0");
                                                prod.TAMANHO = widget.grade;
                                                prod.COR = widget.cor;
                                                prod.corid = idCor;
                                                prod.tamid = idGrade;
                                                prod.dados =
                                                    prodid.dados == "null" ||
                                                            prodid.dados == null
                                                        ? produto.dados
                                                        : prodid.dados;

                                                baixarEstoqueProduto(
                                                    prod.PROID,
                                                    prod.corid,
                                                    prod.tamid,
                                                    empid,
                                                    prod.quantity);

                                                estoquePro =
                                                    await estoqueProduto(
                                                        prod.PROID,
                                                        prod.corid,
                                                        prod.tamid,
                                                        empresa.EMPID);

                                                setState(() {
                                                  if (estoquePro > 0.0) {
                                                    estoquePro = estoquePro;
                                                  }
                                                });

                                                print("Estoque pro: " +
                                                    estoquePro.toString());

                                                setState(() {
                                                  widget.grade =
                                                      "Selecione o Tamanho";
                                                  widget.cor =
                                                      "Selecione a Cor";
                                                });
                                                if (controlProdDesc
                                                    .text.isEmpty) {
                                                  prod.PROVALORDESCONTO = 0.0;
                                                } else {
                                                  prod.PROVALORDESCONTO =
                                                      double.parse(
                                                          "${controlProdDesc.text}");
                                                }

                                                prod.PRECOCUSTO = double.parse(
                                                    controlProdValorCusto.text);

                                                if (prod.quantity > 0.0) {
                                                  if (widget.list.isEmpty) {
                                                    widget.list.add(prod);

                                                    limpar();
                                                    print(
                                                        'adicionando lista vazia');
                                                  } else {
                                                    if (enabledEdit == false) {
                                                      print("editando");

                                                      addItemIndex(
                                                          indexEdit, prod);

                                                      voltarEstoqueProduto(
                                                          prod.PROID,
                                                          prod.corid,
                                                          prod.tamid,
                                                          empid,
                                                          qtdResid);

                                                      limpar();

                                                      setState(() {
                                                        enabledEdit = true;
                                                      });
                                                    } else {
                                                      if (configuracoesModel
                                                              .CFGVALOR !=
                                                          0) {
                                                        if (buscarProduto(
                                                                    prod) ==
                                                                true &&
                                                            prod.quantity >=
                                                                estoquePro) {
                                                          setState(() {
                                                            temGrade = true;
                                                          });
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Produto não adicionado, quantidade indisponível");
                                                        } else {
                                                          setState(() {
                                                            resultqtd =
                                                                somarQtd(prod);
                                                          });

                                                          print("Estoque pro: " +
                                                              estoquePro
                                                                  .toString());

                                                          if (resultqtd +
                                                                  prod.quantity <=
                                                              estoquePro) {
                                                            widget.list
                                                                .add(prod);

                                                            setState(() {
                                                              resultqtd =
                                                                  somarQtd(
                                                                      prod);
                                                            });

                                                            print(resultqtd);
                                                            print("aqui add");

                                                            limpar();
                                                          } else {
                                                            setState(() {
                                                              temGrade = true;
                                                            });
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Produto não adicionado, quantidade indisponível");
                                                          }
                                                        }
                                                      } else {
                                                        widget.list.add(prod);
                                                        limpar();
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            } else {
                                              if (qtdMax <
                                                  double.parse(
                                                      controlQtd.text)) {
                                                setState(() {
                                                  temGrade = true;
                                                });
                                                print("qtdmax" +
                                                    qtdMax.toString());
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Produto não adicionado, quantidade indisponível");
                                              } else {
                                                if (controlProdId
                                                    .text.isNotEmpty) {
                                                  Produto prod = Produto();
                                                  prod.PROID =
                                                      enabledEdit == false
                                                          ? idProdEdit
                                                          : idProd;
                                                  prod.PROREFERENCIA =
                                                      controlProdId.text;
                                                  prod.PRONOME =
                                                      controlProdNome.text;
                                                  prod.PROOBS = controlProdObs
                                                          .text.isEmpty
                                                      ? ""
                                                      : controlProdObs.text;
                                                  prod.PRODESCRICAO =
                                                      controlProdDesc.text;
                                                  prod.PROVALOR = double.parse(
                                                      controlProdValor.text);
                                                  prod.quantity = double.parse(
                                                      controlQtd.text + ".0");
                                                  prod.TAMANHO = widget.grade;
                                                  prod.COR = widget.cor;
                                                  prod.corid = idCor;
                                                  prod.tamid = idGrade;
                                                  prod.dados = prodid.dados ==
                                                              "null" ||
                                                          prodid.dados == null
                                                      ? produto.dados
                                                      : prodid.dados;

                                                  baixarEstoqueProduto(
                                                      prod.PROID,
                                                      prod.corid,
                                                      prod.tamid,
                                                      empid,
                                                      prod.quantity);

                                                  estoquePro =
                                                      await estoqueProduto(
                                                          prod.PROID,
                                                          prod.corid,
                                                          prod.tamid,
                                                          empresa.EMPID);

                                                  setState(() {
                                                    if (estoquePro > 0.0) {
                                                      estoquePro = estoquePro;
                                                    }
                                                  });

                                                  print("Estoque pro: " +
                                                      estoquePro.toString());

                                                  setState(() {
                                                    widget.grade =
                                                        "Selecione o Tamanho";
                                                    widget.cor =
                                                        "Selecione a Cor";
                                                  });
                                                  if (controlProdDesc
                                                      .text.isEmpty) {
                                                    prod.PROVALORDESCONTO = 0.0;
                                                  } else {
                                                    prod.PROVALORDESCONTO =
                                                        double.parse(
                                                            "${controlProdDesc.text}");
                                                  }

                                                  prod.PRECOCUSTO =
                                                      double.parse(
                                                          controlProdValorCusto
                                                              .text);

                                                  if (prod.quantity > 0.0) {
                                                    if (widget.list.isEmpty) {
                                                      widget.list.add(prod);

                                                      limpar();
                                                      print(
                                                          'adicionando lista vazia');
                                                    } else {
                                                      if (enabledEdit ==
                                                          false) {
                                                        print("editando");

                                                        addItemIndex(
                                                            indexEdit, prod);

                                                        voltarEstoqueProduto(
                                                            prod.PROID,
                                                            prod.corid,
                                                            prod.tamid,
                                                            empid,
                                                            qtdResid);

                                                        limpar();

                                                        setState(() {
                                                          enabledEdit = true;
                                                        });
                                                      } else {
                                                        if (buscarProduto(
                                                                    prod) ==
                                                                true &&
                                                            prod.quantity >=
                                                                estoquePro) {
                                                          setState(() {
                                                            temGrade = true;
                                                          });
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Produto não adicionado, quantidade indisponível");
                                                        } else {
                                                          setState(() {
                                                            resultqtd =
                                                                somarQtd(prod);
                                                          });

                                                          print("Estoque pro: " +
                                                              estoquePro
                                                                  .toString());

                                                          if (resultqtd +
                                                                  prod.quantity <=
                                                              estoquePro) {
                                                            widget.list
                                                                .add(prod);

                                                            setState(() {
                                                              resultqtd =
                                                                  somarQtd(
                                                                      prod);
                                                            });

                                                            print(resultqtd);
                                                            print("aqui add");

                                                            limpar();
                                                          } else {
                                                            setState(() {
                                                              temGrade = true;
                                                            });
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Produto não adicionado, quantidade indisponível");
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              })),
                      Padding(padding: EdgeInsets.all(8)),
                      new SizedBox(
                          width: SizeConfig.screenWidth - 195,
                          height: 45,
                          child: RaisedButton(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete),
                                  Padding(padding: EdgeInsets.all(4)),
                                  Text("Limpar")
                                ],
                              ),
                              onPressed: () {
                                setState(() {
                                  enabledEdit = true;
                                  temGrade = false;
                                });

                                Provider.of<ProdutoProvider>(context,
                                        listen: false)
                                    .limparProduto();
                                controlProdId.clear();
                                controlProdDesc.clear();
                                controlProdObs.clear();
                                controlProdNome.clear();
                                controlProdValor.clear();
                                controlQtd.clear();
                                controlDescontoItem.clear();
                                controllerSubtotal.clear();
                              })),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 20),
            child: widget.list.isEmpty
                ? SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Lista de Produtos",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                )
                              ],
                            ),
                          ),
                          width: 750,
                          height: 50,
                          decoration: BoxDecoration(color: Colors.blue[900]),
                        ),
                        Padding(padding: EdgeInsets.all(2)),
                        Container(
                          width: 700,
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                          ),
                        )
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Lista de Produtos",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                )
                              ],
                            ),
                          ),
                          width: 750,
                          height: 50,
                          decoration: BoxDecoration(color: Colors.blue[900]),
                        ),
                        Padding(padding: EdgeInsets.all(2)),
                        Container(
                          width: 700,
                          height:
                              (MediaQuery.of(context).size.height * 0.74) - 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                          ),
                          child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    Container(
                                      height: 212,
                                      width: MediaQuery.of(context).size.width,
                                      child: Consumer<ProdutoProvider>(
                                        builder: (context, cart, child) => Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            GestureDetector(
                                              onDoubleTap: () {
                                                limpar();

                                                valoresVendaEdit(
                                                    widget.list, index);

                                                print(valoresProd);

                                                setState(() {
                                                  buscarTamanhos(
                                                      widget.list[index].corid
                                                          .toString(),
                                                      widget.list[index].PROID
                                                          .toString(),
                                                      empresa.EMPID.toString());

                                                  controlProdId =
                                                      TextEditingController(
                                                          text:
                                                              "${widget.list[index].PROREFERENCIA}");

                                                  enabledEdit = false;
                                                  selected = true;
                                                  widget.cor =
                                                      widget.list[index].COR;
                                                  widget.grade = widget
                                                      .list[index].TAMANHO;

                                                  qtdResid = widget
                                                      .list[index].quantity;

                                                  idCor =
                                                      widget.list[index].corid;
                                                  idGrade =
                                                      widget.list[index].tamid;
                                                });

                                                Provider.of<ProdutoProvider>(
                                                        context,
                                                        listen: false)
                                                    .addProd(
                                                        widget.list[index]);

                                                setState(() {
                                                  indexEdit = index;
                                                });
                                              },
                                              child: Card(
                                                child: Row(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        new Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16.0),
                                                          width: SizeConfig
                                                                  .screenWidth -
                                                              28,
                                                          child: new Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Text(
                                                                'REF: ${widget.list[index].PROREFERENCIA}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(
                                                                '${widget.list[index].PRONOME}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'Qtd: ${widget.list[index].quantity}',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16.0,
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8.0)),
                                                                  Text(
                                                                      'Valor (un): ${_formatValue(widget.list[index].PROVALOR)}',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16.0,
                                                                      )),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  config.TIPODESCONTO ==
                                                                          1
                                                                      ? widget.list[index].PROVALORDESCONTO !=
                                                                              null
                                                                          ? Text(
                                                                              'Desc: ${widget.list[index].PROVALORDESCONTO}',
                                                                              style:
                                                                                  TextStyle(
                                                                                fontSize: 16.0,
                                                                              ))
                                                                          : Text(
                                                                              "")
                                                                      : Text(
                                                                          ""),
                                                                  Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              4)),
                                                                  config.TIPODESCONTO ==
                                                                          1
                                                                      ? widget.list[index].PROVALORDESCONTO !=
                                                                              null
                                                                          ? Text(
                                                                              'Total: ${_formatValueDesconto(cart.total(widget.list[index].quantity, widget.list[index].PROVALOR), widget.list[index].PROVALORDESCONTO)}',
                                                                              style:
                                                                                  TextStyle(
                                                                                fontSize: 16.0,
                                                                              ))
                                                                          : Text(
                                                                              'Total: ${_formatValue(cart.total(widget.list[index].quantity, widget.list[index].PROVALOR))}',
                                                                              style:
                                                                                  TextStyle(
                                                                                fontSize: 16.0,
                                                                              ))
                                                                      : Text(
                                                                          'Total: ${_formatValue(cart.total(widget.list[index].quantity, widget.list[index].PROVALOR))}',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16.0,
                                                                          )),
                                                                ],
                                                              ),
                                                              Text(
                                                                "Grade: ${widget.list[index].COR}, ${widget.list[index].TAMANHO}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16.0),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  top: 10,
                                                                  left: 100,
                                                                ),
                                                                child: ElevatedButton
                                                                    .icon(
                                                                        style: ButtonStyle(
                                                                            backgroundColor: MaterialStateProperty.all(Colors.blue[
                                                                                900])),
                                                                        onPressed:
                                                                            () {
                                                                          if (config.TIPODESCONTO ==
                                                                              1) {
                                                                            setState(() {
                                                                              widget.list.remove(widget.list[index]);

                                                                              total = totalPrice();
                                                                              items = widget.list.length;

                                                                              print(widget.list.length);
                                                                              print(total);
                                                                            });
                                                                          } else {
                                                                            if (resetDesconto ==
                                                                                true) {
                                                                              Fluttertoast.showToast(msg: "Para remover da lista remova primeiro o desconto!");
                                                                            } else {
                                                                              setState(() {
                                                                                widget.list.remove(widget.list[index]);

                                                                                total = totalPrice();
                                                                                items = widget.list.length;

                                                                                print(widget.list.length);
                                                                                print(total);
                                                                              });
                                                                            }
                                                                          }
                                                                        },
                                                                        icon: Icon(Icons
                                                                            .delete_forever),
                                                                        label: Text(
                                                                            "Remover")),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              itemCount: widget.list.length),
                        ),
                      ],
                    ),
                  ),
          ),
          Padding(padding: EdgeInsets.all(2)),
          Padding(
            padding: const EdgeInsets.only(right: 10.0, left: 10.0),
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Items QTD: ${items}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(left: 50)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            config.TIPODESCONTO == 1
                                ? Text(
                                    "Total: R\$:  ${_formatValue(totalPriceProd())}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  )
                                : Text(
                                    "Total: R\$:  ${_formatValue(totalPriceProd())}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                            config.TIPODESCONTO == 0 &&
                                    double.parse(descontoControl.text) > 0.0
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      config.TIPODESCONTO == 0
                                          ? Text(
                                              "Desconto: R\$:  ${_formatValue(double.parse(descontoControl.text))}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            )
                                          : Text(
                                              "Desconto: R\$:  ${_formatValue(total2 - double.parse(descontoControl.text))}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                      double.parse(descontoControl.text) > 0.0
                                          ? Text(
                                              "Total (Desc): R\$:  ${_formatValue(totalPriceProd() - double.parse(descontoControl.text))}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            )
                                          : Container(),
                                    ],
                                  )
                                : widget.list.length > 1
                                    ? descontoControl.text == "0.0"
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              config.TIPODESCONTO == 1
                                                  ? Text(
                                                      "Desconto: R\$:  ${_formatValue(totalDesconto2())}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15),
                                                    )
                                                  : Container(),
                                              totalDesconto2() > 0.0
                                                  ? Text(
                                                      "Total (Desc): R\$:  ${_formatValue(totalPriceProd() - totalDesconto2())}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15),
                                                    )
                                                  : Container(),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              config.TIPODESCONTO == 1
                                                  ? Text(
                                                      "Desconto: R\$:  ${_formatValue(totalDesconto2())}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15),
                                                    )
                                                  : Container(),
                                              totalDesconto2() > 0.0
                                                  ? Text(
                                                      "Total (Desc): R\$:  ${_formatValue(totalPriceProd() - totalDesconto2())}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15),
                                                    )
                                                  : Container(),
                                            ],
                                          )
                                    : totalDesconto2() == 0.0
                                        ? Container()
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              config.TIPODESCONTO == 1
                                                  ? Text(
                                                      "Desconto: R\$:  ${_formatValue(totalDesconto2())}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15),
                                                    )
                                                  : Container(),
                                              config.TIPODESCONTO == 0 &&
                                                      descontoControl.text ==
                                                          "0.0"
                                                  ? Container()
                                                  : Text(
                                                      "Total (Desc): R\$:  ${_formatValue(totalPriceProd() - totalDesconto2())}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15),
                                                    ),
                                            ],
                                          )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              width: SizeConfig.screenWidth,
              height: 80,
              decoration: BoxDecoration(color: Colors.blue[900]),
            ),
          ),
          config.HABDESCONTO == 1
              ? config.TIPODESCONTO == 0
                  ? Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                child: new SizedBox(
                              width: 150,
                              height: 60,
                              child: GestureDetector(
                                onTap: () {
                                  if (widget.list.isEmpty) {
                                    Mensagem();
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: StatefulBuilder(
                                            // You need this, notice the parameters below:
                                            builder: (BuildContext context,
                                                StateSetter setState) {
                                              return Form(
                                                key: formKey,
                                                child: Column(
                                                    // Then, the content of your dialog.
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      DropdownButton(
                                                        hint: widget.desconto ==
                                                                null
                                                            ? Text(
                                                                'Selecione o tipo de desconto',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20),
                                                              )
                                                            : Text(
                                                                widget.desconto,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue,
                                                                    fontSize:
                                                                        20),
                                                              ),
                                                        iconSize: 30.0,
                                                        style: TextStyle(
                                                            color: Colors.blue),
                                                        items: [
                                                          'Valor Real(R\$)',
                                                          'Porcentagem(%)',
                                                        ].map(
                                                          (val) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: val,
                                                              child: Text(val),
                                                            );
                                                          },
                                                        ).toList(),
                                                        onChanged: (val) {
                                                          setState(
                                                            () {
                                                              widget.desconto =
                                                                  val;
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      widget.desconto ==
                                                              "Porcentagem(%)"
                                                          ? SizedBox(
                                                              height: 60,
                                                              width: 150,
                                                              child:
                                                                  TextFormField(
                                                                validator: Validators.max(
                                                                    percentualMax,
                                                                    "MAX: (${percentualMax}%)"),
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                controller:
                                                                    controlPorcen,
                                                                enabled: true,
                                                                decoration: InputDecoration(
                                                                    labelText:
                                                                        '(%)',
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            15,
                                                                        horizontal:
                                                                            20),
                                                                    border: OutlineInputBorder(
                                                                        borderSide: new BorderSide(
                                                                            color: Colors
                                                                                .red),
                                                                        borderRadius: BorderRadius.circular(
                                                                            10)),
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            width:
                                                                                2,
                                                                            color: Colors.blue[
                                                                                900]),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10))),
                                                              ),
                                                            )
                                                          : Text(""),
                                                      widget.desconto ==
                                                              "Valor Real(R\$)"
                                                          ? SizedBox(
                                                              height: 50,
                                                              width: 100,
                                                              child: TextField(
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                controller:
                                                                    descontoControl,
                                                                enabled: true,
                                                                decoration: InputDecoration(
                                                                    labelText:
                                                                        'Desconto',
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            15,
                                                                        horizontal:
                                                                            20),
                                                                    border: OutlineInputBorder(
                                                                        borderSide: new BorderSide(
                                                                            color: Colors
                                                                                .red),
                                                                        borderRadius: BorderRadius.circular(
                                                                            10)),
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            width:
                                                                                2,
                                                                            color: Colors.blue[
                                                                                900]),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10))),
                                                              ),
                                                            )
                                                          : Text(""),
                                                      widget.desconto ==
                                                              "Tipo Desconto"
                                                          ? Text("")
                                                          : Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                        primary:
                                                                            Colors.blue[
                                                                                900],
                                                                        textStyle:
                                                                            TextStyle()),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: Text(
                                                                        "Cancelar")),
                                                                Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0)),
                                                                ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                        primary:
                                                                            Colors.blue[
                                                                                900],
                                                                        textStyle:
                                                                            TextStyle()),
                                                                    onPressed:
                                                                        () {
                                                                      if (widget
                                                                              .desconto ==
                                                                          "Porcentagem(%)") {
                                                                        if (formKey.currentState?.validate() ==
                                                                            true) {
                                                                          double
                                                                              valor =
                                                                              valorDescontoPorcent2(double.parse(controlPorcen.text), totalPriceProd());

                                                                          this.valorD =
                                                                              valor;

                                                                          alterarDescontoControl(
                                                                              "${_formatValue(valorD)}");

                                                                          Navigator.pop(
                                                                              context,
                                                                              () {
                                                                            alterarDescontoControl("${_formatValue(valorD)}");
                                                                          });

                                                                          focusNodeObs
                                                                              .requestFocus();
                                                                        }
                                                                      } else if (widget
                                                                              .desconto ==
                                                                          "Valor Real(R\$)") {
                                                                        if (double.parse(descontoControl.text) >
                                                                            total2) {
                                                                          Fluttertoast.showToast(
                                                                              msg: "Valor de Desconto maior do que valor total!",
                                                                              timeInSecForIosWeb: 4);

                                                                          alterarDescontoControl(
                                                                              "0.0");
                                                                        }

                                                                        if (descontoControl.text !=
                                                                            "0.0") {
                                                                          setState(
                                                                              () {
                                                                            resetDesconto =
                                                                                true;
                                                                          });
                                                                        }

                                                                        alterarDescontoControl(
                                                                            descontoControl.text);

                                                                        Navigator.of(context)
                                                                            .pop();

                                                                        focusNodeObs
                                                                            .requestFocus();
                                                                      }
                                                                    },
                                                                    child: Text(
                                                                        "OK")),
                                                              ],
                                                            )
                                                    ]),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[350]),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Desconto',
                                      labelStyle: TextStyle(fontSize: 15),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: SizedBox(
                                      height: 100,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, top: 2),
                                        child: Text(
                                            descontoControl.text == "0.0"
                                                ? "${descontoControl.text}"
                                                : "${descontoControl.text}"),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          ),
                        ),
                        double.parse(descontoControl.text) <= 0
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // retorna um objeto do tipo Dialog
                                      return AlertDialog(
                                        title: new Text(
                                            "Tem certeza que deseja excluir o desconto?",
                                            style: TextStyle(
                                              color: Colors.black,
                                            )),
                                        actions: <Widget>[
                                          // define os botões na base do dialogo
                                          new ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.blue[900]),
                                            ),
                                            child: new Text("Não"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          new ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.red),
                                            ),
                                            child: new Text("Excluir"),
                                            onPressed: () {
                                              setState(() {
                                                resetDesconto = false;
                                              });
                                              focusNodeObs.requestFocus();
                                              alterarDescontoControl("0.0");
                                              alterarDescontoControlPorc("0.0");
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.blue[900],
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                      ],
                    )
                  : Text("")
              : Text(""),
          config.TELAFORMAPAGAMENTO == 1
              ? widget.list.isEmpty
                  ? Container()
                  : Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: DropdownButton(
                            hint: widget.forma == null
                                ? Text(
                                    'Forma De Pagamento',
                                    style: TextStyle(fontSize: 18),
                                  )
                                : Text(
                                    widget.forma,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18),
                                  ),
                            iconSize: 30.0,
                            style: TextStyle(color: Colors.blue),
                            items: formasPagamento.map((dynamic map) {
                              return new DropdownMenuItem<dynamic>(
                                onTap: () {
                                  setState(() {
                                    formaNome = map['FPGNOME'];
                                    FPGTIPO = int.parse(map['FPGTIPO']);

                                    controlOrcObs = TextEditingController(
                                        text: "Pagamento: $formaNome");
                                  });
                                },
                                value: map['FPGNOME'],
                                child: new Text(map['FPGNOME'],
                                    style: new TextStyle(color: Colors.black)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(
                                () {
                                  widget.forma = val;
                                  getFormasPrazo();
                                },
                              );
                            },
                          ),
                        ),
                        FPGTIPO != 5
                            ? Text("")
                            : Padding(
                                padding: const EdgeInsets.only(right: 200),
                                child: DropdownButton(
                                  hint: widget.condPagamento == null
                                      ? Text(
                                          'Condições',
                                          style: TextStyle(fontSize: 18),
                                        )
                                      : Text(
                                          widget.condPagamento,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        ),
                                  iconSize: 30.0,
                                  style: TextStyle(color: Colors.blue),
                                  items: formasPrazo.map((dynamic map) {
                                    return new DropdownMenuItem<dynamic>(
                                      value: map['FPRNOME'],
                                      child: new Text(map['FPRNOME'],
                                          style: new TextStyle(
                                              color: Colors.black)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(
                                      () {
                                        controlOrcObs.clear();
                                        widget.condPagamento = val;
                                        controlOrcObs = TextEditingController(
                                            text:
                                                "Pagamento: ${formaNome}  \n ${val}");
                                      },
                                    );
                                  },
                                ),
                              ),
                      ],
                    )
              : Text(""),
          obsOrcamento == null
              ? Padding(
                  padding:
                      const EdgeInsets.only(right: 10.0, top: 10.0, left: 10.0),
                  child: Container(
                    child: new SizedBox(
                      width: SizeConfig.screenWidth,
                      height: 100,
                      child: GestureDetector(
                        onDoubleTap: () {},
                        child: TextField(
                          focusNode: focusNodeObs,
                          controller: controlOrcObs,
                          decoration: InputDecoration(
                              labelText: 'Observações',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 30, horizontal: 20),
                              filled: true,
                              fillColor: Colors.grey[350],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: Colors.blue[900]),
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: new SizedBox(
                  width: 220,
                  height: 45,
                  child: FlatButton(
                    child: enebledButton == false
                        ? Text(
                            'ALTERAR',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          )
                        : CircularProgressIndicator(),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Colors.blue[900],
                    textColor: Colors.white,
                    onPressed: () {
                      getLOCID(empid);
                      if (int.parse(controlParcelas.text) >= 1) {
                        double totalparcela =
                            total / int.parse(controlParcelas.text);

                        setState(() {
                          controlOrcObs.clear();
                          controlOrcObs = TextEditingController(
                              text: controlOrcObs.text +
                                  " Pagamento parcelado: ${controlParcelas.text} de R\$ ${_formatValue(totalparcela)}");
                        });
                      }

                      if (controllerClienteNome != null) {
                        if (widget.list.isNotEmpty) {
                          _dateformat =
                              DateFormat('yyyy-MM-dd').format(_dateTime);

                          Orcamento orcamento = Orcamento(
                              ORCID: widget.orc.ORCID,
                              VENID: widget.orc.VENID,
                              CLIID: widget.orc.CLIID,
                              ORCOBS: controlOrcObs.text,
                              ORCFORMAPAGAMENTOTXT: formaNome,
                              ORCVALORTOTAL: config.TIPODESCONTO == 0
                                  ? totalPriceProd() -
                                      double.parse(descontoControl.text)
                                  : totalPrice2(),
                              ORCOBS2: config.TIPODESCONTO == 1
                                  ? totalDesconto2().toString()
                                  : descontoControl.text,
                              EMPID: empid,
                              ORCHORA: _horaAtual,
                              ORCDATA: _dateformat,
                              produtos: widget.list);

                          if (formaNome == "" &&
                              config.TELAFORMAPAGAMENTO == 1) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // retorna um objeto do tipo Dialog
                                return AlertDialog(
                                  backgroundColor: Colors.red,
                                  title: new Text(
                                    "Error: Selecione a forma de pagamento!",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  actions: <Widget>[
                                    // define os botões na base do dialogo
                                    new ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.blue[900]),
                                      ),
                                      child: new Text("Fechar"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            if (locid != 0) {
                              if (enebledButton == false) {
                                deleteItem(widget.orc.ORCID);

                                add(orcamento);
                                setState(() {
                                  enebledButton = true;
                                });
                              }
                            }
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // retorna um objeto do tipo Dialog
                              return AlertDialog(
                                backgroundColor: Colors.red,
                                title: new Text(
                                  "Error: Nenhum produto adicionado ao pedido!",
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: new Text(
                                    "adicione produtos ao pedido para continuar",
                                    style: TextStyle(color: Colors.white)),
                                actions: <Widget>[
                                  // define os botões na base do dialogo
                                  new ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.blue[900]),
                                    ),
                                    child: new Text("Fechar"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // retorna um objeto do tipo Dialog
                            return AlertDialog(
                              backgroundColor: Colors.red,
                              title: new Text(
                                "Error: Nenhum cliente selecionado!",
                                style: TextStyle(color: Colors.white),
                              ),
                              content: new Text(
                                  "Selecione um cliente para continuar",
                                  style: TextStyle(color: Colors.white)),
                              actions: <Widget>[
                                // define os botões na base do dialogo
                                new ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.blue[900]),
                                  ),
                                  child: new Text("Fechar"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  )),
            ),
          ),
        ],
      ),
    );
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

  void MensagemClienteError() {
    var alert = new AlertDialog(
      title: new Text("Cliente não encontrado"),
      content: new Text("Verifique o id digitado!"),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void ValorNaoEncontrado() {
    var alert = new AlertDialog(
      title: new Text("valor nao encontrado"),
      content: new Text("Verifique o id"),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void MensagemProdutoError() {
    var alert = new AlertDialog(
      title: new Text("Produto não encontrado"),
      content: new Text("Verifique o id digitado!"),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void Mensagem() {
    var alert = new AlertDialog(
      title: new Text("Selecione o Produto para adicionar o desconto"),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  Future getDataProd() async {
    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/buscarProdutos.php"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);
      setState(() {
        produtosList = obj['result'];
      });
    } catch (e) {
      print("error");
    }
  }

  Future getDataClientes() async {
    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/clientes/buscarClientes.php"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);

      setState(() {
        clientesList = obj['result'];
      });

      return obj['result'];
    } catch (e) {
      print("error");
    }
  }

  Future getPedido(int id) async {
    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/mostrarPedido.php?pedid=${id}"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);

      setState(() {
        orcamentos = obj['result'];
      });
      return;
    } catch (e) {
      print("error");
    }
  }

  Future getDataVend() async {
    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/vendedores/buscarVendedores.php"),
          body: c.toJson());

      var obj = convert.json.decode(response.body);

      setState(() {
        vendedoresList = obj['result'];
      });
    } catch (e) {
      print("error");
    }
  }

  add(Orcamento pedido) async {
    await _adicionarPedido(pedido).then((sucess) => {
          Fluttertoast.showToast(
              msg: "Orçamento alterado com sucesso!",
              backgroundColor: Colors.blue[900],
              textColor: Colors.white,
              fontSize: 16.0),
        });
  }

  Produto produtoB;

  Future<String> _adicionarPedido(Orcamento orcamento) async {
    final result = await http.post(
      'http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/alterarPedido.php?usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}',
      body: orcamento.toJson(),
    );

    if (result.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      getLOCID(empid);
      var obj = convert.json.decode(result.body);

      //print(obj['success']);

      print(obj);
      //orcid = int.parse(obj['ORCID']);

      for (var item in widget.list.reversed) {
        if (config.HABDESCONTO == 1) {
          if (config.TIPODESCONTO == 1) {
            descontoItem = item.PROVALORDESCONTO;
          } else {
            descontoItem =
                double.parse(descontoControl.text) / widget.list.length;
          }
        }

        pedItem = OrcamentoItem(
          ORCID: widget.orc.ORCID,
          PROID: item.PROID,
          ORIQTD: item.quantity,
          ORIDESCONTO: descontoItem,
          ORIVALOR: item.PROVALOR,
          LOCID: locid,
          ORIOBS: item.PROOBS,
          CORID: item.COR == "PADRAO" ? 0 : item.corid,
          TAMID: item.TAMANHO == "PADRAO" ? 0 : item.tamid,
        );

        alterItems(pedItem);
      }

      Navigator.of(context).pop();
      if (mounted) {
        Navigator.of(context).pop();
      }

      return result.body;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Falha ao adicionar o pedido');
    }
  }

  mostrarPedido(int pedid) async {
    await _mostrarPedido(pedid).then((sucess) => {
          print("Pedido encontrado com sucesso!"),
        });
  }

  bool removerADD(int prodid, Produto prod) {
    for (int i = 0; i < widget.list.length; i++) {
      if (widget.list[i].PROID == prodid) {
        widget.list.removeAt(i);
        widget.list.insert(i, prod);
        return true;
      }
    }

    return false;
  }

  _recuperarTotalDesconto() {
    if (Provider.of<ProdutoProvider>(context, listen: false).items.isNotEmpty) {
      List<Produto> list =
          Provider.of<ProdutoProvider>(context, listen: false).items;

      for (var item in list) {
        if (item.PROVALORDESCONTO == null) {
          item.PROVALORDESCONTO = 0.0;
        }
        if (item.PROVALORDESCONTO > 0.0) {
          totalDesconto += item.PROVALORDESCONTO;
        }
      }

      print(totalDesconto);
    }
  }

  Future<String> _mostrarPedido(int orcid) async {
    final result = await http.post(
        'http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/mostrarPedido.php?ORCID=${widget.orc.ORCID}',
        body: c.toJson());

    if (result.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      var obj = convert.json.decode(result.body);

      orcamentos = obj['result'];

      for (var item in orcamentos) {
        orcid = int.parse(item['ORCID']);
        int vendid = int.parse(item['VENID']);
        int cliid = int.parse(item['CLIID']);
        int proid = int.parse(item['PROID']);

        for (var prod in produtolist) {
          if (prod.PROID == proid) {
            produtoB = prod;
          }
        }
      }

      _recuperarTotalDesconto();

      _dateformat = DateFormat('dd-MM-yyyy').format(_dateTime);

      if (config.HABDESCONTO == 1 && config.TIPODESCONTO == 0) {
        total = total - double.parse(descontoControl.text);
        totalDesconto = double.parse(descontoControl.text);
      }

      GeneratePDFState _generatePDFState = GeneratePDFState(
          cliente: cliente,
          vendedor: vendedor,
          produtos: produtolist,
          orcid: orcid,
          total: total,
          totalDesconto: totalDesconto,
          desconto: double.parse(descontoControl.text),
          formaPagamento: formaPagamento.text,
          obsOrcamento: controlOrcObs.text,
          data: _dateformat,
          hora: _horaAtual,
          empresa: empresa);

      try {
        _generatePDFState.generatePDFInvoice();
      } on NetworkImageLoadException {
        print("URL imagem invalida");
      }
      Navigator.pushNamedAndRemoveUntil(
          context, "/telaInicial", (route) => false);

      return result.body;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Não foi possivel mostrar o pedido');
    }
  }

  alterItems(OrcamentoItem pedidoItem) async {
    await _alterarItems(pedidoItem).then((sucess) => {
          print("item adicionado sucesso!"),
        });
  }

  Future<String> voltarEstoqueProduto(
      int proid, int corid, int tamid, int empid, double qtd) async {
    final result = await http.post(
        'http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/voltarEstoque.php?qtd=${qtd}&proid=${proid}&corid=${corid}&tamid=${tamid}&empid=${empid}',
        body: c.toJson());

    if (result.statusCode == 200) {
      print("retornou o estoque do produto $proid  qtd$qtd");

      return result.body;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
  }

  Future<String> _alterarItems(OrcamentoItem pedidoItem) async {
    final result = await http.post(
      'http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/alterarItens.php?usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}',
      body: pedidoItem.toJson(),
    );

    if (result.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var obj = convert.json.decode(result.body);

      print("Mensagem edit orc: " + obj["message"].toString());

      return result.body;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
  }
}
