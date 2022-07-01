import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/clienteProvider.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/conexaoProvider.dart';
import 'package:flutteraplicativo/src/models/configProvider.dart';
import 'package:flutteraplicativo/src/models/empresaModel.dart';
import 'package:flutteraplicativo/src/models/produtoProvider.dart';
import 'package:flutteraplicativo/src/models/produtos.dart';
import 'package:flutteraplicativo/src/view/home2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:provider/provider.dart';

extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) =>
      this.toLowerCase().contains(secondString.toLowerCase());
}

class ImgProd extends StatefulWidget {
  @override
  _ImgProdState createState() => _ImgProdState();
}

class _ImgProdState extends State<ImgProd> {
  Future<Produto> futureProd;
  bool carregando = false;
  File _image;
  Future _future;
  String razaosocial;
  String cpf_cnpj;
  Future _selectCliente;
  String searchString = "";
  TextEditingController searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();
  String _mensagemErro = "";
  TextEditingController razaosocialtxt = TextEditingController(text: "dan");
  TextEditingController cpf_cnpjtxt = TextEditingController(text: "123");
  var dados;
  Produto prod = new Produto();
  Empresa empresa = Empresa();
  String PROID;
  String PRONOME;
  String PRODESCRICAO;
  bool usage = false;
  String PROVALOR;
  String PROIMAGEM;
  Conexao c = Conexao();
  int empid = 0;
  Future produtosDb;
  List catalogitems = [];
  ConfigProvider config = ConfigProvider();
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
  File _imagem;
  String _idUsuarioLogado;
  bool _subindoImagem = false;
  String _urlImagemRecuperada;

  Future _recuperarImagem(String origemImagem, String proref) async {
    File imagemSelecionada;
    switch (origemImagem) {
      case "camera":
        imagemSelecionada = await ImagePicker.pickImage(
            source: ImageSource.camera,
            imageQuality: 70,
            maxHeight: 250,
            maxWidth: 250);
        break;
      case "galeria":
        imagemSelecionada = await ImagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 70,
            maxHeight: 250,
            maxWidth: 250);
        break;
    }

    setState(() {
      _imagem = imagemSelecionada;
      if (_imagem != null) {
        _subindoImagem = true;
        //_uploadImagem(proref);
        _uploadImagem(proref, empresa.EMPCNPJ);
      }
    });
  }

  Future<String> buscarProdStq(String ref) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    };

    var response = await http.get(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/produtoSemStq.php?ref=${ref}&empid=${empid}&usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}"),
        headers: headers);

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

  edit(String proref, String url) async {
    await _editImage(proref, url).then((sucess) => {
          Fluttertoast.showToast(
              msg: "Upload de imagem com sucesso!",
              backgroundColor: Colors.blue[900],
              textColor: Colors.white,
              fontSize: 16.0),
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Home2(),
              ))
        });
  }

  Future<String> _editImage(String prodref, String url) async {
    Map<String, String> toJson() => {'url': '${url}', 'proref': '${prodref}'};

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Charset': 'utf-8'
    };

    final result = await http.post(
      'http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/updateImage.php?usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}',
      body: toJson(),
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

  //Future uploadImageToFirebase(BuildContext context, String proref) async {
  //  FirebaseStorage storage = FirebaseStorage.instance;
  //  StorageReference pastaRaiz = storage.ref();

  //  StorageReference arquivo =
  //      pastaRaiz.child("produtos").child(proref.toString() + ".jpg");

  //  //Upload da imagem

  //  StorageUploadTask uploadTask = arquivo.putFile(_image);
  //  StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  //  taskSnapshot.ref.getDownloadURL().then(
  //        (value) => print("Done: $value"),
  //      );
  //}

  Future _uploadImagem(String proref, String cnpjEmpresa) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();

    StorageReference arquivo = pastaRaiz
        .child("produtos")
        .child(cnpjEmpresa + "-ref:" + proref.toString() + ".jpg");

    //Upload da imagem
    StorageUploadTask task = arquivo.putFile(_imagem);

    //Controlar progresso do upload
    task.events.listen((StorageTaskEvent storageEvent) {
      if (storageEvent.type == StorageTaskEventType.progress) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (storageEvent.type == StorageTaskEventType.success) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });

    StorageTaskSnapshot taskSnapshot = await task.onComplete;

    taskSnapshot.ref.getDownloadURL().then(
          (value) => {
            edit(proref, value),
          },
        );
  }

  @override
  void initState() {
    recuperarConexao();

    super.initState();
  }

  void recuperarConexao() async {
    List list = await DBProvider.db.getAllConexaos();

    if (list.isNotEmpty) {
      c = await DBProvider.db.getConexao(1);
    }
  }

  void recuperarConfig() {
    if (Provider.of<ConfigProvider>(context).config != null) {
      config = Provider.of<ConfigProvider>(context).config;
    }
  }

  @override
  void didChangeDependencies() {
    recuperarEmpid();
    recuperarConfig();
    super.didChangeDependencies();
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

  void recuperarEmpid() {
    if (Provider.of<Empresa>(context).empresa != null) {
      empid = Provider.of<Empresa>(context).empresa.EMPID;
      empresa = Provider.of<Empresa>(context).empresa;

      print(empresa);
    }
  }

  String _formatValue(double value) {
    final NumberFormat numberFormat = new NumberFormat("#,##0.00", "pt_BR");
    return numberFormat.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text("Produtos"),
        actions: <Widget>[],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, right: 20.0, left: 20.0),
        child: SingleChildScrollView(
          child: Column(
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
                                          left: 20,
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
                                                                                Image.network(
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
                                                                  _subindoImagem ==
                                                                          true
                                                                      ? Center(
                                                                          child:
                                                                              CircularProgressIndicator())
                                                                      : Container()
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Column(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                _recuperarImagem(
                                                                    "galeria",
                                                                    catalogitems[
                                                                            index]
                                                                        [
                                                                        'PROREFERENCIA']);
                                                              },
                                                              child: Container(
                                                                height: 40,
                                                                width: 40,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                          .blue[
                                                                      900],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                ),
                                                                child: Center(
                                                                    child: Icon(
                                                                  Icons
                                                                      .image_search_rounded,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 20,
                                                                )),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  _recuperarImagem(
                                                                      "camera",
                                                                      catalogitems[
                                                                              index]
                                                                          [
                                                                          'PROREFERENCIA']);
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  width: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                            .blue[
                                                                        900],
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                  ),
                                                                  child: Center(
                                                                      child:
                                                                          Icon(
                                                                    Icons
                                                                        .camera_alt,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 20,
                                                                  )),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
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

  Future<dynamic> _showChoiceDialog(BuildContext context, String proref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            // You need this, notice the parameters below:
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Center(
                      child: Text(
                        "SELECIONE A IMAGEM",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                    ),
                    GestureDetector(
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt),
                            Padding(padding: EdgeInsets.all(8.0)),
                            Text("Camera"),
                          ],
                        ),
                        onTap: () {
                          _recuperarImagem("camera", proref);
                        }),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                    ),
                    GestureDetector(
                        child: Row(
                          children: [
                            Icon(Icons.image),
                            Padding(padding: EdgeInsets.all(8.0)),
                            Text("Galeria"),
                          ],
                        ),
                        onTap: () {
                          _recuperarImagem("galeria", proref);
                        }),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                    ),
                    _subindoImagem == true
                        ? Center(child: CircularProgressIndicator())
                        : Text("")
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<Widget> _decideImageView(int proref) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    File savedImage;
    try {
      savedImage = await File(appDir.path + "/$proref.jpg");
    } catch (FileSystemException) {
      print("imagem faltando");
    }

    if (savedImage == null) {
      return Text("Nenhuma imagem selecionada");
    } else {
      return Image.file(savedImage, width: 200, height: 200);
    }
  }

  _openCamera(BuildContext context, int proref) async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    this.setState(() {
      _image = image;
    });

    final appDir = await syspaths.getApplicationDocumentsDirectory();

    final savedImage = await _image.copy('${appDir.path}/$proref.jpg');

    print(savedImage.path);

    this.setState(() {
      _image = savedImage;
    });

    Navigator.of(context).pop();
  }

  _openGalery(BuildContext context, int proref) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      _image = image;
    });

    final appDir = await syspaths.getApplicationDocumentsDirectory();

    final savedImage = await _image.copy('${appDir.path}/$proref.jpg');

    print(savedImage.path);

    this.setState(() {
      _image = savedImage;
    });

    Navigator.of(context).pop();
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

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(prod.PRONOME),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Produto: ' + prod.PRONOME,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Descrição: ' + prod.PRODESCRICAO,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Valor: R\$:  ${_formatValue(prod.PROVALOR)}',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              color: Colors.blue[900],
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> buscarProduto(String proref) async {
    String url =
        "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/selectProd.php?proid=${proref}";

    final response = await http.post(Uri.parse(url), body: c.toJson());

    var obj = convert.json.decode(response.body);
    var msg = obj["message"];

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      dados = obj['result'];

      _showChoiceDialog(context, dados[0]['PROREFERENCIA']);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
    if (msg == "Dados incorretos!") {
      MensagemDadosIncorretos();
    } else {}
  }

  _dados(dados) {
    PRONOME = dados[0]['PRONOME'];
    PRODESCRICAO = dados[0]['PRODESCRICAO'];
    PROVALOR = dados[0]['PROVALORVENDA1'];
    PROIMAGEM = dados[0]['PROIMAGEM'];

    this.prod.PROID = int.parse(dados[0]['PROREFERENCIA']);
    this.prod.PRONOME = PRONOME;
    this.prod.PRODESCRICAO = PRODESCRICAO;
    this.prod.PROVALOR = double.parse(PROVALOR);
    this.prod.PROIMAGEM = PROIMAGEM;
    return prod;
  }

  Future getData() async {
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
      print("Error");
    }
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

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  Future selectProdutos(String busca, String preco) async {
    var response = await http.post(
        Uri.parse(
            "http://crtsistemas.com.br/crt_mobile_flutter/apis/produtos/selectPronome.php?preco=${preco}&busca=${busca}&idCliente=${empid}"),
        body: c.toJson());

    var obj = convert.json.decode(response.body);
    var code = obj['code'];
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
}
