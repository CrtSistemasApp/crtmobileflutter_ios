import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutteraplicativo/src/models/configuracoes.dart';
import 'package:flutteraplicativo/src/models/formasModel.dart';
import 'package:wc_form_validators/wc_form_validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutteraplicativo/src/models/configEspe.dart';
import 'package:flutteraplicativo/src/view/pedidos/relatorio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as p;
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';

import 'package:flutteraplicativo/src/models/configProvider.dart';
import 'package:flutteraplicativo/src/models/empresaModel.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

Directory _appDocsDir;
enum SingingCharacter { real, porcentagem }

SingingCharacter _character = SingingCharacter.real;

class CadastroPedido extends StatefulWidget {
  String forma = "Forma De Pagamento";
  String tipo = "Documento";
  String condPagamento = "Cond/Pagamento";
  String desconto = "Tipo Desconto";
  String cor = "Selecione a Cor";
  String grade = "Selecione o Tamanho";
  String valorVenda = "Vr.Venda";

  @override
  _CadastroPedidoState createState() => _CadastroPedidoState();
}

class _CadastroPedidoState extends State<CadastroPedido>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List tamcores = [];
  List cores = [];
  FocusNode focusNodeRef;
  FocusNode focusNodeCli;
  bool selected = false;
  List valoresProd = [];
  List tamanhos = [];
  double resultqtd = 0.0;
  bool semEstoque = false;
  bool focus = false;
  ProdutoProvider prodVenda = ProdutoProvider();
  List testList = [
    {"1": "numero"},
    {"2": "sadadsa"},
    {"3": "asdasdsa"},
    {"4": "asdasdasda"}
  ];
  bool resetDesconto = false;
  final formKey = GlobalKey<FormState>();
  String formaSelect = "";
  bool enebledButton = false;
  double estoquePro = 0.0;
  double valorPercentDesconto = 0.0;
  int _radioValue = 0;
  double qtdMax = 0.000;
  double qtdMaxEst = 0.000;
  int idProd = 0;
  double qtdResid = 0.0;
  double percentualMax = 0.0;
  List valoresVenda = [];
  double percentualMax2 = 0.0;
  String dropdownvalue = 'Selecione o Tipo de Desconto';
  var itemsList = ['R\$ Valor', '% Porcentagem'];
  bool temGrade = false;
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

  bool semGrade = false;
  int idGrade = 0;
  String nomeGrade = "Selecione a Cor";
  int idCor = 0;
  String nomeCor = "Selecione o Tamanho";
  List gradeList = [];
  List corList = [];

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
  TextEditingController controlPorcen = TextEditingController();
  TextEditingController controlProdValor = TextEditingController(text: "0.0");
  TextEditingController controlProdValorCusto = TextEditingController();
  TextEditingController controlParcelas = TextEditingController(text: "0");
  List formasPagamento = [];
  List tipoDocumento = [];
  TextEditingController formaPagamento =
      TextEditingController(text: "Nenhuma forma selecionada");
  TextEditingController controlNull;
  TextEditingController descontoControl = TextEditingController(
    text: "0.0",
  );
  GlobalKey _scaffold = GlobalKey();
  bool enabledEdit = true;
  double slider = 0.0;
  List produtosList = [];
  List vendedoresList = [];
  List formasPrazo = [];
  List clientesList = [];
  List orcamentos = [];
  int idProdEdit = 0;
  ConfiguracoesModel configuracoesModel = ConfiguracoesModel();
  String _myProd;
  String _myVend;
  String _myForma;
  String _myCliente;
  int orcid;
  double valorD = 0.0;
  int FPGTIPO = 0;
  String opcaoItem = "";
  String opcaoTotal = "";
  int locidemp = 0;
  int percentualdesconto = 0;
  ConfigProvider config = ConfigProvider();
  OrcamentoItem pedItem;
  String generatedPdfFilePath;
  DateTime selectedDate = DateTime.now();
  Future<Produto> futureProd;
  Future _future;
  Future _getPedido;
  Future _futureVend;
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
  Especifica especifica = Especifica();
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
  List listaDebitos = [];
  var dados;
  String PROID;
  String PRONOME;
  String PRODESCRICAO;
  String PROVALOR;
  String PROIMAGEM;
  String forma;
  int idForma = 0;
  DateTime _dateTime = DateTime.now();
  String _dateformat;
  String _horaAtual;
  bool asSelect = false;
  bool asSelectCli = false;
  String nomeVendedor;
  List<Produto> produtolist = [];
  double descontoPercente = 0.0;
  Vendedor vendedor;
  Cliente cliente;
  Produto produto;
  Produto produtoBusca;
  Produto prodid = Produto();

  Timer _timer;
  Conexao c = Conexao();
  String obsOrcamento = null;
  String valorProduto = null;
  String desconto = null;
  String formasDePagamento = null;
  String custo = null;
  String _selected;
  String formaNome = "";
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
  String cep = "";
  String uf = "";
  String cnpj = "";
  DateTime now = new DateTime.now();
  DateTime date;
  int indexEdit = 0;
  int idCliente = 0;
  double descontoTotal = 0.0;
  Cliente cli = Cliente();
  Empresa empresa = Empresa();
  FocusNode focusNodeObs;
  bool debitoButton = false;

  @override
  void initState() {
    focusNodeRef = FocusNode();
    focusNodeCli = FocusNode();
    focusNodeObs = FocusNode();
    descontoControl.selection = TextSelection.fromPosition(
        TextPosition(offset: descontoControl.text.length));
    recuperarConexao();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProdutoProvider>(context, listen: false).clearList();
      recuperarEmpid();
      print("empid recup: " + empid.toString());
    });

    initializeDateFormatting('pt_br');
    _future = getDataProd();
    _futureVend = getDataVend();
    _futureCli = getDataClientes();

    //_dateTime = DateTime.now();
    _dateformat = DateFormat('dd/MM/yyyy').format(_dateTime);
    _horaAtual = DateFormat.jms('pt_br').format(now);
    _timer = new Timer(const Duration(milliseconds: 400), () {});
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  void alterarValor(String text) {
    setState(() {
      controlProdValor = TextEditingController(text: text);
    });
  }

  double setDesconto() {
    setState(() {});

    return totalDesconto;
  }

  double setTotalDesconto() {
    setState(() {});

    return totalDesconto;
  }

  void alterarDesconto(String text) {
    setState(() {
      controlProdDesc = TextEditingController(text: text);
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

  void alterarSubtotal() {
    double valorSubtotal =
        (double.parse(controlQtd.text) * double.parse(controlProdValor.text)) -
            double.parse(controlProdDesc.text);
    setState(() {
      controllerSubtotal =
          TextEditingController(text: _formatValue(valorSubtotal));
    });
  }

  void alterarSubtotal2(String text) {
    setState(() {
      controllerSubtotal = TextEditingController(text: "${text}");
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

  void recuperarEmpid() {
    if (Provider.of<Empresa>(context, listen: false).empresa != null) {
      empid = Provider.of<Empresa>(context, listen: false).empresa.EMPID;
      empresa = Provider.of<Empresa>(context, listen: false).empresa;

      percentualMax2 = Provider.of<Especifica>(context, listen: false)
          .getEspecifica()
          .UPEPERCENTUALDESCONTO
          .toDouble();
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

  void recuperarEspecifica() {
    if (Provider.of<Especifica>(context).UPEPERCENTUALDESCONTO != null) {
      percentualMax = Provider.of<Especifica>(context, listen: false)
          .getEspecifica()
          .UPEPERCENTUALDESCONTO
          .toDouble();
    }
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

  void Mensagem2() {
    var alert = new AlertDialog(
      title: new Text("Lista vazia"),
      content: Text(
          "Adicione no mínimo 1 produto a lista pra adicionar um desconto"),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  Future<double> recuperarultimovalorvenda(int cliid, int proid) async {
    if (Provider.of<ClienteProvider>(context, listen: false).cli != null) {
      return await buscarUltimoValor(cliid, proid);
    }
  }

  _deslogarUsuario() async {
    Navigator.pushReplacementNamed(context, "/login");

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

  _recuperarCnpjCliente() {
    if (Provider.of<ClienteProvider>(context).cnpj != null) {
      cliImagem = Provider.of<ClienteProvider>(context).cnpj;
    }
  }

  Future<String> buscarClienteId(String cliid) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    };

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

      Fluttertoast.showToast(
          msg: "Cliente selecionado!",
          backgroundColor: Colors.blue[900],
          textColor: Colors.white,
          fontSize: 16.0);

      Provider.of<ClienteProvider>(context, listen: false).clienteGet(this.cli);

      _buscarDebitos(cli.id);

      focusNodeRef.requestFocus();
    }
  }

  Future<String> _buscarDebitos(int cliid) async {
    listaDebitos.clear();

    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/contasReceber/contasReceber.php?cliid=${cliid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (msg == "Dados incorretos!") {
      //ValorNaoEncontrado();
      debitoButton = false;
    } else {
      var dados = obj['result'];

      setState(() {
        listaDebitos = dados;
        debitoButton = true;
      });
    }

    return "funcao";
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
      var dados = obj['result'];

      this.prodid = await _dadosProd(dados);
      setState(() {
        temGrade = false;
        semGrade = true;
      });

      limpar();
      Provider.of<ProdutoProvider>(context, listen: false).addProd(prodid);
    }
  }

  Future<double> buscarUltimoValor(int cliid, int proid) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/ultimovalorvenda.php?cliid=${cliid}&proid=${proid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (msg == "Dados incorretos!") {
      //ValorNaoEncontrado();
    } else {
      var dados = obj['result'];

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
    } else {
      var dados = obj['result'];

      valoresProd.clear();

      for (int i = 0; i < valoresVenda.length; i++) {
        valoresProd.add({
          "Nome": "PROVALORVENDA${valoresVenda[i]['VENDA']}",
          "Valor": "${dados[0]['PROVALORVENDA${valoresVenda[i]['VENDA']}']}"
        });
      }

      setState(() {
        semGrade = false;
      });

      if (dados[0]['PROID'] == null) {
        buscarProdStq(proid);
      } else {
        this.prodid = await _dadosProd(dados);

        qtdMaxEst = double.parse(dados[0]['LOPQTD']);

        print("Max estoque: " + qtdMaxEst.toString());
        print("Proid: " + prodid.PROID.toString());

        limpar();
        Provider.of<ProdutoProvider>(context, listen: false).addProd(prodid);

        buscarCoresTam(dados[0]['PROID']);
      }
    }
  }

  Future<String> buscarCoresTam(String proid) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/corestam.php?proid=${proid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    print("aqui" + obj['result'].toString());

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

  Future<String> buscarTamanhos(
      String idCor, String proid, String empid) async {
    tamanhos.clear();

    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/tamanhos.php?empid=${empid}&corid=${idCor}&proid=${proid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (msg == "Dados incorretos!") {
    } else {
      print(dados = obj['result']);

      setState(() {
        tamanhos = dados;
      });

      if (tamanhos.length == 1 && tamanhos[0]['TAMID'] == "0") {
        setState(() {
          idGrade = int.parse(tamanhos[0]['TAMID']);
          widget.grade = tamanhos[0]['TAMNOME'];
        });
      }
    }
  }

  Future<double> estoqueProduto(
      int proid, int corid, int tamid, int empid) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/qtdEstoqueProduto.php?proid=${proid}&tamid=${tamid}&corid=${idCor}&empid=${empid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);

    dados = obj['result'];

    print(dados);
    if (dados != null) {
      setState(() {
        qtdMax = double.parse(dados[0]['LOPQTD']);
      });
      return estoquePro = double.parse(dados[0]['LOPQTD']);
    }
    return 0.0;
  }

  _showDialog() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return new CupertinoAlertDialog(
          title: new Text('Please select'),
          actions: <Widget>[
            new CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop('Cancel');
              },
              child: new Text('Cancel'),
            ),
            new CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop('Accept');
              },
              child: new Text('Accept'),
            ),
          ],
          content: new SingleChildScrollView(
            child: new Material(
              child: DropdownButton(
                hint: widget.desconto == null
                    ? Text(
                        'Selecione o tipo de desconto',
                        style: TextStyle(fontSize: 20),
                      )
                    : Text(
                        widget.desconto,
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                      ),
                iconSize: 30.0,
                style: TextStyle(color: Colors.blue),
                items: [
                  'Valor real',
                  'Porcentagem',
                ].map(
                  (val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val),
                    );
                  },
                ).toList(),
                onChanged: (val) {
                  setState(
                    () {
                      widget.desconto = val;
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
      barrierDismissible: false,
    );
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

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;

      switch (_radioValue) {
        case 0:
          break;
        case 1:
          break;
        case 2:
          break;
      }
    });
  }

  void showDesconto() {
    var alert = SingleChildScrollView(
      padding: EdgeInsets.only(top: 300, left: 30, right: 30),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [],
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: new SizedBox(
                  width: 97,
                  height: 50,
                  child: GestureDetector(
                    onDoubleTap: () => showDesconto(),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: controlProdDesc,
                      enabled: true,
                      decoration: InputDecoration(
                          labelText: 'Desc/item',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
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
                )),
            Text("data"),
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

  Produto produtoB;

  Future<String> _adicionarPedido(Orcamento orcamento) async {
    final result = await http.post(
      'http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/inserirPedido.php?usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}',
      body: orcamento.toJson(),
    );

    if (result.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var obj = convert.json.decode(result.body);

      print(obj['success']);
      orcid = int.parse(obj['ORCID']);

      if (Provider.of<ProdutoProvider>(context, listen: false)
          .items
          .isNotEmpty) {
        print(Provider.of<ProdutoProvider>(context, listen: false).items);
      }

      for (var item in Provider.of<ProdutoProvider>(context, listen: false)
          .items
          .reversed) {
        if (config.HABDESCONTO == 1) {
          if (config.TIPODESCONTO == 1) {
            descontoItem = item.PROVALORDESCONTO;
          } else {
            descontoItem =
                double.parse(descontoControl.text) / produtolist.length;
          }
        }

        pedItem = OrcamentoItem(
            ORCID: orcid,
            PROID: item.PROID,
            ORIQTD: item.quantity,
            ORIDESCONTO: descontoItem,
            ORIVALOR: item.PROVALOR,
            LOCID: locid,
            ORIOBS: item.PROOBS,
            CORID: item.corid,
            TAMID: item.tamid);

        addItems(pedItem);
      }

      _timer = new Timer(const Duration(milliseconds: 400), () {
        setState(() {
          mostrarPedido(orcid);
        });
      });

      return result.body;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Falha ao adicionar o pedido');
    }
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

  _recuperarTotalDesconto() {
    if (Provider.of<ProdutoProvider>(context, listen: false).items.isNotEmpty) {
      for (int i = 0;
          i < Provider.of<ProdutoProvider>(context, listen: false).items.length;
          i++) {
        totalDesconto += Provider.of<ProdutoProvider>(context, listen: false)
            .items[i]
            .PROVALORDESCONTO;
      }

      print(totalDesconto);
    }
  }

  Future<String> _mostrarPedido(int orcid) async {
    final result = await http.post(
        'http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/mostrarPedido.php?ORCID=${orcid}',
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

      //if (double.parse(descontoControl.text) > 0.0) {
      //  totalDesconto = total - double.parse(descontoControl.text);
      //}

      _dateformat = DateFormat('dd-MM-yyyy').format(_dateTime);

      if (config.HABDESCONTO == 1 && config.TIPODESCONTO == 0) {
        total = total - double.parse(descontoControl.text);
        totalDesconto = double.parse(descontoControl.text);
      }

      print("gerendo pdf");

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
          empresa: empresa,
          valorTotal: total + totalDesconto);

      _generatePDFState.generatePDFInvoice();

      Timer(Duration(seconds: 4), () {
        Navigator.of(context).pop();
        Provider.of<FormasProvider>(context, listen: false).reset();

        Provider.of<ProdutoProvider>(context, listen: false).addProd(null);

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CadastroPedido(),
            ));
      });

      return result.body;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Não foi possivel mostrar o pedido');
    }
  }

  @override
  void dispose() {
    // Clean up the focus nodes
    // when the form is disposed
    focusNodeRef.dispose();
    focusNodeCli.dispose();
    focusNodeObs.dispose();

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

  Future<String> _adicionarProduto(OrcamentoItem pedidoItem) async {
    final result = await http.post(
      'http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/addItems.php?usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}',
      body: pedidoItem.toJson(),
    );

    if (result.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var obj = convert.json.decode(result.body);

      print("Result add itens: " + obj.toString());

      baixarEstoqueProduto(pedidoItem.PROID, pedidoItem.CORID, pedidoItem.TAMID,
          empid, pedidoItem.ORIQTD);
      return result.body;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
  }

  add(Orcamento pedido) async {
    await _adicionarPedido(pedido).then((sucess) => {
          Fluttertoast.showToast(
              msg: "Pedido cadastrado com sucesso!",
              backgroundColor: Colors.blue[900],
              textColor: Colors.white,
              fontSize: 16.0),
        });
  }

  mostrarPedido(int pedid) async {
    await _mostrarPedido(pedid).then((sucess) => {
          print("Pedido encontrado com sucesso!"),
        });
  }

  recuperarProdutoID(int proid) async {
    await _mostrarPedido(orcid).then((sucess) => {
          print("Pedido encontrado com sucesso!"),
        });
  }

  addItems(OrcamentoItem pedidoItem) async {
    await _adicionarProduto(pedidoItem).then((sucess) => {
          print("item adicionado sucesso!"),
          Provider.of<ClienteProvider>(context, listen: false).clienteReset(),
        });
  }

  Future<String> baixarEstoqueProduto(
      int proid, int corid, int tamid, int empid, double qtd) async {
    final result = await http.post(
        'http://crtsistemas.com.br/crt_mobile_flutter/apis/pedidos/baixarEstoque.php?qtd=${qtd}&proid=${proid}&corid=${corid}&tamid=${tamid}&empid=${empid}',
        body: c.toJson());

    if (result.statusCode == 200) {
      print("baixa de estoque no produto $proid");

      return result.body;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
  }

  void recuperarConfig() {
    if (Provider.of<ConfigProvider>(context).config != null) {
      config = Provider.of<ConfigProvider>(context).config;
    }

    if (Provider.of<Especifica>(context).UPEPERCENTUALDESCONTO != null) {}
  }

  void recuperarDados() {
    vendedor = Provider.of<VendedorProvider>(context).vendedor;
    String nome = Provider.of<VendedorProvider>(context).vendedor.VENDNOME;
    int id = Provider.of<VendedorProvider>(context).vendedor.VENDID;
    controllerVendId = TextEditingController(text: '${id}');
    controllerVendNome = TextEditingController(text: nome);
  }

  void recuperarDadosCliente() {
    if (Provider.of<ClienteProvider>(context).cli != null) {
      cliente = Provider.of<ClienteProvider>(context).cli;
      cli = Provider.of<ClienteProvider>(context).cli;
      String nome = cliente.nomeFantasia;
      int id = cliente.id;
      controllerClienteId = TextEditingController(text: '${id}');
      controllerClienteNome = TextEditingController(text: nome);

      _buscarDebitos(cliente.id);

      if (listaDebitos.isNotEmpty) {
        setState(() {
          debitoButton = true;
        });
      }
    }
  }

  void recuperarDadosClienteADM() {
    razao = Provider.of<ClienteProvider>(context).razao;
    email = Provider.of<ClienteProvider>(context).email;
    fone = Provider.of<ClienteProvider>(context).fone;
    fone2 = Provider.of<ClienteProvider>(context).fone2;
    logradouro = Provider.of<ClienteProvider>(context).logradoudo;
    bairro = Provider.of<ClienteProvider>(context).bairro;
    cidade = Provider.of<ClienteProvider>(context).cidade;
    numero = Provider.of<ClienteProvider>(context).numero;
    cep = Provider.of<ClienteProvider>(context).cep;
    uf = Provider.of<ClienteProvider>(context).uf;
    cnpj = Provider.of<ClienteProvider>(context).cnpj;
  }

  void recuperarDadosProduto() {
    if (Provider.of<ProdutoProvider>(context).items.isNotEmpty) {
      produtolist = Provider.of<ProdutoProvider>(context).items;
      items = produtolist.length;

      for (var item in produtolist) {
        if (item.PROVALORDESCONTO != null) ;
        total = Provider.of<ProdutoProvider>(context).totalPrice;
      }
    } else {
      items = 0;
      total = 0.0;
    }
  }

  void recuperarProduto() async {
    if (Provider.of<ProdutoProvider>(context).produto != null) {
      produto = Provider.of<ProdutoProvider>(context).produto;

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

      if (enabledEdit == false) {
        idProdEdit =
            Provider.of<ProdutoProvider>(context, listen: false).produto.PROID;
      }

      double provalor =
          Provider.of<ProdutoProvider>(context, listen: false).produto.PROVALOR;

      if (config.ULTIMOVALORVENDA == 1) {
        provalor = await buscarUltimoValor(cliente.id, idProd);

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

  @override
  void didChangeDependencies() {
    recuperarDados();
    recuperarConfiguracoesModel();
    recuperarDadosCliente();
    recuperarDadosProduto();
    if (controlProdNome.text == "") {
      recuperarProduto();
    }
    _recuperarCnpjCliente();
    recuperarDadosClienteADM();

    recuperarConfig();
    recuperarEspecifica();
    super.didChangeDependencies();
  }

  _recuperarDescontoItem() {
    if (Provider.of<ProdutoProvider>(context).items.isNotEmpty) {
      List<Produto> list = Provider.of<ProdutoProvider>(context).items;
      for (var item in list) {
        totalDesconto += item.PROVALORDESCONTO;
      }
    }
  }

  void addItemToList(Produto produto) {
    setState(() {
      produtosList.insert(0, produto);
    });
  }

  void recuperarConexao() async {
    List list = await DBProvider.db.getAllConexaos();

    if (list.isNotEmpty) {
      c = await DBProvider.db.getConexao(1);
    }

    if (c.bdname != null) {
      getFormas();
      getTipos();
    }
  }

  Future<bool> _onBackPressed() {
    if (Provider.of<ProdutoProvider>(context, listen: false).items.isNotEmpty) {
      return showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text(
                  'Você tem certeza que quer voltar sem finalizar o pedido?'),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text('Não'),
                ),
                new FlatButton(
                  onPressed: () {
                    for (var item
                        in Provider.of<ProdutoProvider>(context, listen: false)
                            .items) {
                      voltarEstoqueProduto(item.PROID, item.corid, item.tamid,
                          empresa.EMPID, item.quantity);
                    }

                    Navigator.of(context).pop(true);
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
    SizeConfig().init(context);

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffold,
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          title: Text("Novo Orçamento"),
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
        drawer: _drawer(),
      ),
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

  void valoresVendaEdit(ProdutoProvider cart, int index) {
    valoresProd.clear();

    setState(() {
      widget.valorVenda = "Vr.Venda";
    });

    for (int i = 0; i < valoresVenda.length; i++) {
      valoresProd.add({
        "Nome": "PROVALORVENDA${valoresVenda[i]['VENDA']}",
        "Valor":
            "${cart.items[index].dados[0]['PROVALORVENDA${valoresVenda[i]['VENDA']}']}"
      });
    }
  }

  void getLOCID(int empid) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Charset': 'utf-8'
    };

    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/empresas/selectlocid.php?empid=${empid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);

    dados = obj['result'];

    locid = int.parse(dados[0]['LOCID']);

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
      temGrade = false;
      widget.grade = "Selecione o Tamanho";
      widget.cor = "Selecione a Cor";
    });

    Provider.of<ProdutoProvider>(context, listen: false).limparProduto();
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

  alterarTipodesconto(String tipo) {
    setState(() {
      widget.desconto = tipo;
    });
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
              Text("${cli.nomeFantasia}"),
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
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.search,
                            color: Colors.blue[900],
                          ),
                          onPressed: () {},
                        ),
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
                            _recuperarClienteId();
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
                      height: 55,
                      child: GestureDetector(
                        child: TextField(
                          focusNode: focusNodeRef,
                          enabled: enabledEdit,
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
                      height: 55,
                      child: GestureDetector(
                        onDoubleTap: () {
                          enabledEdit == false
                              ? {
                                  print("em edicao"),
                                }
                              : {
                                  limpar(),
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProdutosCatalog(),
                                      ))
                                };
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
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp('[0-9.,]')),
                          ],
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

                                                        alterarSubtotal();
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
                                                                  alterarTipodesconto(
                                                                      val);
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
                                                              : Container(),
                                                          widget.desconto ==
                                                                  "Tipo Desconto"
                                                              ? Container()
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

                                                                              double valorSubtotal = (double.parse(controlProdValor.text) * double.parse(controlQtd.text)) - valor;

                                                                              alterarSubtotal2(_formatValue(valorSubtotal));
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
                    Padding(padding: EdgeInsets.only(left: 8, bottom: 4)),
                    new SizedBox(
                      width: SizeConfig.screenWidth - 283,
                      height: 55,
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
                Padding(padding: EdgeInsets.all(4.0)),
                Row(
                  children: [
                    Padding(padding: EdgeInsets.all(8)),
                    new SizedBox(
                      width: SizeConfig.screenWidth - 27,
                      height: 55,
                      child: GestureDetector(
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
                                    if (resetDesconto == true) {
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
                                                  if (Provider.of<
                                                              ProdutoProvider>(
                                                          context,
                                                          listen: false)
                                                      .items
                                                      .isEmpty) {
                                                    Provider.of<ProdutoProvider>(
                                                            context,
                                                            listen: false)
                                                        .addItem(prod);

                                                    limpar();
                                                    print(
                                                        'adicionando lista vazia');
                                                  } else {
                                                    if (enabledEdit == false) {
                                                      print("editando");

                                                      Provider.of<ProdutoProvider>(
                                                              context,
                                                              listen: false)
                                                          .addItemIndex(
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
                                                        if (Provider.of<ProdutoProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .buscarProduto(
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
                                                            resultqtd = Provider.of<
                                                                        ProdutoProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .somarQtd(prod);
                                                          });

                                                          print("Estoque pro: " +
                                                              estoquePro
                                                                  .toString());

                                                          if (resultqtd +
                                                                  prod.quantity <=
                                                              estoquePro) {
                                                            Provider.of<ProdutoProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .addItem(prod);

                                                            setState(() {
                                                              resultqtd = Provider.of<
                                                                          ProdutoProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .somarQtd(
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
                                                        Provider.of<ProdutoProvider>(
                                                                context,
                                                                listen: false)
                                                            .addItem(prod);

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
                                                    if (Provider.of<
                                                                ProdutoProvider>(
                                                            context,
                                                            listen: false)
                                                        .items
                                                        .isEmpty) {
                                                      Provider.of<ProdutoProvider>(
                                                              context,
                                                              listen: false)
                                                          .addItem(prod);

                                                      limpar();
                                                      print(
                                                          'adicionando lista vazia');
                                                    } else {
                                                      if (enabledEdit ==
                                                          false) {
                                                        print("editando");

                                                        Provider.of<ProdutoProvider>(
                                                                context,
                                                                listen: false)
                                                            .addItemIndex(
                                                                indexEdit,
                                                                prod);

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
                                                        if (Provider.of<ProdutoProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .buscarProduto(
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
                                                            resultqtd = Provider.of<
                                                                        ProdutoProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .somarQtd(prod);
                                                          });

                                                          print("Estoque pro: " +
                                                              estoquePro
                                                                  .toString());

                                                          if (resultqtd +
                                                                  prod.quantity <=
                                                              estoquePro) {
                                                            Provider.of<ProdutoProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .addItem(prod);

                                                            setState(() {
                                                              resultqtd = Provider.of<
                                                                          ProdutoProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .somarQtd(
                                                                      prod);
                                                            });

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
                                });
                                limpar();
                              })),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 20),
            child: Provider.of<ProdutoProvider>(context).items.isEmpty
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
                          width: SizeConfig.screenWidth,
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

                                                valoresVendaEdit(cart, index);

                                                print(valoresProd);

                                                setState(() {
                                                  buscarTamanhos(
                                                      cart.items[index].corid
                                                          .toString(),
                                                      cart.items[index].PROID
                                                          .toString(),
                                                      empresa.EMPID.toString());
                                                  controlProdId =
                                                      TextEditingController(
                                                          text:
                                                              "${cart.items[index].PROREFERENCIA}");

                                                  qtdResid = cart
                                                      .items[index].quantity;

                                                  enabledEdit = false;
                                                  widget.cor =
                                                      cart.items[index].COR;
                                                  widget.grade =
                                                      cart.items[index].TAMANHO;
                                                  idCor =
                                                      cart.items[index].corid;
                                                  idGrade =
                                                      cart.items[index].tamid;
                                                });

                                                Provider.of<ProdutoProvider>(
                                                        context,
                                                        listen: false)
                                                    .addProd(cart.items[index]);

                                                setState(() {
                                                  indexEdit = index;
                                                });
                                              },
                                              child: Card(
                                                elevation: 5,
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
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Text(
                                                                'REF: ${cart.items[index].PROREFERENCIA}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(
                                                                '${cart.items[index].PRONOME}',
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
                                                                    'Qtd: ${cart.items[index].quantity}',
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
                                                                      'Valor (un): ${_formatValue(cart.items[index].PROVALOR)}',
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
                                                                      ? cart.items[index].PROVALORDESCONTO !=
                                                                              null
                                                                          ? Text(
                                                                              'Desc: ${cart.items[index].PROVALORDESCONTO}  ',
                                                                              style:
                                                                                  TextStyle(
                                                                                fontSize: 16.0,
                                                                              ))
                                                                          : Text(
                                                                              "")
                                                                      : Text(
                                                                          ""),
                                                                  config.TIPODESCONTO ==
                                                                          1
                                                                      ? cart.items[index].PROVALORDESCONTO !=
                                                                              null
                                                                          ? Text(
                                                                              'Total: R\$ ${_formatValueDesconto(cart.total(cart.items[index].quantity, cart.items[index].PROVALOR), cart.items[index].PROVALORDESCONTO)}',
                                                                              style:
                                                                                  TextStyle(
                                                                                fontSize: 16.0,
                                                                              ))
                                                                          : Text(
                                                                              'Total: R\$ ${_formatValue(cart.total(cart.items[index].quantity, cart.items[index].PROVALOR))}',
                                                                              style:
                                                                                  TextStyle(
                                                                                fontSize: 16.0,
                                                                              ))
                                                                      : Text(
                                                                          'Total: R\$ ${_formatValue(cart.total(cart.items[index].quantity, cart.items[index].PROVALOR))}',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16.0,
                                                                          )),
                                                                ],
                                                              ),
                                                              Text(
                                                                "Grade: ${cart.items[index].COR}, ${cart.items[index].TAMANHO}",
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
                                                                          if (resetDesconto ==
                                                                              true) {
                                                                            Fluttertoast.showToast(msg: "Para remover da lista remova primeiro o desconto!");
                                                                          } else {
                                                                            int proid =
                                                                                cart.items[index].PROID;
                                                                            int corid =
                                                                                cart.items[index].corid;
                                                                            int tamid =
                                                                                cart.items[index].tamid;
                                                                            double
                                                                                qtd =
                                                                                cart.items[index].quantity;
                                                                            voltarEstoqueProduto(
                                                                                proid,
                                                                                corid,
                                                                                tamid,
                                                                                empid,
                                                                                qtd);
                                                                            Provider.of<ProdutoProvider>(context, listen: false).clearItem(cart.items[index]);

                                                                            if (Provider.of<ProdutoProvider>(context, listen: false).items.length ==
                                                                                1) {
                                                                              alterarDescontoControl("0.0");
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
                              itemCount: Provider.of<ProdutoProvider>(context,
                                      listen: false)
                                  .items
                                  .length),
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
                padding: EdgeInsets.only(right: 10.0, left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Text(
                            "Items QTD: ${items}",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          Padding(padding: EdgeInsets.only(left: 85)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total: R\$:  ${_formatValue(Provider.of<ProdutoProvider>(context, listen: false).totalSemdesconto)}",
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
                                                "Desconto: R\$:  ${_formatValue(total - double.parse(descontoControl.text))}",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                        Text(
                                          "Total (Desc): R\$:  ${_formatValue(total - double.parse(descontoControl.text))}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    )
                                  : Provider.of<ProdutoProvider>(context,
                                                  listen: false)
                                              .totalDesconto2 ==
                                          0.0
                                      ? Container()
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            config.TIPODESCONTO == 1
                                                ? Text(
                                                    "Desconto: R\$:  ${_formatValue(Provider.of<ProdutoProvider>(context, listen: false).totalDesconto2)}",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15),
                                                  )
                                                : Text(
                                                    "Desconto: R\$:  ${_formatValue(total - double.parse(descontoControl.text))}",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15),
                                                  ),
                                            Text(
                                              "Total (Desc): R\$:  ${_formatValue(Provider.of<ProdutoProvider>(context, listen: false).totalSemdesconto - Provider.of<ProdutoProvider>(context, listen: false).totalDesconto2)}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                          ],
                                        )
                            ],
                          )
                        ],
                      ),
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
                                  if (Provider.of<ProdutoProvider>(context,
                                          listen: false)
                                      .items
                                      .isEmpty) {
                                    Mensagem2();
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
                                                          : Container(),
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
                                                          : Container(),
                                                      widget.desconto ==
                                                              "Tipo Desconto"
                                                          ? Container()
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
                                                                              valorDescontoPorcent2(
                                                                            double.parse(controlPorcen.text),
                                                                            total,
                                                                          );

                                                                          this.valorD =
                                                                              valor;

                                                                          alterarDescontoControl(
                                                                              "${_formatValue(valorD)}");

                                                                          if (controlPorcen.text !=
                                                                              "0.0") {
                                                                            setState(() {
                                                                              resetDesconto = true;
                                                                            });
                                                                          }

                                                                          focusNodeObs
                                                                              .requestFocus();

                                                                          Navigator.pop(
                                                                              context,
                                                                              () {
                                                                            alterarDescontoControl("${_formatValue(valorD)}");
                                                                          });
                                                                        }
                                                                      } else if (widget
                                                                              .desconto ==
                                                                          "Valor Real(R\$)") {
                                                                        if (double.parse(descontoControl.text) >
                                                                            Provider.of<ProdutoProvider>(context, listen: false).totalPrice2) {
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

                                                                        focusNodeObs
                                                                            .requestFocus();

                                                                        Navigator.of(context)
                                                                            .pop();
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
                                      height: 110,
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
                  : Container()
              : Container(),
          Padding(padding: EdgeInsets.all(4)),
          config.TELAFORMAPAGAMENTO == 1
              ? Provider.of<ProdutoProvider>(context, listen: false)
                      .items
                      .isEmpty
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
                            ? Container()
                            : Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 30.0),
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
                              ),
                      ],
                    )
              : Container(),
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
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              child: new SizedBox(
                  width: 220,
                  height: 45,
                  child: FlatButton(
                    child: enebledButton == false
                        ? Text(
                            'CONFIRMAR',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          )
                        : CircularProgressIndicator(),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Colors.blue[900],
                    textColor: Colors.white,
                    onPressed: () {
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
                      if (controllerClienteNome.text.isNotEmpty &&
                          controllerClienteId.text.isNotEmpty) {
                        if (produtolist.isNotEmpty) {
                          _dateformat =
                              DateFormat('yyyy-MM-dd').format(_dateTime);

                          if (config.TIPODESCONTO == 0 && locid > 0) {
                            setState(() {
                              total =
                                  total - double.parse(descontoControl.text);

                              totalDesconto =
                                  double.parse(descontoControl.text);
                            });

                            print("total com desconto: " + total.toString());
                          } else if (config.TIPODESCONTO == 1 && locid > 0) {
                            totalDesconto = Provider.of<ProdutoProvider>(
                                    context,
                                    listen: false)
                                .valorDesconto();

                            total = total - totalDesconto.toDouble();
                            print(
                                "total com desconto item: " + total.toString());

                            setState(() {
                              print(totalDesconto);
                            });
                          }

                          if (config.HABDESCONTO == 0) {
                            Orcamento orcamento = Orcamento(
                                VENID: int.parse(controllerVendId.text),
                                CLIID: int.parse(controllerClienteId.text),
                                ORCOBS: controlOrcObs.text,
                                ORCFORMAPAGAMENTOTXT: formaNome,
                                ORCVALORTOTAL: total,
                                ORCOBS2: totalDesconto.toString(),
                                EMPID: empid,
                                ORCHORA: _horaAtual,
                                ORCDATA: _dateformat);

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
                              if (locid > 0) {
                                if (enebledButton == false) {
                                  add(orcamento);
                                  setState(() {
                                    enebledButton = true;
                                  });
                                }
                              }
                            }
                          } else {
                            if (totalDesconto == 0.0) {
                              _recuperarTotalDesconto();
                            }
                            if (totalDesconto > 0.0) {
                              Orcamento orcamento = Orcamento(
                                  VENID: int.parse(controllerVendId.text),
                                  CLIID: int.parse(controllerClienteId.text),
                                  ORCOBS: controlOrcObs.text,
                                  ORCFORMAPAGAMENTOTXT: formaNome,
                                  ORCVALORTOTAL: total,
                                  ORCOBS2: totalDesconto.toString(),
                                  EMPID: empid,
                                  ORCHORA: _horaAtual,
                                  ORCDATA: _dateformat);

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
                                                MaterialStateProperty.all<
                                                    Color>(Colors.blue[900]),
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
                                if (locid > 0) {
                                  if (enebledButton == false) {
                                    add(orcamento);
                                    setState(() {
                                      enebledButton = true;
                                    });
                                  }
                                }
                              }
                            } else {
                              Orcamento orcamento = Orcamento(
                                  VENID: int.parse(controllerVendId.text),
                                  CLIID: int.parse(controllerClienteId.text),
                                  ORCOBS: controlOrcObs.text,
                                  ORCFORMAPAGAMENTOTXT: formaNome,
                                  ORCVALORTOTAL: total,
                                  ORCOBS2: totalDesconto.toString(),
                                  EMPID: empid,
                                  ORCHORA: _horaAtual,
                                  ORCDATA: _dateformat);

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
                                                MaterialStateProperty.all<
                                                    Color>(Colors.blue[900]),
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
                                if (locid > 0) {
                                  if (enebledButton == false) {
                                    add(orcamento);
                                    setState(() {
                                      enebledButton = true;
                                    });
                                  }
                                }
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
      content: new Text("Verifique a referência digitada!"),
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

      print(clientesList);
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
}

class GeneratePDF extends StatefulWidget {
  @override
  State<GeneratePDF> createState() => new GeneratePDFState();
}

class GeneratePDFState extends State<GeneratePDF> {
  Cliente cliente;
  String generatedPdfFilePath;
  List<Produto> produtos;
  Vendedor vendedor;
  int orcid;
  double total;
  String formaPagamento;
  String obsOrcamento;
  double desconto;
  double totalDesconto;
  var assetImage;
  String data;
  MemoryImage imagem;
  String razao, hora;
  var image;
  Empresa empresa;
  double valorTotal;
  DateFormat dateFormat = DateFormat("dd-MM-yyyy");
  ImageProvider _imageProvider;
  GeneratePDFState(
      {@required this.cliente,
      this.vendedor,
      this.orcid,
      this.produtos,
      this.total,
      this.totalDesconto,
      this.desconto,
      this.formaPagamento,
      this.obsOrcamento,
      this.razao,
      this.data,
      this.hora,
      this.empresa,
      this.valorTotal});
  int count = 0;

  File fileFromDocsDir(String filename) {
    String pathName = p.join(_appDocsDir.path, filename);
    return File(pathName);
  }

  generatePDFInvoice() async {
    String msg = "";

    if (empresa.LOGOMARCA == null || empresa.LOGOMARCA == "") {
      image = await flutterImageProvider(
        NetworkImage(
            "http://crtsistemas.com.br/crt_mobile_flutter/logoEmpresa/semimagem.bmp"),
      );
    } else {
      image = await flutterImageProvider(
        NetworkImage("${empresa.LOGOMARCA}"),
      );
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
      String result = await openFileBytesForMobile(_pdfTextByte, orcid);
      if (result == "done") {
        print(result);
      }
    }
  }

  generatePDFInvoice2() async {
    String msg = "";

    if (empresa.LOGOMARCA == null || empresa.LOGOMARCA == "") {
      image = await flutterImageProvider(
        NetworkImage(
            "http://crtsistemas.com.br/crt_mobile_flutter/logoEmpresa/semimagem.bmp"),
      );
    } else {
      image = await flutterImageProvider(
        NetworkImage("${empresa.LOGOMARCA}"),
      );
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
          header: _buildHeader2,
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
      String result = await openFileBytesForMobile(_pdfTextByte, orcid);
      if (result == "done") {
        print(result);
      }
    }
  }

  Future<String> openFileBytesForMobile(List<int> bytes, int orcid) async {
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/${orcid}.pdf");
    await file.writeAsBytes(bytes);

    final _result = await OpenFile.open(file.path);
    return _result.message;
  }

  String _formatData(String value) {
    DateTime data = DateTime.parse(value);
    String _dateformat = DateFormat('dd/MM/yyyy').format(data);

    return _dateformat;
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Container(
        color: PdfColors.blue900,
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
                          padding: pw.EdgeInsets.only(right: 100, bottom: 20),
                          child: pw.Text("Orçamento: N° ${orcid}",
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.only(right: 4, bottom: 20),
                          child: pw.Text("${data}",
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.only(bottom: 20),
                          child: pw.Text("${hora}",
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                      ]),
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

  pw.Widget _buildHeader2(pw.Context context) {
    return pw.Container(
        color: PdfColors.blue900,
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
                          padding: pw.EdgeInsets.only(right: 100, bottom: 20),
                          child: pw.Text("Orçamento: N° ${orcid}",
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.only(right: 4, bottom: 20),
                          child: pw.Text("${_formatData(data)}",
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.only(bottom: 20),
                          child: pw.Text("${hora}",
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                      ]),
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
          padding: pw.EdgeInsets.only(top: 4, left: 25, right: 25),
          child: _buildContentClient()),
      pw.Padding(
          padding: pw.EdgeInsets.only(top: 4, left: 25, right: 25),
          child: _contentTable(context)),
    ];
  }

  pw.Widget _buildContentClient() {
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _titleText('Cliente'),
              pw.Text(cliente.nomeFantasia),
              _titleText('CPF/CNPJ'),
              pw.Text(cliente.cpf_cnpj),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _titleText('Vendedor'),
              pw.Text(vendedor.VENDNOME),
              _titleText('Telefone'),
              pw.Text(vendedor.VENDTEL),
            ],
          ),
        ]);
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
    const tableHeaders = ['ID', 'DESCRIÇÃO', 'GRADE', 'PREÇO', 'QTD', 'TOTAL'];

    return pw.Table.fromTextArray(
      border: pw.TableBorder.symmetric(
          inside: pw.BorderSide(width: 2), outside: pw.BorderSide(width: 3)),
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(),
      headerHeight: 25,
      cellHeight: 20,
      // Define o alinhamento das células, onde a chave é a coluna
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.center,
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
      data: List<List<String>>.generate(
        produtos.length,
        (row) => List<String>.generate(
          tableHeaders.length,
          (col) => _getValueIndex(produtos[row], col),
        ),
      ),
    );
  }

  /// Retorna o valor correspondente a coluna
  String _getValueIndex(Produto product, int col) {
    switch (col) {
      case 0:
        return product.PROID.toString();
      case 1:
        return product.PRONOME;
      case 2:
        return "Cor: " +
            product.COR +
            "\n"
                "Tamanho: " +
            product.TAMANHO;
      case 3:
        return _formatValue(product.PROVALOR);

      case 4:
        return product.quantity.toString();
      case 5:
        return _formatValue(product.PROVALOR * product.quantity);
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

  /// Retorna o rodapé da página
  pw.Widget _buildPrice(pw.Context context) {
    return pw.Container(
      color: PdfColors.blue900,
      height: 100,
      child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Padding(
                padding: pw.EdgeInsets.only(left: 16),
                child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      _titleText('Observações do Orçamento'),
                      pw.Padding(
                          padding: pw.EdgeInsets.only(),
                          child: pw.Text("${obsOrcamento}",
                              style: pw.TextStyle(color: PdfColors.white))),
                      pw.Padding(padding: pw.EdgeInsets.only(top: 4)),
                      _titleText("VALOR TOTAL"),
                      pw.Text('R\$:  ${_formatValue(valorTotal)}',
                          style: pw.TextStyle(
                              color: PdfColors.white, fontSize: 18)),
                    ])),
            pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _titleText("DESCONTO APLICADO"),
                      pw.Text('R\$:  ${_formatValue(totalDesconto)}',
                          style: pw.TextStyle(
                              color: PdfColors.white, fontSize: 18)),
                      _titleText('VALOR COM DESCONTO'),
                      pw.Text('R\$: ${_formatValue(total)}',
                          style: pw.TextStyle(
                              color: PdfColors.white, fontSize: 18)),
                    ]))
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;
  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }
}
