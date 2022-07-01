import 'package:fluttertoast/fluttertoast_web.dart';
import 'package:printing/printing_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(Registrar registrar) {
  FluttertoastWebPlugin.registerWith(registrar);
  PrintingPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
