import 'dart:convert' as convert;

import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/cliente.dart';

import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/empresaModel.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:masked_text/masked_text.dart';

class Editview extends StatefulWidget {
  Cliente cliente;
  Editview({Key key, @required this.cliente}) : super(key: key);

  String _selectTipoPessoa = "Pessoa Física";
  String _hint = "* CPF";
  String _estados = "* UF";
  String _municipios = "* CIDADE";
  bool habilitar = true;
  @override
  _EditviewState createState() => _EditviewState();
}

class _EditviewState extends State<Editview>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> itensMenu = ["Ajuda", "Sair"];
  String _mensagemErro = "";
  int tipoPessoa = 0;
  TextEditingController razaosocial = new TextEditingController();
  TextEditingController nomefantasia = new TextEditingController();
  TextEditingController cpf_cnpj = new TextEditingController();
  TextEditingController rg_ie = new TextEditingController();
  TextEditingController tel1 = new TextEditingController();
  TextEditingController tel2 = new TextEditingController();
  TextEditingController logradouro = new TextEditingController();
  TextEditingController bairro = new TextEditingController();
  TextEditingController cidade = new TextEditingController();
  TextEditingController cep = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController site = new TextEditingController();
  TextEditingController obs = new TextEditingController();
  Conexao c = Conexao();
  final formKey = GlobalKey<FormState>();
  int idCliente = 0;
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String celular;
  List municipios = [];
  Future _future;
  FocusNode myFocusNode = FocusNode();
  String error;
  String errorCfp;
  var msg;
  String cepTxt = "";
  String tel1Txt = "";
  String tel2Txt = "";
  String cpfTxt = "";
  bool focus = false;
  int tipoPessoaInt = 0;
  int munid = 0;
  String munnome = "";
  int id = 0;

  @override
  void didChangeDependencies() {
    recuperarEmpid();
    super.didChangeDependencies();
  }

  void recuperarEmpid() {
    if (Provider.of<Empresa>(context).empresa != null) {
      idCliente = Provider.of<Empresa>(context).empresa.EMPID;
    }
  }

  void recuperarConexao() async {
    List list = await DBProvider.db.getAllConexaos();

    if (list.isNotEmpty) {
      c = await DBProvider.db.getConexao(1);
    }
  }

  _deslogarUsuario() async {
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  _escolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case "Ajuda":
        Navigator.pushNamed(context, "/");
        break;
      case "Sair":
        _deslogarUsuario();
        break;
    }
    //print("Item escolhido: " + itemEscolhido );
  }

  @override
  void initState() {
    recuperarConexao();
    recuperarDadosCliente();
    myFocusNode = FocusNode();
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future getDataMunicipios(String uf) async {
   

    try {
      var response = await http.post(
          Uri.parse(
              "http://crtsistemas.com.br/crt_mobile_flutter/apis/municipios.php?uf=${uf}"),
      body: c.toJson());

      var obj = convert.json.decode(response.body);

      setState(() {
        municipios = obj['result'];
      });

      return obj['result'];
    } catch (e) {
      print("nao foi possivel recuperar os municipios");
    }
  }

  void MensagemCpfErro() {
    var alert = new AlertDialog(
      contentPadding: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
      backgroundColor: Colors.red,
      title: new Text(
        "CPF OU CNPJ JÁ CADASTRADO OU CLIENTE CADASTRADO NA EMPRESA",
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

  void MensagemSelect() {
    var alert = new AlertDialog(
      contentPadding: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
      backgroundColor: Colors.red,
      title: new Text(
        "Error: Selecione a cidade",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: new Text(
          "Se for mudar o estado selecione a cidade correspondente",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void MensagemCpfInvalid() {
    var alert = new AlertDialog(
      contentPadding: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
      backgroundColor: Colors.red,
      title: new Text(
        "CPF OU CNPJ INVÁLIDO",
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

  // Http post request to create new data
  Future<String> _createCliente(Cliente cliente) async {
    final result = await http.post(
      'http://crtsistemas.com.br/crt_mobile_flutter/apis/clientes/inserirCliente.php?idCliente=${idCliente}&usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}',
      body: cliente.toJson(),
    );

    if (result.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      var obj = convert.json.decode(result.body);

      setState(() {
        msg = obj["message"];
      });

      return result.body;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
  }

  add(Cliente cliente) async {
    await _createCliente(cliente).then((sucess) => {
          if (msg == "CPF já Cadastrado ou Cliente cadastrado na Empresa")
            {MensagemCpfErro()}
          else
            {
              Fluttertoast.showToast(
                  msg: "Cadastrado com sucesso!",
                  backgroundColor: Colors.blue[900],
                  textColor: Colors.white,
                  fontSize: 16.0),
              Navigator.pushNamedAndRemoveUntil(
                  context, "/telaInicial", (route) => false)
            },
        });
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: new Text("Cliente não cadastrado"),
          content: new Text(
              "Verifique os campos obrigatorios * e digite a quantidade de letras especificadas"),
          actions: <Widget>[
            // define os botões na base do dialogo
            new FlatButton(
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

  void _showDialogTel() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: new Text("Telefone precisa ter 11 digitos"),
          content: new Text("Verifique o campo e tente novamente"),
          actions: <Widget>[
            // define os botões na base do dialogo
            new FlatButton(
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

  void _showDialogCpf() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: new Text("CPF OU CNPJ INVALIDO"),
          content: new Text("Verifique o campo e tente novamente"),
          actions: <Widget>[
            new FlatButton(
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

  void _showDialogCep() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: new Text("CEP INVALIDO"),
          content: new Text("O cep precisa ter 8 digitos"),
          actions: <Widget>[
            // define os botões na base do dialogo
            new FlatButton(
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

  _sendForm() {
    if (_key.currentState.validate()) {
      // Sem erros na validação
      _key.currentState.save();
    } else {
      // erro de validação
      setState(() {
        _validate = true;
      });
    }
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  void _resetCampos() {
    razaosocial.clear();
    nomefantasia.clear();
    cpf_cnpj.clear();
    rg_ie.clear();
    tel1.clear();
    tel2.clear();
    logradouro.clear();
    bairro.clear();
    cidade.clear();
    cep.clear();
    email.clear();
    site.clear();
    obs.clear();
  }

  String _validarCelular(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe o celular";
    } else if (value.length != 10) {
      return "O celular deve ter 10 dígitos";
    } else if (!regExp.hasMatch(value)) {
      return "O número do celular so deve conter dígitos";
    }
    return null;
  }

  recuperarDadosCliente() {
    id = widget.cliente.id;
    razaosocial = new TextEditingController(text: "${widget.cliente.razao}");
    nomefantasia =
        new TextEditingController(text: "${widget.cliente.nomeFantasia}");
    cpf_cnpj = new TextEditingController(text: "${widget.cliente.cpf_cnpj}");
    rg_ie = new TextEditingController(text: "${widget.cliente.rg_ie}");
    tel1 = new TextEditingController(text: "${widget.cliente.tel1}");
    tel2 = new TextEditingController(text: "${widget.cliente.tel2}");
    logradouro =
        new TextEditingController(text: "${widget.cliente.logradouro}");
    bairro = new TextEditingController(text: "${widget.cliente.bairro}");
    cidade = new TextEditingController(text: "${widget.cliente.cidade}");
    cep = new TextEditingController(text: "${widget.cliente.cep}");
    email = new TextEditingController(text: "${widget.cliente.email}");
    site = new TextEditingController(text: "${widget.cliente.site}");
    obs = new TextEditingController(text: "${widget.cliente.obs}");
    widget._estados = widget.cliente.uf;
    widget._municipios = widget.cliente.cidade;
    widget._selectTipoPessoa =
        widget.cliente.tipoPessoa == 1 ? "Pessoa Jurídica" : "Pessoa Física";
    tipoPessoaInt = widget.cliente.tipoPessoa;

    munid = widget.cliente.munid;

    munnome = cidade.text;
  }

  edit(Cliente cliente) async {
    await _editCliente(cliente).then((sucess) => {
          Fluttertoast.showToast(
              msg: "Cliente editado com sucesso!",
              backgroundColor: Colors.blue[900],
              textColor: Colors.white,
              fontSize: 16.0),
          Navigator.pushNamedAndRemoveUntil(
              context, "/homeCliente", (route) => false)
        });
  }

  Future<String> _editCliente(Cliente cliente) async {
    final result = await http.post(
      Uri.parse(
          'http://crtsistemas.com.br/crt_mobile_flutter/apis/clientes/editCliente.php?munid=${munid}&usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}'),
      body: cliente.toJson(),
    );

    if (result.statusCode == 200) {
      var obj = convert.json.decode(result.body);

      print(obj);

      return result.body;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue[900],
          title: Text('Alterar Cliente'),
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
      body: new Form(
        key: _key,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              widget._selectTipoPessoa == "Pessoa Física"
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 8, 8),
                      child: TextField(
                        controller: razaosocial,
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: 17),
                        decoration: InputDecoration(
                            errorText: error,
                            icon: new Icon(Icons.person),
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 20, 8),
                            labelText: "* Nome",
                            filled: true,
                            fillColor: Colors.grey[350],
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 8, 8),
                      child: TextField(
                        controller: razaosocial,
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: 17),
                        decoration: InputDecoration(
                            errorText: error,
                            icon: new Icon(Icons.person),
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 20, 8),
                            labelText: "* Razão Social",
                            filled: true,
                            fillColor: Colors.grey[350],
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 8, 8, 8),
                child: DropdownButton(
                  hint: widget._selectTipoPessoa == null
                      ? Text(
                          'Tipo Pessoa',
                          style: TextStyle(fontSize: 20),
                        )
                      : Text(
                          widget._selectTipoPessoa,
                          style: TextStyle(color: Colors.blue, fontSize: 20),
                        ),
                  iconSize: 30.0,
                  style: TextStyle(color: Colors.blue),
                  items: [
                    'Pessoa Física',
                    'Pessoa Jurídica',
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
                        widget._selectTipoPessoa = val;

                        if (widget._selectTipoPessoa == "Pessoa Física") {
                          widget._hint = "* CPF";
                          tipoPessoaInt = 0;
                          tipoPessoa = 0;
                          widget.habilitar = false;
                        } else if (widget._selectTipoPessoa ==
                            "Pessoa Jurídica") {
                          widget._hint = "* CNPJ";
                          widget.habilitar = true;
                          tipoPessoa = 1;
                        }
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 8, 8),
                child: TextField(
                  controller: nomefantasia,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 17),
                  enabled: widget._selectTipoPessoa == "Pessoa Física"
                      ? false
                      : true,
                  decoration: InputDecoration(
                      icon: new Icon(Icons.business),
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 20, 8),
                      labelText: "Nome Fantasia",
                      filled: true,
                      fillColor: Colors.grey[350],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Row(
                children: <Widget>[
                  widget._selectTipoPessoa == "Pessoa Física"
                      ? Container(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 50, top: 25),
                            child: SizedBox(
                              width: 150,
                              child: new MaskedTextField(
                                maxLength: 14,
                                maskedTextFieldController: cpf_cnpj,
                                mask: "xxx.xxx.xxx-xx",
                                keyboardType: TextInputType.number,
                                inputDecoration: new InputDecoration(
                                    errorText: errorCfp,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 20, 8),
                                    labelText: widget._hint,
                                    filled: true,
                                    fillColor: Colors.grey[350],
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 50, top: 25),
                            child: SizedBox(
                              width: 150,
                              child: new MaskedTextField(
                                maxLength: 18,
                                maskedTextFieldController: cpf_cnpj,
                                mask: "xx.xxx.xxx/xxxx-xx",
                                keyboardType: TextInputType.number,
                                inputDecoration: new InputDecoration(
                                    errorText: errorCfp,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 20, 8),
                                    labelText: "CNPJ",
                                    filled: true,
                                    fillColor: Colors.grey[350],
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                            ),
                          ),
                        ),
                  widget._selectTipoPessoa == "Pessoa Física"
                      ? Container(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30, top: 3),
                            child: SizedBox(
                              width: 165,
                              child: TextFormField(
                                inputFormatters: [
                                  new LengthLimitingTextInputFormatter(14)
                                ],
                                controller: rg_ie,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontSize: 17),
                                decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 20, 8),
                                    labelText: "RG",
                                    filled: true,
                                    fillColor: Colors.grey[350],
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30, top: 3),
                            child: SizedBox(
                              width: 165,
                              child: TextFormField(
                                inputFormatters: [
                                  new LengthLimitingTextInputFormatter(9)
                                ],
                                controller: rg_ie,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontSize: 17),
                                decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 20, 8),
                                    labelText: "* IE",
                                    filled: true,
                                    fillColor: Colors.grey[350],
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
              Padding(padding: EdgeInsets.all(4.0)),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 8, 8),
                child: new MaskedTextField(
                  maxLength: 14,
                  maskedTextFieldController: tel1,
                  mask: "(xx)xxxxx-xxxx",
                  keyboardType: TextInputType.phone,
                  inputDecoration: new InputDecoration(
                      icon: new Icon(Icons.call),
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 20, 8),
                      labelText: "Telefone 1",
                      filled: true,
                      fillColor: Colors.grey[350],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 8, 8),
                child: new MaskedTextField(
                  maxLength: 14,
                  maskedTextFieldController: tel2,
                  mask: "(xx)xxxxx-xxxx",
                  keyboardType: TextInputType.phone,
                  inputDecoration: new InputDecoration(
                      icon: new Icon(Icons.call),
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 20, 8),
                      labelText: "Telefone 2",
                      filled: true,
                      fillColor: Colors.grey[350],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: DropdownButton(
                      hint: widget._estados == null
                          ? Text(
                              'UF',
                              style: TextStyle(fontSize: 20),
                            )
                          : Text(
                              widget._estados,
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 20),
                            ),
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.blue),
                      items: [
                        'AC',
                        'AL',
                        'AP',
                        'AM',
                        'BA',
                        'CE',
                        'DF',
                        'ES',
                        'GO',
                        'MA',
                        'MT',
                        'MS',
                        'MG',
                        'PA',
                        'PB',
                        'PR',
                        'PE',
                        'PI',
                        'RJ',
                        'RN',
                        'RS',
                        'RO',
                        'RR',
                        'SC',
                        'SP',
                        'SE',
                        'TO'
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
                            widget._estados = val;
                            getDataMunicipios(val);
                          },
                        );
                      },
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10, left: 50)),
                  Flexible(
                    child: DropdownButton(
                      hint: widget._municipios == null
                          ? Text(
                              'CIDADE',
                              style: TextStyle(fontSize: 20),
                            )
                          : Text(
                              widget._municipios,
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 20),
                            ),
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.blue),
                      items: municipios.map((dynamic map) {
                        return new DropdownMenuItem<dynamic>(
                          onTap: () {
                            setState(() {
                              munid = int.parse(map['MUNID']);
                              munnome = map['MUNNOME'];
                            });
                          },
                          value: map['MUNNOME'],
                          child: new Text(map['MUNNOME'],
                              style: new TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(
                          () {
                            widget._municipios = val;
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 8, 8),
                child: TextField(
                  controller: logradouro,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 17),
                  decoration: InputDecoration(
                      errorText: error,
                      icon: new Icon(Icons.location_on),
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 20, 8),
                      labelText: "* Logradouro",
                      filled: true,
                      fillColor: Colors.grey[350],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 10, 8, 8),
                child: TextField(
                  controller: bairro,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 17),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 20, 0, 8),
                      labelText: "Bairro",
                      filled: true,
                      fillColor: Colors.grey[350],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 1, 0),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 40),
                child: Container(
                  child: SizedBox(
                    width: 355,
                    child: new MaskedTextField(
                      maxLength: 9,
                      maskedTextFieldController: cep,
                      mask: "xxxxx-xxx",
                      keyboardType: TextInputType.phone,
                      inputDecoration: new InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 20, 8),
                          labelText: "Cep",
                          filled: true,
                          fillColor: Colors.grey[350],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 8, 8),
                child: TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 17),
                  decoration: InputDecoration(
                      icon: new Icon(Icons.email),
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 20, 8),
                      labelText: "E-mail",
                      filled: true,
                      fillColor: Colors.grey[350],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 8, 8),
                child: TextField(
                  controller: site,
                  keyboardType: TextInputType.url,
                  style: TextStyle(fontSize: 17),
                  decoration: InputDecoration(
                      icon: new Icon(Icons.alternate_email),
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 20, 8),
                      labelText: "Site",
                      filled: true,
                      fillColor: Colors.grey[350],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 10, 8, 8),
                child: TextField(
                  controller: obs,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 17),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 55, 0, 8),
                      labelText: "Observações",
                      filled: true,
                      fillColor: Colors.grey[350],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(
                    textColor: Colors.blue[900],
                    child: Text('Limpar'),
                    onPressed: () {
                      _resetCampos();
                    },
                  ),
                  FlatButton(
                    padding: EdgeInsets.fromLTRB(45, 8, 55, 16),
                    child: Text(
                      'Confirmar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Colors.blue[900],
                    textColor: Colors.white,
                    onPressed: () {
                      tel1Txt = tel1.text
                          .replaceAll(new RegExp(r'[^0-9]'), ''); // '23'
                      tel2Txt = tel2.text
                          .replaceAll(new RegExp(r'[^0-9]'), ''); // '23'
                      cpfTxt = cpf_cnpj.text
                          .replaceAll(new RegExp(r'[^0-9]'), ''); // '23'
                      cepTxt = cep.text
                          .replaceAll(new RegExp(r'[^0-9]'), ''); // '23'
                      Cliente c = Cliente(
                          id: id,
                          nomeFantasia: nomefantasia.text,
                          munid: munid,
                          razao: razaosocial.text,
                          cpf_cnpj: cpfTxt,
                          logradouro: logradouro.text,
                          email: email.text,
                          rg_ie: rg_ie.text,
                          tel1: tel1Txt,
                          tel2: tel2Txt,
                          cep: cepTxt,
                          tipoPessoa:
                              widget._selectTipoPessoa == "Pessoa Física"
                                  ? 0
                                  : 1,
                          uf: widget._estados,
                          bairro: bairro.text,
                          cidade: munnome,
                          obs: obs.text,
                          site: site.text);

                      if (CPFValidator.isValid(c.cpf_cnpj) == true ||
                          CNPJValidator.isValid(c.cpf_cnpj) == true) {
                        if (widget._estados != widget.cliente.uf &&
                            widget.cliente.cidade == munnome) {
                          MensagemSelect();
                        } else {
                          edit(c);
                        }
                      } else {
                        setState(() {
                          errorCfp = "Inválido";
                        });
                        MensagemCpfInvalid();
                      }
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
