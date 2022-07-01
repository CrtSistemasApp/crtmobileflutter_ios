import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';


class HomeImagePicker extends StatefulWidget {
  @override
  _HomePickerState createState() => _HomePickerState();
}

class _HomePickerState extends State<HomeImagePicker> {
  File _image;

  Future<dynamic> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Make a Choice"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                      child: Text("Camera"),
                      onTap: () {
                        _openCamera(context);
                      }),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                      child: Text("Galeria"),
                      onTap: () {
                        _openGalery(context);
                      }),
                ],
              ),
            ),
          );
        });
  }

  _openCamera(BuildContext context) async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    this.setState(() {
      _image = image;
    });

    Navigator.of(context).pop();
  }

  _openGalery(BuildContext context) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      _image = image;
    });

    Navigator.of(context).pop();
  }

  Widget _decideImageView() {
    if (_image == null) {
      return Text("Nenhuma imagem selecionada");
    } else {
      return Image.file(_image, width: 400, height: 400);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: Text('Image Picker'),
      ),
      body: Container(
        child: Center(
          child: Column(
            
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _decideImageView(),
             
              RaisedButton(
                onPressed: () {
                  _showChoiceDialog(context);
                },
                child: Text("Selecionar imagem"),)
            ],
          ),
        ),
      ),
    );
  }
}
