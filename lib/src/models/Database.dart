import 'dart:async';

import 'package:flutteraplicativo/src/models/conexao.dart';
import 'package:flutteraplicativo/src/models/configuracoesModel.dart';
import 'package:flutteraplicativo/src/models/empresaModel.dart';
import 'package:flutteraplicativo/src/models/sequencialProvider.dart';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  static const tableConexao = """
  CREATE TABLE IF NOT EXISTS Conexao (
        id INTEGER,
        host TEXT,
        bdname TEXT,
        usuario TEXT,
        senha TEXT
      );""";

  static const tableConfig = """
  CREATE TABLE IF NOT EXISTS Config (
        id INTEGER,
        descontoItem TEXT,
        descontoTotal TEXT,
        custo TEXT,
        formas TEXT,
        valorVenda TEXT,
        obs TEXT,
        cnpjEmpresa TEXT
      );""";

  static const tableSequencial = """
  CREATE TABLE IF NOT EXISTS Sequencial (
        id INTEGER,
        sequenCliente TEXT,
        sequenOrc TEXT
      );""";
  static const tableEmpresa = """
  CREATE TABLE IF NOT EXISTS Empresa (
        id INTEGER,
        cnpjEMP TEXT
      );""";

  Future<Database> initDB() async {
    print("initDB executed");
    //Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(await getDatabasesPath(), "Conexao.db");
    // await deleteDatabase(path);
    return await openDatabase(path, version: 2,
        onCreate: (Database db, int version) async {
      await db.execute(tableConexao);
      await db.execute(tableConfig);
      await db.execute(tableSequencial);
      await db.execute(tableEmpresa);
    });
  }

  newConexao(Conexao newConexao) async {
    final db = await database;

    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Conexao (id,host,bdname,usuario,senha)"
        " VALUES (?,?,?,?,?)",
        [
          1,
          newConexao.host,
          newConexao.bdname,
          newConexao.user,
          newConexao.pass
        ]);
    return raw;
  }

  newEmpresa(Empresa emp) async {
    final db = await database;

    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Empresa (id,cnpjEMP)"
        " VALUES (?,?)",
        [emp.EMPID, emp.EMPCNPJ]);
    return raw;
  }

  newSequencial(Sequencial sequen) async {
    final db = await database;

    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Sequencial (id,sequenCliente,sequenOrc)"
        " VALUES (?,?,?)",
        [
          1,
          sequen.sequenCliente,
          sequen.sequenOrc,
        ]);
    return raw;
  }

  newConfig(ConfigModel config) async {
    final db = await database;

    var raw = await db.rawInsert(
        "INSERT Into Config (id,descontoItem,descontoTotal,custo,formas,valorVenda,obs,cnpjEmpresa)"
        " VALUES (?,?,?,?,?,?,?,?)",
        [
          1,
          config.descontoItem,
          config.descontoTotal,
          config.custo,
          config.formas,
          config.valorVenda,
          config.obs,
          config.cnpjEmpresa
        ]);
    return raw;
  }

  updateConexao(Conexao newConexao) async {
    final db = await database;
    var res = await db.update("Conexao", newConexao.toJson(),
        where: "id = ?", whereArgs: [newConexao.id]);
    return res;
  }

  updateConfig(ConfigModel config) async {
    final db = await database;
    var res = await db.update("Config", config.toMap(),
        where: "id = ?", whereArgs: [config.id]);
    return res;
  }

  getConexao(int id) async {
    final db = await database;
    var res = await db.query("Conexao", where: "id = ?", whereArgs: [id]);

    return res.isNotEmpty ? Conexao.fromMap(res.first) : null;
  }

  getEmpresa(int id) async {
    final db = await database;
    var res = await db.query("Empresa", where: "id = ?", whereArgs: [id]);

    return res.isNotEmpty ? Empresa.fromMapDB(res.first) : null;
  }

  getSequencial(int id) async {
    final db = await database;
    var res = await db.query("Sequencial", where: "id = ?", whereArgs: [id]);

    return res.isNotEmpty ? Sequencial.fromMap(res.first) : null;
  }

  getConfig(int id) async {
    final db = await database;
    var res = await db.query("Config", where: "id = ?", whereArgs: [id]);

    return res.isNotEmpty ? ConfigModel.fromMap(res.first) : null;
  }

  Future<List<Conexao>> getusuarioConexaos() async {
    final db = await database;

    // var res = await db.rawQuery("SELECT * FROM Conexao WHERE usuario=1");
    var res = await db.query("Conexao", where: "usuario = ? ", whereArgs: [1]);

    List<Conexao> list =
        res.isNotEmpty ? res.map((c) => Conexao.fromMap(c)).toList() : [];

    return list;
  }

  Future<List<Conexao>> getAllConexaos() async {
    final db = await database;
    var res = await db.query("Conexao");
    List<Conexao> list =
        res.isNotEmpty ? res.map((c) => Conexao.fromMap(c)).toList() : [];

    return list;
  }

  Future<List<Empresa>> getAllEmpresa() async {
    final db = await database;
    var res = await db.query("Empresa");
    List<Empresa> list =
        res.isNotEmpty ? res.map((c) => Empresa.fromMapDB(c)).toList() : [];

    return list;
  }

  Future<List<Sequencial>> getAllSequencial() async {
    final db = await database;
    var res = await db.query("Sequencial");
    List<Sequencial> list =
        res.isNotEmpty ? res.map((c) => Sequencial.fromMap(c)).toList() : [];

    return list;
  }

  Future<List<ConfigModel>> getAllConfig() async {
    final db = await database;
    var res = await db.query("Config");
    List<ConfigModel> list =
        res.isNotEmpty ? res.map((c) => ConfigModel.fromMap(c)).toList() : [];

    return list;
  }

  deleteConexao(int id) async {
    final db = await database;
    return db.delete("Conexao", where: "id = ?", whereArgs: [id]);
  }

  deleteConfig(int id) async {
    final db = await database;
    return db.delete("Config", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("DELETE FROM Conexao");
  }

  deleteAllConfi() async {
    final db = await database;
    db.rawDelete("DELETE FROM Config");
  }

  deleteAllSequen() async {
    final db = await database;
    db.rawDelete("DELETE FROM Sequencial");
  }

  deleteAllEmpresa() async {
    final db = await database;
    db.rawDelete("DELETE FROM Empresa");
  }
}
