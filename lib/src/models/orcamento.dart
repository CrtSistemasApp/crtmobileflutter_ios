import 'package:flutteraplicativo/src/models/produtos.dart';

class Orcamento {
  int ORCID;
  int VENID;
  int CLIID;
  int EMPID;
  String ORCOBS;
  String ORCOBS2;
  String ORCFORMAPAGAMENTOTXT;
  String ORCDATA;
  String ORCHORA;
  String VENNOME;
  double ORCVALORTOTAL;
  String CLINOMERAZAO;
  String CLINOMEFANTASIA;
  String FONEVEND;
  String CLICPF;
  List<Produto> produtos;

  Orcamento(
      {this.ORCID,
      this.VENID,
      this.CLIID,
      this.ORCDATA,
      this.ORCHORA,
      this.VENNOME,
      this.CLINOMERAZAO,
      this.CLINOMEFANTASIA,
      this.ORCVALORTOTAL,
      this.ORCOBS,
      this.ORCFORMAPAGAMENTOTXT,
      this.EMPID,
      this.ORCOBS2,
      this.CLICPF,
      this.FONEVEND,
      this.produtos});

  Map<String, dynamic> toJson() => {
        'ORCID': "${ORCID}",
        'VENID': "${VENID}",
        'CLIID': "${CLIID}",
        'ORCDATA': "${ORCDATA}",
        'ORCHORA': "${ORCHORA}",
        'ORCVALORTOTAL': "${ORCVALORTOTAL}",
        'EMPID': "${EMPID}",
        'ORCOBS': "${ORCOBS}",
        'ORCFORMAPAGAMENTOTXT': "${ORCFORMAPAGAMENTOTXT}",
        'ORCOBS2': "${ORCOBS2}",
        'VENFONE01': "${FONEVEND}",
        'LIST': "${produtos}"
      };

  @override
  String toString() {
    return 'Orcamento(ORCID: $ORCID, VENID: $VENID, CLIID: $CLIID, EMPID: $EMPID, ORCOBS: $ORCOBS, ORCOBS2: $ORCOBS2, ORCFORMAPAGAMENTOTXT: $ORCFORMAPAGAMENTOTXT, ORCDATA: $ORCDATA, CLICPF: $CLICPF, VENFONE01: $FONEVEND, ORCHORA: $ORCHORA, VENNOME: $VENNOME, ORCVALORTOTAL: $ORCVALORTOTAL, CLINOMERAZAO: $CLINOMERAZAO, CLINOMEFATASIA: $CLINOMEFANTASIA)';
  }
}

class OrcamentoItem {
  int ORCID;
  int PROID;
  int LOCID;
  double ORIVALOR;
  double ORIQTD;
  double ORIDESCONTO;
  String ORIOBS;
  int CORID;
  int TAMID;
  bool edit;

  OrcamentoItem(
      {this.ORCID,
      this.PROID,
      this.ORIVALOR,
      this.ORIQTD,
      this.ORIDESCONTO,
      this.LOCID,
      this.ORIOBS,
      this.CORID,
      this.TAMID,
      this.edit});

  Map<String, dynamic> toJson() => {
        'PROID': "${PROID}",
        'ORCID': "${ORCID}",
        'ORIVALOR': "${ORIVALOR}",
        'ORIQTD': "${ORIQTD}",
        'ORIDESCONTO': "${ORIDESCONTO}",
        'LOCID': "${LOCID}",
        'ORIOBS': "${ORIOBS}",
        'CORID': "${CORID}",
        'TAMID': "${TAMID}",
        'EDIT': "${edit}",
      };

  @override
  String toString() {
    return 'OrcamentoItem(ORCID: $ORCID, PROID: $PROID, LOCID: $LOCID, ORIVALOR: $ORIVALOR, ORIQTD: $ORIQTD, ORIDESCONTO: $ORIDESCONTO, ORIOBS: $ORIOBS, CORID: $CORID, TAMID: $TAMID, edit: $edit )';
  }
}
