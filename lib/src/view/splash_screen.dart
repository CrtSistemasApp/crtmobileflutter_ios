import 'package:flutter/material.dart';
import 'package:flutteraplicativo/src/view/login/loginPage.dart';
import 'package:splashscreen/splashscreen.dart';

class InitialScreen extends StatefulWidget {
  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 2,
      navigateAfterSeconds: new Login(),
      image: Image.asset(
        "assets/logo1.png",
      ),

      photoSize: 100,
      loadingText: Text(
        "CRT SISTEMAS MOBILE",
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      imageBackground: AssetImage("assets/backgroud.jpeg"),
      //image: new Image.network(
      //    'https://flutter.io/images/catalog-widget-placeholder.png'),
      backgroundColor: Colors.white,
      loaderColor: Colors.white,
    );
  }
}
