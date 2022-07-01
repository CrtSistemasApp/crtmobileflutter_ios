import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/models/Database.dart';
import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/empresaModel.dart';
import 'package:flutteraplicativo/src/view/home2.dart';
import 'package:flutteraplicativo/src/view/login/loginPage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class EmpresaView extends StatefulWidget {
  @override
  State<EmpresaView> createState() => _EmpresaViewState();
}

class _EmpresaViewState extends State<EmpresaView>
    with SingleTickerProviderStateMixin {
  Conexao c = Conexao();
  TabController _tabController;
  List<String> itensMenu = ["Ajuda", "Sair"];
  Empresa empresa = Empresa();
  File _imagem;
  String _idUsuarioLogado;
  bool _subindoImagem = false;
  String _urlImagemRecuperada;

  _deslogarUsuario() async {
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  void recuperarConexao() async {
    List list = await DBProvider.db.getAllConexaos();

    if (list.isNotEmpty) {
      c = await DBProvider.db.getConexao(1);
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

  Future _uploadImagem(String cnpj) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();

    StorageReference arquivo =
        pastaRaiz.child("empresas").child(cnpj.toString() + ".jpg");

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
            edit(cnpj, value),
          },
        );
  }

  edit(String cnpj, String url) async {
    await _editImage(cnpj, url).then((sucess) => {
          Fluttertoast.showToast(
              msg: "Upload de imagem com sucesso!",
              backgroundColor: Colors.blue[900],
              textColor: Colors.white,
              fontSize: 16.0),
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Login(),
              ))
        });
  }

  Future<String> _editImage(String cnpj, String url) async {
    Map<String, String> toJson() => {'url': '${url}', 'cnpj': '${cnpj}'};

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Charset': 'utf-8'
    };

    final result = await http.post(
      'http://crtsistemas.com.br/crt_mobile_flutter/apis/empresas/alterarLogo.php?usuario=${c.user}&senha=${c.pass}&bdname=${c.bdname}&host=${c.host}',
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

  @override
  void initState() {
    recuperarConexao();
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  Future _recuperarImagem(String origemImagem, String cnpj) async {
    File imagemSelecionada;
    switch (origemImagem) {
      case "camera":
        imagemSelecionada =
            await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case "galeria":
        imagemSelecionada =
            await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      _imagem = imagemSelecionada;
      if (_imagem != null) {
        _subindoImagem = true;
        //_uploadImagem(proref);
        _uploadImagem(cnpj);
      }
    });
  }

  _body() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            empresa.LOGOMARCA == ""
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 180,
                      width: 500,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.network(
                          "https://firebasestorage.googleapis.com/v0/b/crtmobile-2581b.appspot.com/o/empresas%2Fsemimagem.jpg?alt=media&token=bf681856-65b7-4654-9cd9-6b17590471e8",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                        height: 180,
                        width: 500,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.network(empresa.LOGOMARCA))),
                  ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 100),
                    child: _subindoImagem == true
                        ? CircularProgressIndicator()
                        : Container(),
                  ),
                  ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blue[900])),
                      onPressed: () {
                        _recuperarImagem("galeria", empresa.EMPCNPJ);
                      },
                      icon: Icon(Icons.image_search_outlined),
                      label: Text("Galeria")),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.blue[900])),
                        onPressed: () {
                          _recuperarImagem("camera", empresa.EMPCNPJ);
                        },
                        icon: Icon(Icons.image_search_outlined),
                        label: Text("Camera")),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'INFORMAÇÕES DA EMPRESA',
                      labelStyle: TextStyle(fontSize: 18.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                              text: 'RAZÃO SOCIAL: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: empresa.EMPRAZAOSOCIAL,
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'NOME FANTASIA: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: empresa.EMPNOMEFANTASIA,
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'CNPJ: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: empresa.EMPCNPJ,
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'FONES: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      "${empresa.EMPFONE01} / ${empresa.EMPFONE02}",
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'E-MAIL: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: empresa.EMPEMAIL,
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Endereço"),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'LOGRADOURO: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: empresa.EMPENDERECO,
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'BAIRRO: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: empresa.EMPBAIRRO,
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'CIDADE: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: empresa.EMPCIDADE,
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'CEP: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: empresa.EMPCEP,
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'UF: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: empresa.EMPUF,
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                        ),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void recuperarEmpid() {
    if (Provider.of<Empresa>(context).empresa != null) {
      empresa = Provider.of<Empresa>(context).empresa;

      print(empresa.LOGOMARCA);
    }
  }

  @override
  void didChangeDependencies() {
    recuperarEmpid();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
      appBar: AppBar(
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
        title: Text(
          empresa.EMPNOMEFANTASIA == ""
              ? "EMPRESA"
              : "${empresa.EMPNOMEFANTASIA}",
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}
