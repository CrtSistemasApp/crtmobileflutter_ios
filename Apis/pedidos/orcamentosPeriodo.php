<?php

$host= $_POST['host'];
$dbname=$_POST['bdname'];
$user = $_POST['usuario'];
$pass = $_POST['senha'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$cliid = $_GET['cliid'];
$venid = $_GET['venid'];
$datainicial = $_GET['datainicial'];
$datafinal = $_GET['datafinal'];
$status = $_GET['status'];
$statusN = "";
$statusU = "";

$dados = array();

date_default_timezone_set('America/Sao_Paulo');




try {
    $pdo = new PDO($dns, $user, $pass);


    if ($status == '2') {
        $query = $pdo->query("SELECT O.ORCSTATUS, O.ORCID, V.VENNOME, C.CLIFONE01, C.CLIFONE02, C.CLINOMERAZAO, O.ORCDATA, O.ORCVALORTOTAL, O.ORCHORA FROM ORCAMENTOS O JOIN CLIENTES C ON (O.CLIID = C.CLIID) JOIN VENDEDORES V ON (O.VENID = V.VENID) WHERE (O.ORCSTATUS= '0' OR O.ORCSTATUS='N' OR O.ORCSTATUS='A' OR O.ORCSTATUS='1') AND O.VENID = '$venid' AND O.CLIID = '$cliid' AND ORCDATA BETWEEN '$datainicial' AND '$datafinal';");

        $res = $query->fetchAll(PDO::FETCH_ASSOC);
    } elseif ($status == 0) {
        $query = $pdo->query("SELECT O.ORCSTATUS, O.ORCID, V.VENNOME, C.CLIFONE01, C.CLIFONE02, C.CLINOMERAZAO, O.ORCDATA, O.ORCVALORTOTAL, O.ORCHORA FROM ORCAMENTOS O JOIN CLIENTES C ON (O.CLIID = C.CLIID) JOIN VENDEDORES V ON (O.VENID = V.VENID) WHERE (O.ORCSTATUS= '0' OR O.ORCSTATUS='N' OR O.ORCSTATUS='A') AND O.VENID = '$venid' AND O.CLIID = '$cliid' AND ORCDATA BETWEEN '$datainicial' AND '$datafinal';");

        $res = $query->fetchAll(PDO::FETCH_ASSOC);
    } else {
        $query = $pdo->query("SELECT O.ORCSTATUS, O.ORCID, V.VENNOME, C.CLIFONE01, C.CLIFONE02, C.CLINOMERAZAO, O.ORCDATA, O.ORCVALORTOTAL, O.ORCHORA FROM ORCAMENTOS O JOIN CLIENTES C ON (O.CLIID = C.CLIID) JOIN VENDEDORES V ON (O.VENID = V.VENID) WHERE O.ORCSTATUS= '$status' AND O.VENID = '$venid' AND O.CLIID = '$cliid' AND ORCDATA BETWEEN '$datainicial' AND '$datafinal';");

        $res = $query->fetchAll(PDO::FETCH_ASSOC);

    }

    for ($i = 0; $i < count($res); $i++) {
        foreach ($res[$i] as $key => $value) {
        }

        $dados = $res;
    }

    echo ($res) ?
        json_encode(array("code" => 1, "result" => $dados)) :
        json_encode(array("code" => 0, "message" => "Dados incorretos!", "status" => $status));
} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}
