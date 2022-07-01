import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteraplicativo/src/componentes/routes.dart';
import 'package:flutteraplicativo/src/models/checkBoxModel.dart';
import 'package:flutteraplicativo/src/models/clienteProvider.dart';
import 'package:flutteraplicativo/src/models/configuracoes.dart';
import 'package:flutteraplicativo/src/models/conexaoProvider.dart';
import 'package:flutteraplicativo/src/models/configEspe.dart';
import 'package:flutteraplicativo/src/models/configProvider.dart';
import 'package:flutteraplicativo/src/models/empresaModel.dart';
import 'package:flutteraplicativo/src/models/formasModel.dart';
import 'package:flutteraplicativo/src/models/produtoProvider.dart';
import 'package:flutteraplicativo/src/models/sequencialProvider.dart';
import 'package:flutteraplicativo/src/models/verdedorProvider.dart';
import 'package:flutteraplicativo/src/view/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final ThemeData temaIOS = ThemeData(
  primaryColor: Colors.blue[900],
  appBarTheme: AppBarTheme(backgroundColor: Colors.blue[900]),
);

final ThemeData temaPadrao = ThemeData(
  appBarTheme: AppBarTheme(backgroundColor: Colors.blue[900]),
  primaryColor: Colors.blue,
);

ThemeData thema() {
  if (Platform.isAndroid) {
    return temaPadrao;
  } else if (Platform.isIOS) {
    return temaIOS;
  }

  return null;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ConfiguracoesModel()),
        ChangeNotifierProvider(create: (context) => ProdutoProvider()),
        ChangeNotifierProvider(create: (context) => VendedorProvider()),
        ChangeNotifierProvider(create: (context) => ClienteProvider()),
        ChangeNotifierProvider(create: (context) => ConexaoProvider()),
        ChangeNotifierProvider(create: (context) => SequancialProvider()),
        ChangeNotifierProvider(create: (context) => CheckBoxModel()),
        ChangeNotifierProvider(create: (context) => FormasProvider()),
        ChangeNotifierProvider(create: (context) => Empresa()),
        ChangeNotifierProvider(create: (context) => ConfigProvider()),
        ChangeNotifierProvider(create: (context) => Especifica()),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [const Locale('pt', 'BR')],
        debugShowCheckedModeBanner: false,
        home: MyApp(),
      ),
    ));
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: thema(),
      home: InitialScreen(),
      initialRoute: "/",
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
