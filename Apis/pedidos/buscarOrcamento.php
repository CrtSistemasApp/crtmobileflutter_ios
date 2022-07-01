<?php

$host= $_POST['host'];
$dbname=$_POST['bdname'];
$user = $_POST['usuario'];
$pass = $_POST['senha'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$orcid = $_GET['orcid'];

date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);

    $dados = array();

    $query = $pdo->query("SELECT C.CLIID, V.VENID, O.ORCOBS2, O.EMPID, O.ORCID, V.VENNOME, V.VENFONE01,
    C.CLINOMERAZAO, C.CLICPF, O.ORCVALORTOTAL, 
    C.CLINOME,
    O.ORCOBS, O.ORCFORMAPAGAMENTOTXT, 
    O.ORCDATA,
    O.ORCOBS2, 
    O.ORCHORA,
    O.ORCSTATUS,
    P.PROID,
    P.PRONOME,
    P.PROREFERENCIA,
    CO.CORNOME,
    CO.CORID,
    TA.TAMID,
    TA.TAMNOME,

ORI.ORIQTD,
ORI.ORIDESCONTO,
ORI.ORIVALOR,
ORI.ORIOBS
    FROM ORCAMENTOS O
    JOIN CLIENTES C
    ON (O.CLIID = C.CLIID)
    JOIN VENDEDORES V
    ON (V.VENID = O.VENID)
    JOIN ORCAMENTOITENS ORI
    ON (ORI.ORCID = O.ORCID)
    JOIN PRODUTOS P
    ON (P.PROID = ORI.PROID)
    JOIN CORES CO ON(ORI.CORID = CO.CORID)
    JOIN TAMANHOS TA ON(ORI.TAMID = TA.TAMID)
    WHERE O.ORCID = $orcid;");
    $res = $query->fetchAll(PDO::FETCH_ASSOC);


    for ($i = 0; $i < count($res); $i++) {
        foreach ($res[$i] as $key => $value) {
        }

        $dados = $res;
    }

    echo ($res) ?
        json_encode(array("code" => 1, "result" => $dados)) :
        json_encode(array("code" => 0, "message" => "Dados incorretos!"));
} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}
